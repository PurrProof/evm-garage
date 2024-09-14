// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CounterInitializable} from "../../src/CounterInitializable.sol";
import {CounterV2Initializable} from "../../src/CounterV2Initializable.sol";

contract MyBeaconProxyTest is Test {
    uint256 constant FIRST_INIT_NUM = 5;

    address public owner;
    address public alice;

    UpgradeableBeacon public beacon;

    BeaconProxy public proxy1;
    BeaconProxy public proxy2;

    CounterInitializable public counter1;
    CounterV2Initializable public counter2;

    function setUp() public {
        owner = makeAddr("Owner");
        alice = makeAddr("Alice");

        //proxy = new MyErc1967Proxy(address(counter), "");

        // deploy implementation v1
        counter1 = new CounterInitializable();

        // deploy implementation v2
        counter2 = new CounterV2Initializable();

        // deploy beacon
        beacon = new UpgradeableBeacon(address(counter1), owner);

        // deploy proxy 1
        bytes memory data1 = abi.encodeWithSignature("initialize(uint256)", FIRST_INIT_NUM);
        proxy1 = new BeaconProxy(address(beacon), data1);

        // deploy proxy 2
        proxy2 = new BeaconProxy(address(beacon), "");
    }

    function test_beaconSlot() public view {
        // beacon proxies contain beacon address in the immutable beacon variable, to save gas on reading it
        // AND, in ERC1967 beacon slot, to signal explorers about that's beacon proxy

        bytes32 beaconSlot = bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1);
        assertEq(beaconSlot, ERC1967Utils.BEACON_SLOT);

        // read beacon address from proxy1's beacon slot
        address storedBeacon1 = address(uint160(uint256(vm.load(address(proxy1), beaconSlot))));
        assertEq(storedBeacon1, address(beacon));

        // read beacon address from proxy2's beacon slot
        address storedBeacon2 = address(uint160(uint256(vm.load(address(proxy2), beaconSlot))));
        assertEq(storedBeacon2, address(beacon));
    }

    function test_BeaconProxy1_Initializability() public {
        // proxy initialization
        assertEq(CounterInitializable(address(proxy1)).number(), FIRST_INIT_NUM);

        // initializer can't be called twice
        vm.expectRevert(abi.encodeWithSignature("InvalidInitialization()"));
        CounterInitializable(address(proxy1)).initialize(8);
    }

    // not authorized user can't upgrade
    function test_Revert_BeaconUpgradeable_upgradeTo() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", alice));
        vm.prank(alice);
        beacon.upgradeTo(address(proxy2));
    }

    function test_upgradeability() public {
        // check whether proxies pointing to the current implementation
        assertEq(CounterInitializable(address(proxy1)).version(), 1);
        assertEq(CounterInitializable(address(proxy2)).version(), 1);

        // upgrade implementation
        vm.prank(owner);
        beacon.upgradeTo(address(counter2));

        // beacon is upgraded and proxies delegate to implementation V2 now
        assertEq(CounterV2Initializable(address(proxy1)).version(), 2);
        assertEq(CounterV2Initializable(address(proxy2)).version(), 2);

        // but proxies are not reinitialized yet
        assertEq(CounterV2Initializable(address(proxy1)).answer(), 0);
        assertEq(CounterV2Initializable(address(proxy1)).answer(), 0);

        // unfortunately, we should reinitialize them manually
        CounterV2Initializable(address(proxy1)).initializeV2();
        CounterV2Initializable(address(proxy2)).initializeV2();

        // proxies are reinitialized now
        assertEq(CounterV2Initializable(address(proxy1)).answer(), 42);
        assertEq(CounterV2Initializable(address(proxy1)).answer(), 42);

        // repeated reinitialization is impossible
        vm.expectRevert(abi.encodeWithSignature("InvalidInitialization()"));
        CounterV2Initializable(address(proxy1)).initializeV2();
        vm.expectRevert(abi.encodeWithSignature("InvalidInitialization()"));
        CounterV2Initializable(address(proxy2)).initializeV2();
    }
}
