// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DeploySanctionableTknScript} from "../script/DeploySanctionableTknScript.sol";
import {SanctionableTkn} from "../src/sanction/SanctionableTkn.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract SanctionableTknTest is Test {
    SanctionableTkn token;
    DeploySanctionableTknScript deployer;
    address bob;
    address alice;
    uint256 BOB_STARTING_AMOUNT = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places

    function setUp() public {
        deployer = new DeploySanctionableTknScript();
        token = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        vm.prank(msg.sender);
        token.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function test_CreateToken() public view {
        assertEq(token.name(), "TestToken");
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_BobBalance() public view {
        assertEq(token.balanceOf(bob), BOB_STARTING_AMOUNT);
    }

    function test_DeployerBalance() public view {
        assertEq(
            token.balanceOf(address(msg.sender)),
            INITIAL_SUPPLY - BOB_STARTING_AMOUNT
        );
    }

    function test_TransferFromBobToAlice() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        token.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);
        assertEq(token.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
    }

    // Test if the sanction list works
    function test_ApproveIncreaseDecrease() public {
        uint256 initialAllowance = 100 ether;
        uint256 increaseAmount = 50 ether;
        uint256 decreaseAmount = 30 ether;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        token.approve(alice, initialAllowance);
        assertEq(token.allowance(bob, alice), initialAllowance);

        // Bob increases the allowance
        vm.prank(bob);
        token.approve(alice, initialAllowance + increaseAmount);
        assertEq(
            token.allowance(bob, alice),
            initialAllowance + increaseAmount
        );

        // Bob decreases the allowance
        vm.prank(bob);
        token.approve(
            alice,
            initialAllowance + increaseAmount - decreaseAmount
        );
        assertEq(
            token.allowance(bob, alice),
            initialAllowance + increaseAmount - decreaseAmount
        );
    }

    // Alice is in the sanction list
    function test_SanctionListApproval() public {
        token.addSanction(alice);
        uint256 transferAmount = 500;

        vm.startPrank(bob);
        // Approval cannot work
        vm.expectRevert("Sender / Recipient is in the sanction list");
        token.approve(alice, transferAmount);
        vm.stopPrank();

        // Alice tries to transfer tokens to Bob
        // vm.prank(bob);
        // token.transfer(alice, transferAmount);
    }
}
