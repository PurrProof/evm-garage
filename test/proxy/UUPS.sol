// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";
import {CounterV2} from "../../src/CounterV2.sol";
import {CounterUpgradeable} from "../../src/proxy/CounterUpgradeable.sol";
import {CounterUpgradeableV2} from "../../src/proxy/CounterUpgradeableV2.sol";
import {MyErc1967Proxy} from "../../src/proxy/Erc1967Proxy.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyUUPSProxyTest is Test {
    MyErc1967Proxy public proxy;
    CounterUpgradeable public counter;
    CounterUpgradeableV2 public counter2;
    address public owner;
    address public alice;

    function setUp() public {
        owner = makeAddr("Owner");
        alice = makeAddr("Alice");

        // deploy implementation 1
        counter = new CounterUpgradeable();

        // deploy implementation 2
        counter2 = new CounterUpgradeableV2();

        // deploy proxy with counter V1 as implementation
        proxy = new MyErc1967Proxy(address(counter), abi.encodeWithSignature("initialize(address)", owner));
        //vm.stopBroadcast();
    }

    function test_CounterUpgradeable() public view {
        assertEq(OwnableUpgradeable(address(proxy)).owner(), owner);
        assertEq(Counter(address(proxy)).version(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        Counter(address(proxy)).setNumber(x);
        assertEq(Counter(address(proxy)).number(), x);
    }

    function test_CounterUpgradeableV2_owner() public view {
        // second implementation is not initialized, has no state
        // should not be called directly
        assertEq(counter2.owner(), address(0x0000000000000000000000000000000000000000));
    }

    // not authorized user can't upgrade
    function test_Revert_CounterUpgradeableV2_upgrade() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(
            address(counter2), abi.encodeWithSignature("initializeV2(address)", owner)
        );
    }

    function test_CounterUpgradeableV2() public {
        vm.startPrank(owner);
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(
            address(counter2), abi.encodeWithSignature("initializeV2(address)", owner)
        );
        assertEq(OwnableUpgradeable(address(proxy)).owner(), owner);
        assertEq(CounterV2(address(proxy)).version(), 2);
    }
}
