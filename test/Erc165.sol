// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MyErc165, IMyErc165} from "../src/Erc165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMyTest {
    function test() external;
    function test1() external returns (bool something);
}

contract Erc165Test is Test {
    MyErc165 public erc165;

    function setUp() public {
        erc165 = new MyErc165();
    }

    function test_interfaceIdCalc() public pure {
        // XOR of ABI functions
        bytes4 calculatedInterfaceId = IMyTest.test.selector ^ IMyTest.test1.selector;
        assertEq(type(IMyTest).interfaceId, calculatedInterfaceId);
        assertEq(type(IERC165).interfaceId, IERC165.supportsInterface.selector);
    }

    function test_IERC165_selector() public pure {
        assertEq(type(IERC165).interfaceId, IERC165.supportsInterface.selector);
    }

    // https://eips.ethereum.org/EIPS/eip-165#how-to-detect-if-a-contract-implements-erc-165
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/utils/introspection/ERC165Checker.sol#L108
    function test_ERC165_Detect() public view {
        // prepare call
        bytes memory encodedParams = abi.encodeCall(IERC165.supportsInterface, (IERC165.supportsInterface.selector));

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        address account = address(erc165);
        assembly {
            // gas limit is 30000 by ERC165
            // add(encodedParams, 0x20) -> argOffset; encodedParams is memory pointer, 0x20 is offset to data (first
            // 0x20 bytes is length)
            // mload(encodedParams) loads first word from memory pointer, i.e. bytes variable length
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }
        assertEq(success, true);
        assertEq(returnSize, 0x20);
        assertEq(returnValue, 0x01);
    }

    function test_ERC165_Detect_Unsupported() public view {
        // prepare call
        bytes4 unsupported = 0xffffffff;
        bytes memory encodedParams = abi.encodeCall(IERC165.supportsInterface, unsupported);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        address account = address(erc165);
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }
        assertEq(success, true);
        assertEq(returnSize, 0x20);
        assertEq(returnValue, 0x00);
    }

    function test_ERC165_supportsInterface() public view {
        bool result = erc165.supportsInterface(IERC165.supportsInterface.selector);
        assertEq(result, true);

        result = erc165.supportsInterface(type(IMyErc165).interfaceId);
        assertEq(result, true);
    }
}
