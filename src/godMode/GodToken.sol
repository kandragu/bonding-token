// //SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {ERC1363, ERC20, IERC20} from "../base/ERC1363.sol";
import {console} from "forge-std/Test.sol";

// @title GodToken
// @author K Rahunandan
// @notice This contract is used to create a token with God mode
// @dev God mode is used to bypass the allowance check
contract GodToken is ERC1363 {
    address private god;

    // @param INITIAL_SUPPLY The initial supply of the token
    // @param _god The address of the god
    constructor(uint256 INITIAL_SUPPLY, address _god) ERC20("GodToken", "GOD") {
        god = _god;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // @notice for god address no need to check the allowance
    // @dev override the _spendAllowance function to bypass the allowance check
    // for god address
    function _spendAllowance(address owner, address spender, uint256 value) internal override {
        if (spender == god) {
            return;
        } else {
            super._spendAllowance(owner, spender, value);
        }
    }
}
