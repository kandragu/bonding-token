// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SanctionableTkn} from "../src/sanction/SanctionableTkn.sol";

contract SanctionableTknTest is Test {
    SanctionableTkn token;

    function setUp() public {
        token = new SanctionableTkn("TestToken", "TST");
    }

    function test_CreateToken() public view {
        assertEq(token.name(), "TestToken");
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }

    // function test_Transfer() public {
    //     token.transfer(address(this), 100 * 10 ** 18);
    //     assertEq(token.balanceOf(address(this)), 100 * 10 ** 18);
    // }
}
