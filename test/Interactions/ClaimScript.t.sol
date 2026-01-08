// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ClaimScript} from "../../script/interactions/ClaimScript.s.sol";
import {Test,console} from "forge-std/Test.sol";
import {DeployScript} from "../../script/DeployScript.s.sol";
import {Token} from "../../src/Token.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";

contract ClaimScriptTest is Test {
    ClaimScript claim;
    DeployScript deploy;
    Token token;
    CrowdFund crowdFund;

    address EXECUTOR = makeAddr("executor");

    function setUp() public {
        deploy = new DeployScript();
        (token, crowdFund) = deploy.run();
        claim = new ClaimScript();
    }

    function testClaimTest() public {
        address user = makeAddr("user");
        vm.prank(address(claim));
        CrowdFund(crowdFund).launch(
            100 ether,
            uint32(block.timestamp + 360),
            uint32(block.timestamp + 1 days)
        );

        deal(address(token) ,user, 100 ether);
        vm.startPrank(user);
        console.log("user balance : ", Token(token).balanceOf(user));
        token.approve(address(crowdFund), 100 ether);
        vm.warp(block.timestamp + 5 hours);
        console.log(
            "user balance after some t: ",
            Token(token).balanceOf(user)
        );
        CrowdFund(crowdFund).pledge(1, 100 ether);
        vm.stopPrank();

        vm.startPrank(address(claim));
        vm.warp(block.timestamp + 1 days + 5 hours);
        claim.claimCampaign(address(crowdFund), 1);

        (, , , , uint256 goal, , uint256 totalPledge) = CrowdFund(crowdFund)
            .getTrackCampaign(1);
        uint256 userDeposited = CrowdFund(crowdFund).getUserAccount(1, user);
        assertEq(goal, totalPledge);
        assertEq(userDeposited, 100 ether);
        vm.stopPrank();
    }
}
