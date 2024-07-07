// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DeploySanctionableTknScript} from "../script/DeploySanctionableTknScript.s.sol";
import {SanctionableTkn} from "../src/sanction/SanctionableTkn.sol";

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
        // only admin can add to the sanction list
        console.log("msg sender", msg.sender);
        vm.prank(msg.sender);
        token.addSanction(alice);
        uint256 transferAmount = 500;

        vm.startPrank(bob);
        // Approval cannot work
        vm.expectRevert("Sender / Recipient is in the sanction list");
        token.approve(alice, transferAmount);
        vm.stopPrank();
    }

    //Add Bob as the admin and add Alice to the sanction list
    function test_AddAdminAndSanction() public {
        vm.prank(msg.sender);
        token.addAdmin(bob);
        //bob is the admin and he will add alice to the sanction list
        vm.prank(bob);
        token.addSanction(alice);

        // Alice is in the sanction list
        assert(token.sanctionList(alice));
    }
}
