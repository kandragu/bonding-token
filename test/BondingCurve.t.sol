// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BondingCurve} from "../src/bondingCurveToken/BondingCurve.sol";
import {BondingCurveScript} from "../script/DeployBondingCurve.sol";

contract BondingCurveTest is Test {
    BondingCurveScript deployer;
    BondingCurve bondingCurveToken;
    address payable bob;
    address payable alice;
    address payable joy;

    function setUp() public {
        deployer = new BondingCurveScript();
        bondingCurveToken = deployer.run();

        bob = payable(makeAddr("bob"));
        alice = payable(makeAddr("alice"));
        joy = payable(makeAddr("joy"));

        bob.transfer(10 ether);
        alice.transfer(10 ether);
        joy.transfer(10 ether);
    }

    function test_TokenSupply() public view {
        assertEq(bondingCurveToken.name(), "Bonding Token");
        assertEq(bondingCurveToken.totalSupply(), 1);
        assertEq(bondingCurveToken.poolBalance(), 1 wei);
        assertEq(address(bondingCurveToken).balance, 1 wei);
    }

    function test_buy() public {
        vm.prank(msg.sender);
        bondingCurveToken.setGasPrice(77825 gwei);
        uint256 gasPrice = 10 gwei;
        vm.txGasPrice(gasPrice);
        uint256 gasStart = gasleft();
        bool buyResponse = bondingCurveToken.buy{value: 1 ether}();
        uint256 gasEnd = gasleft();
        assertEq(buyResponse, true);
        assertEq(bondingCurveToken.balanceOf(address(this)), 999981 wei);
        assertEq(bondingCurveToken.poolBalance(), 1000000000000000001 wei);
        // console.log("gasUsed", (gasStart - gasEnd) * tx.gasprice);
        // console.log("gas used", (gasStart - gasEnd));
    }

    function test_calculatePurchaseReturn() public view {
        uint256 amtToken = bondingCurveToken.calculatePurchaseReturn(
            1,
            1,
            1000000,
            1
        );
        assertEq(amtToken, 1);
        // console.log("tokenPurchase", amtToken);
    }

    function test_calculateSaleReturn() public view {
        uint256 amtReturn = bondingCurveToken.calculateSaleReturn(
            1,
            1,
            1000000,
            1
        );
        console.log("tokenSale", amtReturn);
    }

    function test_sell() public {
        uint256 ethIntialBalance = address(this).balance;
        bondingCurveToken.buy{value: 1 ether}();
        uint256 tokenBalance = bondingCurveToken.balanceOf(address(this));
        console.log("tokenBalance", tokenBalance);
        bool sellResponse = bondingCurveToken.sell(tokenBalance);
        assertEq(sellResponse, true);
        assertEq(bondingCurveToken.balanceOf(address(this)), 0);
        assertApproxEqRel(ethIntialBalance, address(this).balance, 0.000001e18);
    }

    receive() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        // emit Log("fallback", gasleft());
        console.log("receive", msg.value);
    }

    // write a test where bob buys first, then alice and then joy
    // bob sell for profit

    function test_buySell() public {
        uint256 bobInitialEthBalance = address(bob).balance;
        console.log("bobInitialEthBalance", bobInitialEthBalance);
        vm.prank(bob);
        bondingCurveToken.buy{value: 1 ether}();
        vm.prank(alice);
        bondingCurveToken.buy{value: 1 ether}();
        vm.prank(joy);
        bondingCurveToken.buy{value: 1 ether}();

        uint256 bobBalance = bondingCurveToken.balanceOf(bob);
        console.log("bobBalance", bobBalance);
        uint256 aliceBalance = bondingCurveToken.balanceOf(alice);
        console.log("aliceBalance", aliceBalance);
        uint256 joyBalance = bondingCurveToken.balanceOf(joy);
        console.log("joyBalance", joyBalance);

        vm.prank(bob);
        bondingCurveToken.sell(bobBalance);
        uint256 bobFinalEthBalance = address(bob).balance;
        console.log("bobFinalEthBalance", bobFinalEthBalance);

        console.log("bob profit", bobFinalEthBalance - bobInitialEthBalance);
    }
}
