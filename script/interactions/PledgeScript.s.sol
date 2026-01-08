// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../HelperConfig.s.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";
import {IToken} from "../../src/interface/IToken.i.sol";

contract PledgeScript is Script {
    HelperConfig helper;

    function run() public {
        helper = new HelperConfig();
        (address tokenAddr, address crowdFundAddr) = helper.run();

        address user = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
        address main_deployer = vm.envAddress("DEPLOYER");
        vm.startBroadcast(main_deployer);
        // minting the token for the user
        IToken(tokenAddr).mint(user, 100 ether);
        vm.stopBroadcast();

        // will do the pledge through the user
        vm.startBroadcast();
        IToken(tokenAddr).approve(crowdFundAddr, 100 ether);
        // setting for the pledge
        uint256 _id = 1;
        uint256 _amount = 100 ether;
        console.log(
            "user balance Before Pledge :",
            IToken(tokenAddr).balanceOf(msg.sender)
        );
        vm.warp(block.timestamp + 1 days);
        CrowdFund(crowdFundAddr).pledge(_id, _amount);
        uint256 userDeposited = CrowdFund(crowdFundAddr).getUserAccount(
            1,
            msg.sender
        );
        console.log("user balance : ", userDeposited);
        vm.stopBroadcast();
    }
}
