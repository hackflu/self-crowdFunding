// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";
import {Token} from "../../src/Token.sol";
import {DeployScript} from "../../script/DeployScript.s.sol";
import {LaunchScript} from "../../script/interactions/LaunchScript.s.sol";
contract LaunchScriptTest is Test {
    CrowdFund crowdFund;
    LaunchScript launchScript;
    Token token;
    address user = makeAddr("user");
    address creator = makeAddr("creator");

    function setUp() public {
        DeployScript deploy = new DeployScript();
        (Token tokenAddr, CrowdFund crowdFundAddr) = deploy.run();
        token = Token(tokenAddr);
        crowdFund = CrowdFund(crowdFundAddr);
        launchScript = new LaunchScript();
    }

    function testLaunchCampaign() public {
        vm.startPrank(address(launchScript));
        launchScript.launch(address(crowdFund),50 ether, uint32(block.timestamp + 10 minutes), uint32(block.timestamp + 2 hours));
        (address _creator,,,, uint256 goal,,) = crowdFund.getTrackCampaign(1);
        vm.stopPrank();
        assert(_creator == address(launchScript));
        assert(goal == 50 ether);
    }
    
}