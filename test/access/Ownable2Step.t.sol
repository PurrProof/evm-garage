// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract CounterOwnable2Step is Counter, Ownable2Step {
    constructor(address initialOwner) Ownable(initialOwner) {
        this;
    }

    function setNumber(uint256 num) public override onlyOwner {
        super.setNumber(num);
    }

    function internalCheckOwner() public view returns (bool res) {
        _checkOwner();
        return true;
    }
}

contract CounterOwnable2StepTest is Test {
    CounterOwnable2Step public counter;
    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = makeAddr("Owner");
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        counter = new CounterOwnable2Step(owner);
    }

    function test_owner() public view {
        assertEq(counter.owner(), owner);
    }

    function test_setNumber() public {
        vm.startPrank(owner);
        counter.setNumber(42);
        assertEq(counter.number(), 42);
    }

    function test_internalCheckOwner() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        counter.internalCheckOwner();
        vm.prank(owner);
        assertEq(counter.internalCheckOwner(), true);
    }

    function test_onlyOwnerModifier() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        counter.setNumber(256);
    }

    function test_transferOwnership_by_notOwner() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        counter.transferOwnership(bob);
    }

    function test_transferOwnership_to_ZeroAddress() public {
        // vm.expectRevert(abi.encodeWithSignature("OwnableInvalidOwner(address)", address(bytes20(0))));
        // there is not very logical behaviour, but still:
        vm.expectEmit(true, true, false, false, address(counter));
        emit Ownable2Step.OwnershipTransferStarted(counter.owner(), address(bytes20(0)));
        vm.prank(owner);
        counter.transferOwnership(address(bytes20(0)));
        assertEq(counter.pendingOwner(), address(bytes20(0)));
    }

    function test_transferOwnership() public {
        // start transferring ownership to Bob
        vm.expectEmit(true, true, false, false, address(counter));
        emit Ownable2Step.OwnershipTransferStarted(counter.owner(), bob);
        vm.prank(owner);
        counter.transferOwnership(bob);
        assertEq(counter.pendingOwner(), bob);

        // Alice can't accept ownership
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        counter.acceptOwnership();

        // Bob accepts ownership
        vm.expectEmit(true, true, false, false, address(counter));
        emit Ownable.OwnershipTransferred(owner, bob);
        vm.prank(bob);
        counter.acceptOwnership();
        assertEq(counter.owner(), bob);

        // Bob can set number
        vm.prank(bob);
        counter.setNumber(84);
        assertEq(counter.number(), 84);
    }

    function test_renounceOwnership() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        counter.renounceOwnership();

        vm.expectEmit(true, true, false, false, address(counter));
        emit Ownable.OwnershipTransferred(owner, address(bytes20(0)));
        vm.prank(owner);
        counter.renounceOwnership();

        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", owner));
        vm.prank(owner);
        counter.setNumber(1);
    }
}
