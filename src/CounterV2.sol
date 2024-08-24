// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CounterV2 {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function setNumberV2(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        ++number;
    }
}
