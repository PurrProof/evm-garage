// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {BigIntLib, Bigint} from "../src/BigInt.sol";

contract BigIntTest is Test {
    using BigIntLib for Bigint;

    //function setUp() public {}

    function test_BigIntLib() public pure {
        Bigint memory x = BigIntLib.fromUint(7);
        Bigint memory y = BigIntLib.fromUint(type(uint256).max);
        Bigint memory z = x.add(y);
        Bigint memory k = z.add(z);
        assertEq(x.limb(0), 7);
        assertEq(y.limb(0), type(uint256).max);
        assertEq(z.limb(0), 6);
        assertEq(z.limb(1), 1);
        assertEq(k.limb(0), 12);
        assertEq(k.limb(1), 2);
    }
}
