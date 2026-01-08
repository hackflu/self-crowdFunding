// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig {
    function run() public view returns(address,address) {
        address tokenContractAddr = DevOpsTools.get_most_recent_deployment("Token",block.chainid);
        address crowdFundAddr = DevOpsTools.get_most_recent_deployment("CrowdFund",block.chainid);
        return (tokenContractAddr , crowdFundAddr);
    }
}