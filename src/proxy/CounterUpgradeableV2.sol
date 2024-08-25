// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {CounterV2} from "../CounterV2.sol";

contract CounterUpgradeableV2 is CounterV2, UUPSUpgradeable, OwnableUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initializeV2(address _initOwner) external reinitializer(2) {
        __Ownable_init(_initOwner);
    }

    function _authorizeUpgrade(address newImpl) internal view override onlyOwner {
        newImpl;
    }
}
