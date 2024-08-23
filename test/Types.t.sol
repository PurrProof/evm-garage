// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {stdError} from "forge-std/StdError.sol";
import {Test} from "forge-std/Test.sol";

contract TypesTest is Test {
    //function setUp() public {}

    // The expression type(int).min / (-1) is the only case where division causes an overflow.
    // In checked arithmetic mode, this will cause a failing assertion,
    // while in wrapping mode, the value will be type(int).min.

    function test_Overflow1() public {
        vm.expectRevert(stdError.arithmeticError);
        int8 res = type(int8).min / int8(-1);
    }

    function test_Overflow2() public {
        vm.expectRevert(stdError.arithmeticError);
        int8 res = type(int8).min * int8(-1);
    }

    function test_Unchecked() public pure {
        assertEq(type(int8).min, -128);
        unchecked {
            assertEq(type(int8).min / int8(-1), -128);
            assertEq(type(int8).min * int8(-1), -128);
        }
    }

    function test_Math() public pure {
        assertEq(type(int8).min, int8(-128));
    }

    function test_StringLiteral() public pure {
        string memory test =
            "\n\"'\\abc\
def\
1";
        assertEq(bytes(test).length, 11);
        test =
            "\
";
        assertEq(bytes(test).length, 0);
    }
}
