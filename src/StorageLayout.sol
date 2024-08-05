// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract StorageStruct {
    struct SomeStruct {
        uint256 firstValue;
        uint16 secondValue;
        bool thirdValue;
    }

    uint256 a = 9198; // 0x23ee in hexadecimal
    uint256 b = 0x5f931e; // 6263582 in decimal
    SomeStruct structVariable = SomeStruct(0x452, 5, true);
    bytes32 c;
}

contract StorageMapping {
    struct S {
        uint16 a;
        uint16 b;
        uint256 c;
    }
    uint x;
    mapping(uint => mapping(uint => S)) data;
}

contract StorageString {
    string public test = "";
}
