// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";
import {CounterV2} from "../../src/CounterV2.sol";
import {MyTransparentUpgradeableProxy} from "../../src/proxy/TransparentUpgradeableProxy.sol";

contract MyTransparentUpgradeableProxyTest is Test {
    MyTransparentUpgradeableProxy public proxy;
    Counter public counter;
    CounterV2 public counter2;
    ProxyAdmin public proxyAdmin;
    address public owner;

    function setUp() public {
        owner = makeAddr("Owner");
        counter = new Counter();
        counter2 = new CounterV2();
        vm.prank(owner);
        proxy = new MyTransparentUpgradeableProxy(address(counter), owner, "");

        // read implementation address from proxy's slot
        address proxyAdminAddr = address(uint160(uint256(vm.load(address(proxy), ERC1967Utils.ADMIN_SLOT))));
        proxyAdmin = ProxyAdmin(proxyAdminAddr);
    }

    function test_admin() public {
        emit log_address(owner);
        assertEq(owner, proxyAdmin.owner());
    }

    function testFuzz_SetNumber(uint256 x) public {
        Counter(address(proxy)).setNumber(x);
        assertEq(Counter(address(proxy)).number(), x);
    }

    function testFuzz_Upgrade_SetNumber(uint256 x) public {
        address storedImpl = address(uint160(uint256(vm.load(address(proxy), ERC1967Utils.IMPLEMENTATION_SLOT))));
        assertEq(storedImpl, address(counter));

        if (storedImpl != address(counter2)) {
            vm.prank(owner);
            proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(address(proxy)), address(counter2), "");
        }

        CounterV2(address(proxy)).setNumberV2(x);
        assertEq(CounterV2(address(proxy)).number(), x);
    }

    function test_implementation() public view {
        // read implementation address from proxy's slot
        address storedImpl = address(uint160(uint256(vm.load(address(proxy), ERC1967Utils.IMPLEMENTATION_SLOT))));
        assertEq(storedImpl, address(counter));
    }
}
