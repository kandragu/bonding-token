// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import {Script, console} from "forge-std/Script.sol";
import {SanctionableTkn} from "../src/sanction/SanctionableTkn.sol";

contract DeploySanctionableTknScript is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places

    function setUp() public {}

    function run() public returns (SanctionableTkn) {
        vm.startBroadcast();
        SanctionableTkn token = new SanctionableTkn(INITIAL_SUPPLY);
        console.log("Deployer ==>:", msg.sender);
        vm.stopBroadcast();

        return token;
    }
}
