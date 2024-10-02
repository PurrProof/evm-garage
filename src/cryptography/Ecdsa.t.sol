// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EcdsaTest is Test {
    address alice;
    uint256 alicePk;

    bytes32 MsgHash;
    bytes32 S;
    bytes32 R;
    uint8 V;

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");
        MsgHash = keccak256("Signed by Alice!!!sdfsdf");
        (V, R, S) = vm.sign(alicePk, MsgHash);
    }

    /*
    https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/utils/cryptography/ECDSA.sol#L122

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }
     */

    function test_ecrecover() public view {
        address signer = ecrecover(MsgHash, V, R, S);
        assertEq(alice, signer);
    }

    function test_ecrecover_error() public view {
        uint8 wrongV = 42;
        address signer = ecrecover(MsgHash, wrongV, R, S);
        assertEq(0x0000000000000000000000000000000000000000, signer);

        signer = ecrecover(MsgHash, wrongV, R, S << 1);
        assertNotEq(alice, signer);
    }
}
