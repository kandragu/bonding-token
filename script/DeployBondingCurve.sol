// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {BondingCurve} from "../src/bondingCurveToken/BondingCurve.sol";

contract BondingCurveScript is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {}

    function run() public returns (BondingCurve) {
        vm.startBroadcast();
        BondingCurve token = new BondingCurve{value: 1 wei}();
        console.log("Deployer ==>:", msg.sender);

        vm.stopBroadcast();
        return token;
    }
}
