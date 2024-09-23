// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public virtual {
        number = newNumber;
    }

    function increment() public virtual {
        ++number;
    }

    function version() public pure virtual returns (uint256 v) {
        return 1;
    }
}
