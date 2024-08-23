// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MyErc1967Proxy} from "../../src/proxy/Erc1967Proxy.sol";

contract MyErc1967ProxyTest is Test {
    MyErc1967Proxy public proxy;

    function setUp() public {
        proxy = new MyErc1967Proxy();
    }
}
