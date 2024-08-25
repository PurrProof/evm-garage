// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Counter} from "../Counter.sol";

contract CounterUpgradeable is Counter, UUPSUpgradeable, OwnableUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initOwner) external initializer {
        __Ownable_init(_initOwner);
    }

    function _authorizeUpgrade(address newImpl) internal view override onlyOwner {
        newImpl;
    }
}
