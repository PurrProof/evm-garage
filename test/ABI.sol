// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract AbiTest is Test {
    struct Person {
        string name;
        string nick;
        uint256 age;
    }

    struct Tuple1 {
        uint256 uintValue1;
        bytes byteValue1;
        uint256 uintValue2;
    }

    struct Tuple2 {
        uint256 uintValue1;
        bytes byteValue1;
        bytes byteValue2;
        uint256 uintValue2;
    }

    function test_encodeUint256() public pure {
        uint256 value = 256;
        bytes memory encoded = abi.encode(value);
        bytes memory expected = hex"0000000000000000000000000000000000000000000000000000000000000100";
        assertEq(encoded, expected, "Uint256 encoding failed");
    }

    function test_encodeInt256() public pure {
        int256 value = -1;
        bytes memory encoded = abi.encode(value);
        bytes memory expected = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        assertEq(encoded, expected, "Int256 encoding failed");
    }

    function test_encodeBool() public pure {
        bool valueTrue = true;
        bool valueFalse = false;
        bytes memory encodedTrue = abi.encode(valueTrue);
        bytes memory encodedFalse = abi.encode(valueFalse);
        bytes memory expectedTrue = hex"0000000000000000000000000000000000000000000000000000000000000001";
        bytes memory expectedFalse = hex"0000000000000000000000000000000000000000000000000000000000000000";
        assertEq(encodedTrue, expectedTrue, "Bool true encoding failed");
        assertEq(encodedFalse, expectedFalse, "Bool false encoding failed");
    }

    function test_encodeAddress() public pure {
        address value = 0x1234567890123456789012345678901234567890;
        bytes memory encoded = abi.encode(value);
        bytes memory expected = hex"0000000000000000000000001234567890123456789012345678901234567890";
        assertEq(encoded, expected, "Address encoding failed");
    }

    function test_encodeString() public pure {
        string memory value = "Hello, World!";
        bytes memory encoded = abi.encode(value);

        bytes memory expected = hex"0000000000000000000000000000000000000000000000000000000000000020" // offset to
                // the content
            hex"000000000000000000000000000000000000000000000000000000000000000d" // length of the string (13 bytes)
            hex"48656c6c6f2c20576f726c642100000000000000000000000000000000000000"; // "Hello, World!"
        assertEq(encoded, expected, "String encoding failed");
    }

    function test_encodeBytes() public pure {
        bytes memory value = "Hello";
        bytes memory encoded = abi.encode(value);
        bytes memory expected = bytes.concat(
            hex"0000000000000000000000000000000000000000000000000000000000000020", // offset
            hex"0000000000000000000000000000000000000000000000000000000000000005", // length
            bytes32(bytes(value))
        ); // "Hello" right padded
        assertEq(encoded, expected, "Bytes encoding failed");
    }

    function test_encodeBytes32() public pure {
        bytes32 value = hex"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        bytes memory encoded = abi.encode(value);
        bytes memory expected = hex"1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        assertEq(encoded, expected, "Bytes32 encoding failed");
    }

    function test_encodeArray() public pure {
        uint256[] memory values = new uint256[](3);
        values[0] = 1;
        values[1] = 2;
        values[2] = 3;
        bytes memory encoded = abi.encode(values);
        bytes memory expected = hex"0000000000000000000000000000000000000000000000000000000000000020"
            hex"0000000000000000000000000000000000000000000000000000000000000003" // array
                // length
            hex"0000000000000000000000000000000000000000000000000000000000000001" // element 1
            hex"0000000000000000000000000000000000000000000000000000000000000002" // element 2
            hex"0000000000000000000000000000000000000000000000000000000000000003"; // element 3
        assertEq(encoded, expected, "Array encoding failed");
    }

    function test_encodeStruct() public pure {
        Person memory person = Person({name: hex"11111111", nick: hex"22222222", age: 30});

        bytes memory encoded = abi.encode(person);

        bytes memory expected = hex"0000000000000000000000000000000000000000000000000000000000000020"
            hex"0000000000000000000000000000000000000000000000000000000000000060" // offset to 1st dynamic var
            hex"00000000000000000000000000000000000000000000000000000000000000a0" // offset to 2nd dynamyc var
            hex"000000000000000000000000000000000000000000000000000000000000001e" // age
            hex"0000000000000000000000000000000000000000000000000000000000000004" // name.len
            hex"1111111100000000000000000000000000000000000000000000000000000000" // name
            hex"0000000000000000000000000000000000000000000000000000000000000004" // nick.len
            hex"2222222200000000000000000000000000000000000000000000000000000000"; // nick

        assertEq(encoded, expected, "Struct encoding failed");
    }

    function test_encodeSwap() public pure {
        Tuple1 memory tuple1 = Tuple1({uintValue1: uint256(2), byteValue1: bytes(hex"111111"), uintValue2: uint256(3)});

        Tuple2 memory tuple2 = Tuple2({
            uintValue1: uint256(4),
            byteValue1: bytes(hex"222222"),
            byteValue2: bytes(hex"333333"),
            uintValue2: uint256(5)
        });

        bytes memory encoded = abi.encode(
            uint256(1), // uint256(1) argument: 1
            tuple1, // tuple(1) (2, 0x111111, 3)
            tuple2, // tuple(2) (4, 0x222222, 0x333333, 5)
            uint256(6) // uint256(2): 6
        );

        // swap(uint256,(uint256,bytes,uint256),(uint256,bytes,bytes,uint256),uint256)
        bytes memory expected = hex"0000000000000000000000000000000000000000000000000000000000000001" // uint256(1)
            hex"0000000000000000000000000000000000000000000000000000000000000080" // Tup(1) head -> offset to Tup(1)
                // tail
            hex"0000000000000000000000000000000000000000000000000000000000000120" // Tup(2) head -> offset to Tup(2)
                // tail
            hex"0000000000000000000000000000000000000000000000000000000000000006" // uint256(2)
            hex"0000000000000000000000000000000000000000000000000000000000000002" // Tup(1) tail -> uint256(1)
            hex"0000000000000000000000000000000000000000000000000000000000000060" // Tup(1) tail -> bytes(1) head ->
                // offset to bytes(1) tail, from Tup(1) tail start
            hex"0000000000000000000000000000000000000000000000000000000000000003" // Tup(1) tail -> uint256(2)
            hex"0000000000000000000000000000000000000000000000000000000000000003" // Tup(1) tail -> bytes tail ->
                // len(bytes)
            hex"1111110000000000000000000000000000000000000000000000000000000000" // Tup(1) tail -> bytes tail -> bytes
            hex"0000000000000000000000000000000000000000000000000000000000000004" // Tup(2) tail -> uint256(1)
            hex"0000000000000000000000000000000000000000000000000000000000000080" // Tup(2) tail -> bytes(1) head ->
                // offset to bytes(1) tail, from Tup(2) tail start
            hex"00000000000000000000000000000000000000000000000000000000000000c0" // Tup(2) tail -> bytes(2) head ->
                // offset to bytes(2) tail, from Tup(2) tail start
            hex"0000000000000000000000000000000000000000000000000000000000000005" // Tup(2) tail -> uint256(2)
            hex"0000000000000000000000000000000000000000000000000000000000000003" // Tup(2) tail -> bytes(1) tail ->
                // len(bytes(0x222222))
            hex"2222220000000000000000000000000000000000000000000000000000000000" // data
            hex"0000000000000000000000000000000000000000000000000000000000000003" // Tup(2) tail -> bytes(2) tail
                // len(bytes(0x222222))
            hex"3333330000000000000000000000000000000000000000000000000000000000"; // data

        assertEq(encoded, expected, "Swap function encoding failed");
    }
}
