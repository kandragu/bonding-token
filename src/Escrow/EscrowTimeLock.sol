// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363, ERC20, IERC20} from "../base/ERC1363.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {console} from "forge-std/Test.sol";

/// @title Escrow ECR20 token in timelock protocol
/// @author K Rahunandan
/// @notice This contract is used to escrow ERC20 tokens in a time lock protocol
/// @dev DAYS is three days, should change according to the needs
contract EscrowTimeLock {
    using SafeERC20 for IERC20;

    struct EscrowInfo {
        address buyer;
        address seller;
        address token;
        uint256 amount;
        uint256 unlockTime;
    }

    // Mapping of seller to depositsIds
    mapping(address => uint256[]) public sellerDeposits;
    // Mapping of seller to depositId to EscrowInfo
    mapping(address => mapping(uint256 => EscrowInfo)) public sellerEscroInfo;

    // Events for EscrowTimeLock
    event EscrowDeleted(address indexed seller, uint256 depositId);
    event CreateEscrow(address _buyer, address _seller, address _token, uint256 _amount, uint256 _unlockTime);

    // @notice Create an escrow for the seller
    // @param _seller The address of the seller who will withdraw the tokens after the unlock time
    // @param _token The address of the token to be escrowed
    // @param _amount The amount of tokens to be escrowed
    function createEscrow(address _seller, address _token, uint256 _amount, uint256 _unlockTime) public {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 timestamp = block.timestamp;
        sellerDeposits[_seller].push(timestamp);
        sellerEscroInfo[_seller][timestamp] = EscrowInfo(msg.sender, _seller, _token, _amount, _unlockTime);
        emit CreateEscrow(msg.sender, _seller, _token, _amount, _unlockTime);
    }

    // @notice Release the escrowed tokens to the seller
    // and delete the escrow info
    // @param depositId The id of the deposit
    function releaseEscrow(uint256 depositId) public {
        EscrowInfo memory escrowInfo = sellerEscroInfo[msg.sender][depositId];
        console.log("depositId", depositId);
        console.log("[releaseEscrow]", escrowInfo.seller, escrowInfo.amount);
        require(escrowInfo.unlockTime <= block.timestamp, "Escrow is still locked");
        IERC20(escrowInfo.token).safeTransfer(escrowInfo.seller, escrowInfo.amount);

        deleteEscrowInfo(escrowInfo.seller, depositId);
    }

    function getTokens(uint256 depositId) external view returns (EscrowInfo memory info) {
        info = sellerEscroInfo[msg.sender][depositId];
    }

    function getAllDeposits() external view returns (uint256[] memory deposits) {
        require(sellerDeposits[msg.sender].length > 0, "No deposits found");
        deposits = sellerDeposits[msg.sender];
    }

    // @notice Internal utiitly to delete the escrow info from the mappings
    function deleteEscrowInfo(address _seller, uint256 _depositId) internal {
        // Delete from sellerEscroInfo
        delete sellerEscroInfo[_seller][_depositId];

        // Delete from sellerDeposits
        uint256[] storage deposits = sellerDeposits[_seller];
        uint256 length = deposits.length;

        for (uint256 i = 0; i < length; i++) {
            if (deposits[i] == _depositId) {
                if (i == length - 1) {
                    deposits.pop();
                } else {
                    // Replace with the last element and then pop
                    deposits[i] = deposits[length - 1];
                    deposits.pop();
                }
                // Break here as we've found and removed the element
                break;
            }
        }

        emit EscrowDeleted(_seller, _depositId);
    }
}
