// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script, console} from "forge-std/Script.sol";
import {CrowdFund} from "../src/CrowdFund.sol";
import {Token} from "../src/Token.sol";

contract DeployScript is Script {
    Token public token;
    CrowdFund public crowdFund;

    function run() public returns (Token, CrowdFund) {
        vm.startBroadcast();
        token = new Token();
        crowdFund = new CrowdFund(address(token));
        vm.stopBroadcast();
        return (token, crowdFund);
    }
}
