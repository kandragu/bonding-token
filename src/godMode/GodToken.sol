// //SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;
import {ERC1363, ERC20, IERC20} from "../base/ERC1363.sol";
import {console} from "forge-std/Test.sol";

contract GodToken is ERC1363 {
    address private god;

    constructor(uint256 INITIAL_SUPPLY, address _god) ERC20("GodToken", "GOD") {
        god = _god;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal override {
        console.log("God =", god);
        if (spender == god) {
            console.log("God is spending so no allowance");
            return;
        } else {
            console.log("Spender is not God");
            super._spendAllowance(owner, spender, value);
        }
    }
}
