// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleProofVerifier {
    bytes32 private _root;

    constructor(bytes32 root) {
        _root = root;
    }

    function verify(address addr, uint256 amount, bytes32[] calldata proof) external view returns (bool result) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, amount))));
        return MerkleProof.verifyCalldata(proof, _root, leaf);
    }

    function verifyMulti(
        address[] calldata addrs,
        uint256[] calldata amounts,
        bytes32[] calldata proof,
        bool[] calldata proofFlags
    )
        external
        view
        returns (bool result)
    {
        bytes32[] memory leaves = new bytes32[](addrs.length);
        for (uint256 i = 0; i < addrs.length; ++i) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(addrs[i], amounts[i]))));
        }
        return MerkleProof.multiProofVerify(proof, proofFlags, _root, leaves);
    }

    function process(address addr, uint256 amount, bytes32[] calldata proof) external pure returns (bytes32 rootHash) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, amount))));
        return MerkleProof.processProofCalldata(proof, leaf);
    }

    function processMulti(
        address[] calldata addrs,
        uint256[] calldata amounts,
        bytes32[] calldata proof,
        bool[] calldata proofFlags
    )
        external
        pure
        returns (bytes32 rootHash)
    {
        bytes32[] memory leaves = new bytes32[](addrs.length);
        for (uint256 i = 0; i < addrs.length; ++i) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(addrs[i], amounts[i]))));
        }
        return MerkleProof.processMultiProof(proof, proofFlags, leaves);
    }
}

/*
https://purrproof.github.io/merkle-proof-vis/?sig=%255B%2522address%2522%252C%2522uint256%2522%255D&lzdata=0x36b04401803c1196fe18a73ea00d280ace1eeffdd40174d00a14b0a00986daefa1c69bbd50aec0cf093ccb20199050e123458f1c35b42e33c313214224002caad7a8d9ab76f5ac03b0759f9891200000
["address","uint256"]
[["0x1111111111111111111111111111111111111111","5000000000000000000"],
["0x2222222222222222222222222222222222222222","2500000000000000000"],
["0x3333333333333333333333333333333333333333","1000000000000000000"],
["0x4444444444444444444444444444444444444444","7500000000000000000"]]
*/

contract MerkleProofTest is Test {
    MerkleProofVerifier private _verifier;
    bytes32 private _root = 0x313b9da6990be49c650b99c51a9d562e0030cb42d117143019d7a0cd1599abb6;
    address private _zeroAddr = 0x0000000000000000000000000000000000000000;

    function setUp() public {
        _verifier = new MerkleProofVerifier(_root);
    }

    function test_verify() public view {
        address addr = 0x1111111111111111111111111111111111111111;
        uint256 amount = 5_000_000_000_000_000_000;
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xe4fc5b35ba4bd627dffb795fa4c398e7896386584837a8a23f7f3c9ab869b7cc;
        proof[1] = 0xe41d42f0f52b6a0b2c223d0b753143fd6a381a04f9d788ed30d3787e83f57f85;
        bool result = _verifier.verify(addr, amount, proof);
        assertTrue(result);

        // wrong address will not be verified
        assertFalse(_verifier.verify(_zeroAddr, amount, proof));

        // wrong amount will not be verified
        assertFalse(_verifier.verify(addr, 1 wei, proof));

        // wrong proof will not be verified
        proof[0] <<= 1;
        assertFalse(_verifier.verify(addr, amount, proof));
    }

    function test_verifyMulti() public view {
        address[] memory addr = new address[](2);
        addr[0] = 0x2222222222222222222222222222222222222222;
        addr[1] = 0x1111111111111111111111111111111111111111;
        uint256[] memory amount = new uint256[](2);
        amount[0] = 2_500_000_000_000_000_000;
        amount[1] = 5_000_000_000_000_000_000;

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(0xbf7ba4aa09bb952bf1fa9eb251775b985f51d0b893993325176ea8d7697b1355);
        proof[1] = 0xe4fc5b35ba4bd627dffb795fa4c398e7896386584837a8a23f7f3c9ab869b7cc;

        bool[] memory proofFlags = new bool[](3);
        proofFlags[0] = false;
        proofFlags[1] = false;
        proofFlags[2] = true;

        // verify multi proof
        bool result = _verifier.verifyMulti(address[](addr), amount, proof, proofFlags);
        assertTrue(result);

        // wrong address or amount will fail
        addr[0] = _zeroAddr;
        result = _verifier.verifyMulti(addr, amount, proof, proofFlags);
        assertFalse(result);
        addr[0] = 0x2222222222222222222222222222222222222222;

        amount[0] = 12_345;
        result = _verifier.verifyMulti(addr, amount, proof, proofFlags);
        assertFalse(result);
        amount[0] = 2_500_000_000_000_000_000;

        // same for proofs and flags
    }

    function test_processProof() public view {
        address addr = 0x1111111111111111111111111111111111111111;
        uint256 amount = 5_000_000_000_000_000_000;
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xe4fc5b35ba4bd627dffb795fa4c398e7896386584837a8a23f7f3c9ab869b7cc;
        proof[1] = 0xe41d42f0f52b6a0b2c223d0b753143fd6a381a04f9d788ed30d3787e83f57f85;
        bytes32 rootHash = _verifier.process(addr, amount, proof);
        assertEq(rootHash, _root);

        // rootHash will be different if address changed
        rootHash = _verifier.process(_zeroAddr, amount, proof);
        assertNotEq(rootHash, _root);

        // rootHash will be different if amount changed
        rootHash = _verifier.process(addr, 1 wei, proof);
        assertNotEq(rootHash, _root);

        // rootHash will be different if proofs changed
        proof[0] <<= 1;
        rootHash = _verifier.process(addr, 1 wei, proof);
        assertNotEq(rootHash, _root);
    }

    function test_processMulti() public view {
        address[] memory addr = new address[](2);
        addr[0] = 0x2222222222222222222222222222222222222222;
        addr[1] = 0x1111111111111111111111111111111111111111;
        uint256[] memory amount = new uint256[](2);
        amount[0] = 2_500_000_000_000_000_000;
        amount[1] = 5_000_000_000_000_000_000;

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(0xbf7ba4aa09bb952bf1fa9eb251775b985f51d0b893993325176ea8d7697b1355);
        proof[1] = 0xe4fc5b35ba4bd627dffb795fa4c398e7896386584837a8a23f7f3c9ab869b7cc;

        bool[] memory proofFlags = new bool[](3);
        proofFlags[0] = false;
        proofFlags[1] = false;
        proofFlags[2] = true;

        // process mult proof
        bytes32 rootHash = _verifier.processMulti(address[](addr), amount, proof, proofFlags);
        assertEq(rootHash, _root);

        // wrong address or amount will fail
        addr[0] = _zeroAddr;
        rootHash = _verifier.processMulti(addr, amount, proof, proofFlags);
        assertNotEq(rootHash, _root);
        addr[0] = 0x2222222222222222222222222222222222222222;

        amount[0] = 12_345;
        rootHash = _verifier.processMulti(addr, amount, proof, proofFlags);
        assertNotEq(rootHash, _root);
        amount[0] = 2_500_000_000_000_000_000;

        // same for proofs and flags
    }
}
