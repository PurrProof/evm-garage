// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";
import {MyErc1967Proxy} from "../../src/proxy/Erc1967Proxy.sol";

contract MyErc1967ProxyTest is Test {
    MyErc1967Proxy public proxy;
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        proxy = new MyErc1967Proxy(address(counter));
    }

    function test_implementation() public {
        bytes32 slot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

        address storedImpl = address(uint160(uint256(vm.load(address(proxy), slot))));
        emit log_address(storedImpl);

        assertEq(storedImpl, proxy.implementation());
        assertEq(storedImpl, address(counter));
    }
}
