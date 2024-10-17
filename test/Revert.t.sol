// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";

contract Counter {
    // Custom Errors
    error CustomError(uint256);
    error CustomErrorNoParams();
    error WrongNumber(uint256 number);

    // Function that reverts with a custom error with parameters
    function revertWithCustomErrorZero() public pure {
        revert CustomError(0);
    }

    // Function that reverts with a string message
    function revertWithStringRevert() public pure {
        revert("error message");
    }

    // Function that reverts without a message
    function revertWithNoMessage() public pure {
        revert();
    }

    // Function that reverts with a four-character message
    function revertWithFourCharMessage() public pure {
        revert("AAAA");
    }

    // Function that reverts with a custom error without parameters
    function revertWithCustomErrorNoParams() public pure {
        revert CustomErrorNoParams();
    }

    // Function that reverts with a custom error and dynamic parameters
    function revertWithCustomErrorParams(uint256 a, uint256 b) public pure {
        revert CustomError(a + b);
    }

    // Function that reverts with another custom error
    function revertWithWrongNumber(uint256 number) public pure {
        revert WrongNumber(number);
    }
}

contract RevertTest is Test {
    Counter internal counter;

    function setUp() public {
        // Deploy the Counter
        counter = new Counter();
    }

    // Test with expectRevert() without parameters (any revert)
    function testExpectAnyRevert() public {
        vm.expectRevert();
        counter.revertWithCustomErrorZero();
    }

    // Test with expectRevert(bytes) (exact match of revert data)
    function testExpectRevertExactData() public {
        vm.expectRevert(abi.encodeWithSelector(Counter.CustomError.selector, uint256(0)));
        counter.revertWithCustomErrorZero();
    }

    // Test with expectPartialRevert(bytes4) (partial match on selector)
    function testExpectPartialRevert() public {
        vm.expectPartialRevert(Counter.CustomError.selector);
        counter.revertWithCustomErrorZero();
    }

    // Test with expectRevert(string) (string message)
    function testExpectRevertString() public {
        vm.expectRevert("error message");
        counter.revertWithStringRevert();
    }

    // Test with expectRevert(bytes("")) (revert without message)
    function testExpectRevertNoMessage() public {
        vm.expectRevert(bytes(""));
        counter.revertWithNoMessage();
    }

    // Test with expectRevert(bytes("AAAA")) (four-character message)
    function testExpectRevertFourCharMessage() public {
        vm.expectRevert(bytes("AAAA"));
        counter.revertWithFourCharMessage();
    }

    // Test with expectRevert using custom error without parameters
    function testExpectRevertCustomErrorNoParams() public {
        vm.expectRevert(Counter.CustomErrorNoParams.selector);
        counter.revertWithCustomErrorNoParams();
    }

    // Test with expectRevert using custom error with parameters
    function testExpectRevertCustomErrorWithParams() public {
        vm.expectRevert(abi.encodeWithSelector(Counter.CustomError.selector, uint256(3)));
        counter.revertWithCustomErrorParams(1, 2);
    }

    // Test with multiple expectRevert checks in a single test
    function testMultipleExpectReverts() public {
        vm.expectRevert("error message");
        counter.revertWithStringRevert();

        vm.expectPartialRevert(Counter.CustomError.selector);
        counter.revertWithCustomErrorZero();

        vm.expectRevert(abi.encodeWithSelector(Counter.CustomError.selector, 0));
        counter.revertWithCustomErrorZero();

        vm.expectPartialRevert(Counter.WrongNumber.selector);
        counter.revertWithWrongNumber(42);
    }

    // Test with expectRevert and low-level call (note the gotcha)
    function testLowLevelCallRevert() public {
        vm.expectRevert("low-level error");
        (bool success,) = address(counter).call(abi.encodeWithSignature("nonExistentFunction()"));
        assertTrue(!success, "Expected call to fail");
    }
}
