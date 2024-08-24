// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MyTransparentUpgradeableProxy is TransparentUpgradeableProxy {
    constructor(
        address logic,
        address initOwner,
        bytes memory data
    )
        TransparentUpgradeableProxy(logic, initOwner, data)
    {}
}
