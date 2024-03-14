// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BigInt, bigint} from "../src/BigInt.sol";

contract BigIntTest is Test {
    using BigInt for bigint;

    function setUp() public {}

    function test() public pure {
        bigint memory x = BigInt.fromUint(7);
        bigint memory y = BigInt.fromUint(type(uint).max);
        bigint memory z = x.add(y);
        bigint memory k = z.add(z);
        assertEq(x.limb(0), 7);
        assertEq(y.limb(0), type(uint).max);
        assertEq(z.limb(0), 6);
        assertEq(z.limb(1), 1);
        assertEq(k.limb(0), 12);
        assertEq(k.limb(1), 2);
    }
}
