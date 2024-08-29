// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

interface IMyErc165 {
    function foo() external view;
}

contract MyErc165 is ERC165, IMyErc165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool success) {
        return interfaceId == type(IMyErc165).interfaceId || super.supportsInterface(interfaceId);
    }

    function foo() external view {
        this;
    }
}
