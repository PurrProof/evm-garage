// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract Mail {
    struct MailStruct {
        address to;
        string contents;
    }

    function _eip712StructHash(MailStruct calldata mail) internal pure returns (bytes32 structHash) {
        return keccak256(
            abi.encode(keccak256("Mail(address to,string contents)"), mail.to, keccak256(bytes(mail.contents)))
        );
    }
}

contract MailVerifier is EIP712, Mail {
    string private constant SIGNING_DOMAIN = "MailDomain";
    string private constant SIGNATURE_VERSION = "1";

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function verifyMail(
        address signer,
        MailStruct calldata mail,
        bytes calldata signature
    )
        public
        view
        returns (bool)
    {
        bytes32 digest = _hashTypedDataV4(_eip712StructHash(mail));
        address recoveredSigner = ECDSA.recover(digest, signature);
        return recoveredSigner == signer;
    }
}

contract MailOffchainSigner is EIP712, Mail, Test {
    string private constant SIGNING_DOMAIN = "MailDomain";
    string private constant SIGNATURE_VERSION = "1";

    uint256 internal signerPrivateKey;
    address internal signer;
    address private verifierAddress;

    constructor(address _verifierAddress) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        (signer, signerPrivateKey) = makeAddrAndKey("Alice");
        verifierAddress = _verifierAddress;
    }

    function sign(MailStruct calldata mail) public view returns (bytes memory signature, address _signer) {
        // Manually compute the digest using the verifier's domain separator
        bytes32 digest = MessageHashUtils.toTypedDataHash(_verifierDomainSeparator(), _eip712StructHash(mail));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        signature = abi.encodePacked(r, s, v);
        return (signature, signer);
    }

    // we need this because domain separator calculates for address(this)
    function _verifierDomainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(SIGNING_DOMAIN)),
                keccak256(bytes(SIGNATURE_VERSION)),
                block.chainid,
                verifierAddress
            )
        );
    }
}

contract MailVerifierTest is Test, Mail {
    MailVerifier internal verifier;
    MailOffchainSigner internal offchainSigner;

    MailStruct mail;

    function setUp() public {
        mail = MailStruct({to: address(0xB0B), contents: "Hello, Bob!"});

        verifier = new MailVerifier();
        offchainSigner = new MailOffchainSigner(address(verifier));
    }

    function testVerifyMail() public view {
        // emulate offchain signature generation
        (bytes memory signature, address signer) = offchainSigner.sign(mail);

        // verify the signature on-chain
        bool isValid = verifier.verifyMail(signer, mail, signature);

        assertTrue(isValid, "Signature should be valid");
    }

    function testRevert_InvalidSigner() public {
        // emulate offchain signature generation
        (bytes memory signature,) = offchainSigner.sign(mail);

        // verify the signature on-chain with the wrong signer
        address wrongSigner = makeAddr("Bob");
        bool isValid = verifier.verifyMail(wrongSigner, mail, signature);

        assertFalse(isValid, "Signature should be invalid");
    }
}
