// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20} from "./ERC1363.sol";

contract SanctionableTkn is ERC1363 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}
