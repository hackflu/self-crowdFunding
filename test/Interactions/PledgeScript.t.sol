// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {DeployScript} from "../../script/DeployScript.s.sol";
import {PledgeScript} from "../../script/interactions/PledgeScript.s.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";
import {Token} from "../../src/Token.sol";

contract PledgeScriptTest is Test {
    CrowdFund crowdFund;
    Token token;
    PledgeScript pledgeScript;
    address user = makeAddr("user");
    address creator = makeAddr("creator");

    function setUp() public {
        DeployScript deploy = new DeployScript();
        (Token tokenAddr, CrowdFund crowdFundAddr) = deploy.run();
        token = Token(tokenAddr);
        crowdFund = CrowdFund(crowdFundAddr);
        pledgeScript = new PledgeScript();

        // Launch a campaign
        vm.startPrank(creator);
        crowdFund.launch(
            100 ether,
            uint32(block.timestamp + 5 minutes),
            uint32(block.timestamp + 5 hours)
        );
        vm.stopPrank();

        // Mint tokens to user and approve pledgeScript
    }

    function testPledgeToCampaign() public {
        // Give PledgeScript tokens and have it approve crowdFund
        deal(address(token), address(pledgeScript), 100 ether);

        vm.startPrank(address(pledgeScript));
        token.approve(address(crowdFund), 100 ether);
        vm.warp(block.timestamp + 2 hours);
        pledgeScript.pledge(address(crowdFund), 1, 20 ether);
        vm.stopPrank();

        (, , , , , ,uint256 totalPledged) = crowdFund.getTrackCampaign(1);
        assert(totalPledged == 20 ether);
    }
}
