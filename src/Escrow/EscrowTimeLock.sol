// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20, IERC20} from "../base/ERC1363.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {console} from "forge-std/Test.sol";

contract EscrowTimeLock {
    using SafeERC20 for IERC20;
    struct EscrowInfo {
        address buyer;
        address seller;
        address token;
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => EscrowInfo) public sellers;

    function createEscrow(
        address _seller,
        address _token,
        uint256 _amount,
        uint256 _unlockTime
    ) public {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        sellers[_seller] = EscrowInfo(
            msg.sender,
            _seller,
            _token,
            _amount,
            _unlockTime
        );
    }

    function releaseEscrow() public {
        EscrowInfo memory escrow = sellers[msg.sender];
        require(escrow.unlockTime <= block.timestamp, "Escrow is still locked");
        IERC20(escrow.token).safeTransfer(escrow.seller, escrow.amount);
    }

    function getTokens() external view returns (EscrowInfo memory info) {
        info = sellers[msg.sender];
    }
}
