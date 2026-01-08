// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {DeployScript} from "../../script/DeployScript.s.sol";
import {Token} from "../../src/Token.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";

contract DeployScriptTest is Script {
    DeployScript deploy;
    Token token;
    CrowdFund crowdFund;
    address user = makeAddr("user");
    address creator = makeAddr("creator");

    function setUp() public {
        deploy = new DeployScript();
        (token, crowdFund) = deploy.run();
    }

    function testDeployWithLaunch() public {
        vm.startPrank(creator);
        CrowdFund(crowdFund).launch(100 ether, uint32(block.timestamp + 5 minutes), uint32(block.timestamp + 5 hours));
        (address _creator,,,, uint256 goal,,) = CrowdFund(crowdFund).getTrackCampaign(1);
        vm.stopPrank();
        assert(_creator == creator);
        assert(goal == 100 ether);
    }
}
