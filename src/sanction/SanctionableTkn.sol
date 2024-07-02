// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20, IERC20} from "./ERC1363.sol";

contract SanctionableTkn is ERC1363 {
    mapping(address => bool) public sanctionList;

    constructor(uint256 INITIAL_SUPPLY) ERC20("TestToken", "TST") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function addSanction(address _address) public {
        sanctionList[_address] = true;
    }

    function removeSanction(address _address) public {
        sanctionList[_address] = false;
    }

    // modifier to check if the sender is not in the sanction list
    modifier isNotSanctioned(address recipient) {
        require(
            !sanctionList[msg.sender] && !sanctionList[recipient],
            "Sender / Recipient is in the sanction list"
        );
        _;
    }

    //override the transfer function to check if the sender is not in the sanction list
    function transfer(
        address recipient,
        uint256 amount
    ) public override(ERC20, IERC20) isNotSanctioned(recipient) returns (bool) {
        return super.transfer(recipient, amount);
    }

    //override the transferFrom function to check if the sender is not in the sanction list
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20, IERC20) isNotSanctioned(recipient) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    //override the approve function to check if the sender is not in the sanction list
    function approve(
        address spender,
        uint256 amount
    ) public override(ERC20, IERC20) isNotSanctioned(spender) returns (bool) {
        return super.approve(spender, amount);
    }
}
