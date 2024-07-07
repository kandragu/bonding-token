// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import {Script, console} from "forge-std/Script.sol";
import {EscrowTimeLock} from "../src/Escrow/EscrowTimeLock.sol";

contract DeployEscrowTimeLock is Script {
    function setUp() public {}

    function run() public returns (EscrowTimeLock) {
        vm.startBroadcast();
        EscrowTimeLock escrow = new EscrowTimeLock();
        console.log("Deployer ==>:", msg.sender);

        vm.stopBroadcast();
        return escrow;
    }
}
