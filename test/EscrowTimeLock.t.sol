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
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");

        deployer = new DeployEscrowTimeLock();
        escrow = deployer.run();
        token = new MockERC20();
        token.mint(address(buyer), 100000);
        deposit(buyer, seller, 100);
    }

    function deposit(address _buyer, address _seller, uint256 amount) internal {
        // This for the block.timestamp to advance by 1 hr
        uint256 secondsToSkip = 3600; // 1 hour
        skip(secondsToSkip);

        // buyer deposit
        uint256 unlockTime = block.timestamp + DAYS;
        vm.startPrank(_buyer);
        token.approve(address(escrow), amount);
        escrow.createEscrow(_seller, address(token), amount, unlockTime);
        vm.stopPrank();
    }

    function testCreateEscrow() public {
        uint256 amount = 100;
        vm.startPrank(seller);
        uint256[] memory depositIds = escrow.getAllDeposits();

        EscrowTimeLock.EscrowInfo memory sellerTokenInfo = escrow.getTokens(
            depositIds[0]
        );
        vm.stopPrank();
        ERC20 sellerToken = ERC20(sellerTokenInfo.token);
        assertEq(sellerToken.name(), token.name());
        assertEq(sellerTokenInfo.buyer, address(buyer));
        assertEq(sellerTokenInfo.amount, amount);
        vm.stopPrank();
    }

    function test_releaseEscrow() external {
        vm.startPrank(seller);
        uint256[] memory depositIds = escrow.getAllDeposits();

        uint256 tokenBalanceBefore = token.balanceOf(seller);

        // Move the timestamp forward by 3 days (259200 seconds)
        vm.warp(block.timestamp + DAYS);

        escrow.releaseEscrow(depositIds[0]);

        console.log(
            "seller token balance",
            tokenBalanceBefore,
            token.balanceOf(seller)
        );

        vm.expectRevert("No deposits found");
        depositIds = escrow.getAllDeposits();
        vm.stopPrank();
    }

    function test_releaseEscrowStillLocked() external {
        vm.startPrank(seller);
        uint256[] memory depositIds = escrow.getAllDeposits();

        // Move the timestamp forward by 3 days but a second ago
        vm.warp(block.timestamp + DAYS - 1);

        vm.expectRevert("Escrow is still locked");
        escrow.releaseEscrow(depositIds[0]);
        vm.stopPrank();
    }

    function test_releaseMultipleEscrow() external {
        deposit(buyer, seller, 1000);

        vm.startPrank(seller);
        uint256[] memory depositIds = escrow.getAllDeposits();
        console.log("depositIds length", depositIds.length);
        uint256 depositId1 = depositIds[0];
        uint256 depositId2 = depositIds[1];
        console.log("deposit ids", depositId1, depositId2);

        uint256 tokenBalanceBefore = token.balanceOf(seller);

        // Move the timestamp forward by 3 days (259200 seconds)
        vm.warp(block.timestamp + DAYS);

        escrow.releaseEscrow(depositId1);
        escrow.releaseEscrow(depositId2);

        console.log(
            "seller token balance",
            tokenBalanceBefore,
            token.balanceOf(seller)
        );

        vm.expectRevert("No deposits found");
        depositIds = escrow.getAllDeposits();
        // console.log("depositIds", depositIds[0]);
        vm.stopPrank();
    }
}
