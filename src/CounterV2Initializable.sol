// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract CounterV2Initializable is Initializable {
    uint256 public number;
    uint256 public answer;

    constructor() {
        _disableInitializers();
    }

    function initializeV2() external reinitializer(2) {
        answer = 42;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        ++number;
    }

    function version() public pure returns (uint256 v) {
        return 2;
    }
}
