// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../HelperConfig.s.sol";
import {IToken} from "../../src/interface/IToken.i.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";

contract ClaimScript is Script {    
    HelperConfig helper;
    function run() public {
        helper = new HelperConfig();
        (address tokenAddr , address crowdFundAddr) = helper.run();

        vm.startBroadcast();
        vm.warp(block.timestamp + 10 days);
        CrowdFund(crowdFundAddr).claim(1);
        vm.stopBroadcast();

    }
}