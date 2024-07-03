// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DeployerGodTokenScript} from "../script/DeployerGodToken.sol";
import {GodToken} from "../src/godMode/GodToken.sol";

contract GodTokenTest is Test {
    GodToken token;
    DeployerGodTokenScript deployer;
    address god;
    address bob;
    address alice;

    function setUp() public {
        god = makeAddr("god");
        deployer = new DeployerGodTokenScript();
        token = deployer.run(god);

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        vm.prank(msg.sender);
        token.transfer(bob, 100 ether);
    }

    function test_CreateToken() public view {
        assertEq(token.name(), "GodToken");
        assertEq(token.totalSupply(), 1_000_000 ether);
    }

    function test_GodTransferFrom() public {
        uint256 transferAmount = 50 ether;
        //spender is God, no need for approval
        vm.prank(god);
        token.transferFrom(bob, alice, transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(bob), 50 ether);
    }

    function test_NormalTransferFrom() public {
        uint256 allowance = 10 ether;
        uint256 transferAmount = 5 ether;
        vm.prank(bob);
        token.approve(alice, allowance);
        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
    }
}
