// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";

contract Erc1271Test is Test {
    using ECDSA for bytes32;

    address eoaSigner;
    uint256 eoaPrivateKey;

    ERC1271Wallet contractSigner;

    bytes32 messageHash;
    bytes signature;

    function setUp() public {
        // set up eoa signer
        (eoaSigner, eoaPrivateKey) = makeAddrAndKey("eoaSigner");

        // deploy erc1271-compliant contract
        contractSigner = new ERC1271Wallet(eoaSigner);

        // create message hash
        messageHash = keccak256("Test message");

        // sign the message with the eoa private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(eoaPrivateKey, messageHash);
        signature = abi.encodePacked(r, s, v);
    }

    // test against eoa - success case
    function test_EOA_Signature_Success() public view {
        bool isValid = SignatureChecker.isValidSignatureNow(eoaSigner, messageHash, signature);
        assertTrue(isValid, "EOA signature should be valid");
    }

    // test against eoa - failure case
    function test_EOA_Signature_Failure() public view {
        // alter the message hash to simulate an invalid signature
        bytes32 invalidHash = keccak256("Invalid message");
        bool isValid = SignatureChecker.isValidSignatureNow(eoaSigner, invalidHash, signature);
        assertFalse(isValid, "EOA signature should be invalid for altered message");
    }

    // test against sc - success case
    function test_SC_Signature_Success() public view {
        bool isValid = SignatureChecker.isValidSignatureNow(address(contractSigner), messageHash, signature);
        assertTrue(isValid, "Contract signature should be valid");
    }

    // test against sc - failure case
    function test_SC_Signature_Failure() public view {
        // use an invalid signature
        bytes memory invalidSignature = bytes("invalid_signature");
        bool isValid = SignatureChecker.isValidSignatureNow(address(contractSigner), messageHash, invalidSignature);
        assertFalse(isValid, "Contract signature should be invalid with incorrect signature");
    }
}

// https://eips.ethereum.org/EIPS/eip-1271
// simple erc1271-compliant wallet contract
contract ERC1271Wallet is IERC1271 {
    address public owner;
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    constructor(address _owner) {
        owner = _owner;
    }

    // implement isvalidsignature as per erc1271
    function isValidSignature(bytes32 _hash, bytes memory _signature) public view override returns (bytes4) {
        // recover signer using ecdsa
        address signer = ECDSA.recover(_hash, _signature);
        if (signer == owner) {
            return MAGICVALUE;
        } else {
            return 0xffffffff;
        }
    }
}
