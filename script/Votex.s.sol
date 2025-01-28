// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Votex} from "../src/Votex.sol";

contract VotexDeploy is Script {
    event VotexCreated(address votex);

    function run() external returns (Votex) {
        vm.startBroadcast();
        Votex votex = new Votex();
        vm.stopBroadcast();

        emit VotexCreated(address(votex));

        return votex;
    }
}
