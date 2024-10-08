// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract MyErc1967Proxy is ERC1967Proxy {
    constructor(address impl, bytes memory data) ERC1967Proxy(impl, data) {}

    function implementation() public view returns (address impl) {
        return ERC1967Utils.getImplementation();
    }
}
