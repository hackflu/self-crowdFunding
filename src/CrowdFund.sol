// SPDX-License-Identifier: MIT

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

/**
 * @title Crowd Fund Project
 * @author HackFlu
 * @notice creating by my self
 */
contract CrowdFund {

    ////////////////////////
    /// type declearation //
    ///////////////////////
    struct Campaign{
        address creator;
        bool claimed;
        uint32 startAt;
        uint32 endAt;
        uint256 goal;
        uint256 pledged;
        uint256 totalPledge;
    }

    //////////////////////
    /// state varibale //
    //////////////////// 
    uint256 private s_campaignCount;
    mapping(uint256 => Campaign) private s_trackCampaign;
    mapping(uint256 => mapping(address => uint256)) private s_userAmount;

    ////////////////////////
    //////// errors ///////
    //////////////////////
    error  CrowdFund__InvalidAddress();
    error CrowdFund__InsufficientAmount();
    error CrowdFund__GoalCannotBeZero();
    error CrowdFund__StartTimeMustBeInFuture();
    error CrowdFund__EndTimeCannotRevertBeforeStartTime();
    
    //////////////////////
    ////// events ///////
    /////////////////////

    //////////////////////////
    ///// constructor ////////
    /////////////////////////
    event EventLaunched(uint256 , uint32 , uint32);
    ////////////////////////
    ///// modifier ////////
    //////////////////////
    modifier checkAddress(address _addr) {
        if(_addr == address(0)){
            revert CrowdFund__InvalidAddress();
        }
        _;
    }

    modifier checkBalance(uint256 _id , uint256 _amount){
        if(s_userAmount[_id][msg.sender] <= _amount) {
            revert CrowdFund__InsufficientAmount();
        }
        _;
    }
    ////////////////////// 
    ////// function /////
    /////////////////////
    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external checkAddress(msg.sender) {
        if(_goal == 0){
            revert CrowdFund__GoalCannotBeZero();
        }
        if(_startAt < block.timestamp) {
            revert CrowdFund__StartTimeMustBeInFuture();
        }
        if(_endAt < _startAt) {
            revert CrowdFund__EndTimeCannotRevertBeforeStartTime();
        }
        s_campaignCount++;
        Campaign storage newCampaign= s_trackCampaign[s_campaignCount];
        newCampaign.goal += _goal;
        newCampaign.startAt = _startAt;
        newCampaign.endAt = _endAt;
        newCampaign.creator = msg.sender;
        newCampaign.totalPledge = 0;
        newCampaign.claimed = false;
        newCampaign.pledged = 0;

        emit EventLaunched(_goal , _startAt , _endAt);

    }

    function cancel(uint _id) external {}

    function cancel() external {}

    function pledge() external {}

    function unpledge() external{}

    function claim() external {}

    function refund() external {}
}