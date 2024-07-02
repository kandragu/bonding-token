// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20} from "./ERC1363.sol";

contract SanctionableTkn is ERC1363 {
    constructor(uint256 INITIAL_SUPPLY) ERC20("TestToken", "TST") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
