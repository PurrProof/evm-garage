// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract CounterInitializable is Initializable {
    uint256 public number;

    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 num) external initializer {
        number = num;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        ++number;
    }

    function version() public pure returns (uint256 v) {
        return 1;
    }
}
