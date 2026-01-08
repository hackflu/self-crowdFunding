// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../HelperConfig.s.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";
import {IToken} from "../../src/interface/IToken.i.sol";

contract PledgeScript is Script {
    HelperConfig helper;

    function run(uint256 _id , uint256 _amount) public {
        helper = new HelperConfig();
        (address tokenAddr, address crowdFundAddr) = helper.run();

        vm.startBroadcast();
        console.log("user balance Before Pledge :", IToken(tokenAddr).balanceOf(msg.sender));
        pledge(crowdFundAddr, _id, _amount);
        uint256 userDeposited = CrowdFund(crowdFundAddr).getUserAccount(1, msg.sender);
        console.log("user balance : ", userDeposited);
        vm.stopBroadcast();
    }

    function pledge(address crowdFundContractAddr,uint256 _id , uint256 _amount) public {
        CrowdFund(crowdFundContractAddr).pledge(_id, _amount);
    }

}
