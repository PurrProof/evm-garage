// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/Test.sol";

contract Mail {
    struct MailStruct {
        address to;
        string contents;
    }
}

contract MailVerifier is EIP712, Mail {
    string private constant SIGNING_DOMAIN = "MailDomain";
    string private constant SIGNATURE_VERSION = "1";

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function verifyMail(address signer, MailStruct memory mail, bytes memory signature) public view returns (bool) {
        bytes32 digest = _hashMail(mail);
        address recoveredSigner = ECDSA.recover(digest, signature);
        return recoveredSigner == signer;
    }

    function _hashMail(MailStruct memory mail) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(keccak256("Mail(address to,string contents)"), mail.to, keccak256(bytes(mail.contents)))
            )
        );
    }
}

contract MailVerifierTest is Test, Mail {
    MailVerifier internal verifier;

    uint256 internal signerPrivateKey;
    address internal signer;

    MailStruct mail;

    function setUp() public {
        mail = MailStruct({to: address(0xB0B), contents: "Hello, Bob!"});

        verifier = new MailVerifier();
        (signer, signerPrivateKey) = makeAddrAndKey("Alice");
    }

    function testVerifyMail() public view {
        // get the digest (EIP-712 hash of the Mail struct)
        bytes32 digest = verifier._hashMail(mail);

        // sign the digest using Foundry's vm.sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // verify the signature on-chain
        bool isValid = verifier.verifyMail(signer, mail, signature);

        assertTrue(isValid, "Signature should be valid");
    }

    function testRevert_InvalidSigner() public view {
        // get the digest (EIP-712 hash of the Mail struct)
        bytes32 digest = verifier._hashMail(mail);

        // sign the digest using a different private key (incorrect signer)
        uint256 wrongPrivateKey = 0xBEEF;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // verify the signature on-chain with the wrong signer
        bool isValid = verifier.verifyMail(signer, mail, signature);

        assertFalse(isValid, "Signature should be invalid");
    }
}
