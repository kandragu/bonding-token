// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {EscrowTimeLock} from "../src/Escrow/EscrowTimeLock.sol";
import {MockERC20} from "../src/mocks/mockERC20.sol";
import {DeployEscrowTimeLock} from "../script/DeployEscrowTimeLock.s.sol";

contract EscrowTimeLockTest is Test {
    EscrowTimeLock escrow;
    DeployEscrowTimeLock deployer;
    uint256 public constant DAYS = 259200;
    address seller;
    address buyer;
    MockERC20 token;

    function setUp() public {
        deployer = new DeployEscrowTimeLock();
        escrow = deployer.run();
        token = new MockERC20();
        token.mint(address(escrow), 1000);
    }

    function testCreateEscrow() public {
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");

        uint256 amount = 100;
        uint256 unlockTime = block.timestamp + DAYS;

        token.approve(address(escrow), amount);
        escrow.createEscrow(seller, address(token), amount, unlockTime);
        vm.prank(seller);
        EscrowTimeLock.EscrowInfo memory sellerTokenInfo = escrow.getTokens();
        ERC20 sellerToken = ERC20(sellerTokenInfo.token);

        console.log("seller token", sellerTokenInfo.buyer, sellerToken.name());
        // console.log("")

        // console.log(escrow.sellers(seller));
        // EscrowTimeLock.EscrowInfo memory escrowInfo = escrow.sellers(seller);

        // escrowInfo.buyer = address(this);
        // escrowInfo.seller = seller;
        // escrowInfo.token = token;
        // escrowInfo.amount = amount;
        // escrowInfo.unlockTime = unlockTime;
        // assertEq(escrow.sellers(seller), escrowInfo);
    }
}
