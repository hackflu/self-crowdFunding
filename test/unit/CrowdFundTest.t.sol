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
        crowdFund = new CrowdFund(address(token));
        token.mint(user_1, 1000 ether);
        vm.prank(user_1);
        token.approve(address(crowdFund), 100 ether);
    }

    ////////////////////////
    ///////// launch //////
    ///////////////////////
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
        uint256 _goal = 1000 ether;
        vm.warp(100);
        uint32 startTime = uint32(block.timestamp);
        uint32 endTime = uint32(block.timestamp + 100);
        vm.prank(creator);
        crowdFund.launch(_goal, startTime, endTime);
        _;
    }

    function testCancel() public preCampaign {
        vm.prank(creator);
        crowdFund.cancel(1);
        (,,,, uint256 goal,,) = crowdFund.getTrackCampaign(1);
        assertEq(goal, 0);
    }

    function testCancelWithInvalidAddress() public preCampaign {
        vm.prank(address(0x123));
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__OnlyAccessToCreator.selector));
        crowdFund.cancel(1);
    }

    function testCancelWithGtStartTime() public preCampaign {
        vm.prank(creator);
        vm.warp(block.timestamp + 70);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__CannotCancel.selector));
        crowdFund.cancel(1);
    }

    function testCancelEvent() public preCampaign {
        vm.startPrank(creator);
        vm.expectEmit(false, false, false, true, address(crowdFund));
        emit CrowdFund.CampaignCancelled(1);

        crowdFund.cancel(1);
        vm.stopPrank();
    }

    /////////////////////
    /////// pledge /////
    ////////////////////
    function testPledge() public preCampaign {
        vm.startPrank(user_1);
        console.log(token.balanceOf(user_1));
        vm.expectEmit(true, false, false, true, address(crowdFund));
        emit CrowdFund.PledgeSuccessful(user_1, 1, 100 ether);
        crowdFund.pledge(1, 100 ether);
        uint256 user_balance = crowdFund.getUserAccount(1, user_1);
        vm.stopPrank();

        assertEq(user_balance, 100 ether);
    }

    function testPledgeWithInvalidAddress() public preCampaign {
        vm.startPrank(address(0));
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__InvalidAddress.selector));
        crowdFund.pledge(1, 100 ether);
        vm.stopPrank();
    }

    function testPledgeWithCampaignNotStarted() public preCampaign {
        vm.warp(block.timestamp - 10);
        vm.startPrank(user_1);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__CampaignNotStarted.selector));
        crowdFund.pledge(1, 100 ether);
        vm.stopPrank();
    }

    function testPledgeWithInvalidId() public preCampaign {
        vm.startPrank(user_1);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__InvalidCampaignId.selector));
        crowdFund.pledge(2, 100 ether);
        vm.stopPrank();
    }

    function testPledgeWithInvalidAmount() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__AmountCannotBeZero.selector));
        crowdFund.pledge(1, 0);
        vm.stopPrank();
    }

    ////////////////////////////////
    /////// unpledge //////////////
    ///////////////////////////////
    function testUnpledge() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        crowdFund.pledge(1, 100 ether);
        crowdFund.unpledge(1, 50 ether);
        uint256 user_balance = crowdFund.getUserAccount(1, user_1);
        vm.stopPrank();

        assertEq(user_balance, 50 ether);
    }

    function testInsufficientAmountToUnpledge() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        crowdFund.pledge(1, 100 ether);
        vm.expectRevert(abi.encodeWithSelector(CrowdFund.CrowdFund__InsufficientAmount.selector));
        crowdFund.unpledge(1, 150 ether);
        vm.stopPrank();
    }

    function testUnpledgeEvent() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        crowdFund.pledge(1, 100 ether);
        vm.expectEmit(true, false, false, true, address(crowdFund));
        emit CrowdFund.UnpledgeSuccess(user_1, 50 ether);
        crowdFund.unpledge(1, 50 ether);
        vm.stopPrank();
    }

    ////////////////////////////
    /////// refund /////////////
    ////////////////////////////
    function testRefund() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        crowdFund.pledge(1, 100 ether);
        vm.warp(block.timestamp + 200);
        crowdFund.refund(1);
        uint256 user_balance = crowdFund.getUserAccount(1, user_1);
        vm.stopPrank();
        assertEq(user_balance, 0);
    }

    function testRefundEvent() public preCampaign {
        vm.warp(block.timestamp + 10);
        vm.startPrank(user_1);
        crowdFund.pledge(1, 100 ether);
        vm.warp(block.timestamp + 200);
        vm.expectEmit(true, false, false, true, address(crowdFund));
        emit CrowdFund.RefundSuccessful(user_1, 100 ether);
        crowdFund.refund(1);
        vm.stopPrank();
    }

    //////////////////////////////
    ///////// claim /////////////
    /////////////////////////////

    function testClaim() public preCampaign {
        token.mint(user_1, 1000 ether);
        vm.prank(user_1);
        token.approve(address(crowdFund), 1000 ether);

        vm.prank(user_1);
        vm.warp(block.timestamp + 10);
        crowdFund.pledge(1, 1000 ether);

        vm.warp(block.timestamp + 200);
        vm.startPrank(creator);
        crowdFund.claim(1);
        (, bool claimed,,, uint256 _goal,, uint256 totalPledged) = crowdFund.getTrackCampaign(1);
        assertEq(claimed, true);
        assertEq(totalPledged, _goal);
        vm.stopPrank();
    }
}
