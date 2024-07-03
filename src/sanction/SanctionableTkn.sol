// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20, IERC20} from "./ERC1363.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SanctionableTkn is ERC1363, AccessControl {
    mapping(address => bool) public sanctionList;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(uint256 INITIAL_SUPPLY) ERC20("TestToken", "TST") {
        // Grant the minter role to a specified account
        _grantRole(ADMIN_ROLE, msg.sender);
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // function addAdmin(address _address) public {
    //     grantRole(ADMIN_ROLE, _address);
    // }

    function addSanction(address _address) public onlyRole(ADMIN_ROLE) {
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1363, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
