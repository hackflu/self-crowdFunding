// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {CrowdFund} from "../../src/CrowdFund.sol";
import {Token} from "../../src/Token.sol";

contract CrowdFundTest is Test {
    address public owner = makeAddr("owner");
    address public creator = makeAddr("creator");
    address public user_1 = makeAddr("user_1");
    address public user_2 = makeAddr("user_2");

    Token public token;
    CrowdFund public crowdFund;

    function setUp() external {
        token = new Token();
        token.transferOwnership(owner);
        crowdFund = new CrowdFund(address(token));
    }

    function testLaunch() public {
        uint256 _goal = 1000 ether;
        uint32 startTime = uint32(block.timestamp + 300 seconds);
        uint32 endTime = uint32(block.timestamp + 600 seconds);
        vm.startPrank(creator);
        crowdFund.launch(_goal, startTime, endTime);
        (address _creator,, uint32 startAt, uint32 endAt, uint256 goal,,) = crowdFund.getTrackCampaign(1);
        vm.stopPrank();
        assertEq(startTime, startAt);
        assertEq(endTime, endAt);
        assertEq(_goal, goal);
        assertEq(creator, _creator);
    }

    function testLaunchWithZeroGoal() public {
        uint256 _goal = 0;
        uint32 startTime = uint32(block.timestamp + 300 seconds);
        uint32 endTime = uint32(block.timestamp + 600 seconds);
        vm.startPrank(creator);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__AmountCannotBeZero.selector));
        crowdFund.launch(_goal, startTime, endTime);
    }

    function testLaunchWithStartTimeInBefore() public {
        uint256 _goal = 1000 ether;
        console.log("current time Before: ", block.timestamp);
        vm.warp(100);
        uint32 pastTime = 50;
        uint32 endTime = uint32(block.timestamp + 1 days);
        console.log("current time : ", block.timestamp);
        console.log("current time after: ", block.timestamp);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__StartTimeMustBeInFuture.selector));
        crowdFund.launch(_goal, pastTime, endTime);
    }

    function testLaunchStartTimeHigherThenEndTime() public {
        uint256 _goal = 1000 ether;
        uint32 startTime = uint32(block.timestamp + 100);
        uint32 endTime = uint32(block.timestamp);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__EndTimeCannotBeBeforeStartTime.selector));
        crowdFund.launch(_goal, startTime, endTime);
    }

    function testLaunchEvent() public {
        uint256 _goal = 1000 ether;
        uint32 startTime = uint32(block.timestamp);
        uint32 endTime = uint32(block.timestamp + 100);
        vm.expectEmit(false, false, false, true, address(crowdFund));
        emit CrowdFund.EventLaunched(_goal, startTime, endTime);
        crowdFund.launch(_goal, startTime, endTime);
    }

    /////////////////////////////
    ///////// cancel ///////////
    ////////////////////////////
    modifier preCampaign() {
        int256 _goal = 1000 ether;
        uint32 startTime = uint32(block.timestamp);
        uint32 endTime = uint32(block.timestamp + 100);
        crowdFund.launch(_goal, startTime, endTime);
        _;
    }
    function testCancel() public preCampaign {
        
    }
}
