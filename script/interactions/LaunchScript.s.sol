// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../HelperConfig.s.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";

contract LaunchScript is Script {
    HelperConfig helper;

    function run() public {
        // fetching the two contracts address from helperConfig
        helper = new HelperConfig();
        (, address crowdFundAddr) = helper.run();

        // use the address
        // use CrowdFund contract to execute the launch function
        console.log("default Owner ;", msg.sender);
        vm.startBroadcast();
        console.log("Current Owner ", msg.sender);
        uint256 _goal = 1000 ether;
        uint32 _startAt = uint32(block.timestamp + 1 days);
        uint32 _endAt = uint32(block.timestamp + 10 days);
        CrowdFund(crowdFundAddr).launch(_goal, _startAt, _endAt);
        vm.stopBroadcast();
    }
}
