// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";

contract Erc1169MinProxyAkaClone is Test {
    Counter public implementation;
    uint256 constant START = 42;
    bytes32 constant SALT = bytes32(uint256(0x12345));

    function setUp() public {
        implementation = new Counter();
    }

    function test_clone() public {
        address clone1Addr = Clones.clone(address(implementation));
        Counter clone1 = Counter(clone1Addr);
        // we can initialize clone
        clone1.setNumber(START);

        clone1.increment();
        assertEq(clone1.number(), START + 1);
    }

    function test_cloneDeterministic() public {
        address predictedAddress = Clones.predictDeterministicAddress(address(implementation), SALT);
        address clone2Addr = Clones.cloneDeterministic(address(implementation), SALT);

        // check address prediction
        assertEq(predictedAddress, clone2Addr);

        Counter clone1 = Counter(clone2Addr);
        // we can initialize clone
        clone1.setNumber(START);

        clone1.increment();
        assertEq(clone1.number(), START + 1);
    }
}
