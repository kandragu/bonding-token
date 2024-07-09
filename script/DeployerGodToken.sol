// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {GodToken} from "../src/godMode/GodToken.sol";

contract DeployerGodTokenScript is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places

    function setUp() public {}

    function run(address god) public returns (GodToken) {
        vm.startBroadcast();
        GodToken token = new GodToken(INITIAL_SUPPLY, god);
        console.log("Deployer ==>:", msg.sender);
        vm.stopBroadcast();

        return token;
    }
}
