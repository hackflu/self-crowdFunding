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
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Crowd Fund Project
 * @author HackFlu
 * @notice creating by my self
 */
contract CrowdFund {
    ////////////////////////
    /// type declearation //
    ///////////////////////
    struct Campaign {
        address creator; // setting the creator address
        bool claimed; // does the creator claimed the amount
        uint32 startAt; // starting campaign time
        uint32 endAt; // ending campaign time
        uint256 goal; // setting the goal amount
        uint256 pledged; // no of people pledged
        uint256 totalPledge; // to track the total amount for checking the goal
    }

    //////////////////////
    /// state varibale //
    ////////////////////
    uint256 private s_campaignCount;
    mapping(uint256 => Campaign) private s_trackCampaign;
    mapping(uint256 => mapping(address => uint256)) private s_userAmount;
    IERC20 private i_token;

    ////////////////////////
    //////// errors ///////
    //////////////////////
    error CrowdFund__InvalidAddress();
    error CrowdFund__InsufficientAmount();
    error CrowdFund__AmountCannotBeZero();
    error CrowdFund__StartTimeMustBeInFuture();
    error CrowdFund__EndTimeCannotBeBeforeStartTime();
    error CrowdFund__InvalidCampaignId();
    error CrowdFund__CampaignNotStarted();
    error CrowdFund__CampaignEnded();
    error CrowdFund__CannotCancel();
    error CrowdFund__OnlyAccessToCreator();
    error CrowdFund__GoalFullFilled();
    error CrowdFund__CannotAccessClaimAmount();
    error CrowdFund__NotEnded();
    error CrowdFund__CannotClaimAmount();
    error CrowdFund__AlreadyClaimed();
    error CrowdFund__InsufficientContractBalance();
    error CrowdFund__GoalNotFullFilled();
    error CrowdFund__TransferFailed();
    //////////////////////
    ////// events ///////
    /////////////////////
    event EventLaunched(uint256, uint32, uint32);
    event PledgeSuccessful(address indexed, uint256, uint256);
    event CampaignCancelled(uint256);
    event RefundSuccessful(address indexed, uint256);
    event UnpledgeSuccess(address indexed, uint256);
    event Claim(address indexed, uint256);

    //////////////////////////
    ///// constructor ////////
    /////////////////////////
    constructor(address _token) {
        i_token = IERC20(_token);
    }

    ////////////////////////
    ///// modifier ////////
    //////////////////////
    modifier checkAddress(address _addr) {
        if (_addr == address(0)) {
            revert CrowdFund__InvalidAddress();
        }
        _;
    }

    modifier checkId(uint256 _id) {
        if (_id > s_campaignCount) {
            revert CrowdFund__InvalidCampaignId();
        }
        _;
    }
    modifier checkAmount(uint256 _amount) {
        if (_amount == 0) {
            revert CrowdFund__AmountCannotBeZero();
        }
        _;
    }

    //////////////////////
    ////// function /////
    /////////////////////
    /**
     * @notice for launching the event
     * @param _goal for setting the goal amount
     * @param _startAt for setting the start time
     * @param _endAt for setting the end time
     */
    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external payable checkAddress(msg.sender) {
        if (_goal == 0) {
            revert CrowdFund__AmountCannotBeZero();
        }
        if (_startAt < block.timestamp) {
            revert CrowdFund__StartTimeMustBeInFuture();
        }
        if (_endAt < _startAt) {
            revert CrowdFund__EndTimeCannotBeBeforeStartTime();
        }

        s_campaignCount++;
        Campaign storage newCampaign = s_trackCampaign[s_campaignCount];
        newCampaign.goal += _goal;
        newCampaign.startAt = _startAt;
        newCampaign.endAt = _endAt;
        newCampaign.creator = msg.sender;
        newCampaign.totalPledge = 0;
        newCampaign.claimed = false;
        newCampaign.pledged = 0;

        emit EventLaunched(_goal, _startAt, _endAt);
    }

    /**
     * @notice for cancelling the campaing ,if created by the mistake
     * @param _id for specific id
     */
    function cancel(uint256 _id) external checkId(_id) {
        Campaign memory campaign = s_trackCampaign[_id];
        if (campaign.creator != msg.sender) {
            revert CrowdFund__OnlyAccessToCreator();
        }
        if (campaign.startAt < block.timestamp) {
            revert CrowdFund__CannotCancel();
        }
        delete s_trackCampaign[_id];
        emit CampaignCancelled(_id);
    }

    /**
     * @notice for adding value in campaign
     * @param _id unique id of campaign
     * @param _amount amount to add in Event
     */
    function pledge(uint256 _id, uint256 _amount) external checkAddress(msg.sender) checkId(_id) checkAmount(_amount) {
        Campaign storage campaign = s_trackCampaign[_id];
        if (block.timestamp < campaign.startAt) {
            revert CrowdFund__CampaignNotStarted();
        }
        if (block.timestamp > campaign.endAt) {
            revert CrowdFund__CampaignEnded();
        }
        campaign.pledged += 1;
        campaign.totalPledge += _amount;
        s_userAmount[_id][msg.sender] += _amount;

        // transferring the amount
        bool success = i_token.transferFrom(msg.sender, address(this), _amount);
        if (!success) {
            revert CrowdFund__TransferFailed();
        }
        emit PledgeSuccessful(msg.sender, _id, _amount);
    }

    /**
     * @notice for redeeming the
     * @param _id for identifying the campaign
     * @param _amount amount to redeem
     */
    function unpledge(uint256 _id, uint256 _amount)
        external
        checkAddress(msg.sender)
        checkId(_id)
        checkAmount(_amount)
    {
        if (s_userAmount[_id][msg.sender] < _amount) {
            revert CrowdFund__InsufficientAmount();
        }
        Campaign storage campaign = s_trackCampaign[_id];
        if (block.timestamp < campaign.startAt) {
            revert CrowdFund__CampaignNotStarted();
        }
        if (block.timestamp > campaign.endAt) {
            revert CrowdFund__CampaignEnded();
        }
        if (s_userAmount[_id][msg.sender] == _amount) {
            campaign.pledged -= 1;
            delete s_userAmount[_id][msg.sender];
        }
        campaign.totalPledge -= _amount;
        s_userAmount[_id][msg.sender] -= _amount;

        // checking the contract balance
        _calculateContractBalance(_amount);

        // tranfer from the contract to user
        bool success = i_token.transfer(msg.sender, _amount);
        if (!success) {
            revert CrowdFund__TransferFailed();
        }
        emit UnpledgeSuccess(msg.sender, _amount);
    }

    /**
     * @notice to claim the amount.only for creator
     * @param _id id of campaign
     */
    function claim(uint256 _id) external checkAddress(msg.sender) checkId(_id) {
        Campaign storage campaign = s_trackCampaign[_id];
        if (campaign.creator != msg.sender) {
            revert CrowdFund__CannotAccessClaimAmount();
        }
        if (campaign.endAt > block.timestamp) {
            revert CrowdFund__NotEnded();
        }
        if (campaign.totalPledge < campaign.goal) {
            revert CrowdFund__CannotClaimAmount();
        }
        if (campaign.claimed) {
            revert CrowdFund__AlreadyClaimed();
        }
        if (campaign.totalPledge != campaign.goal) {
            revert CrowdFund__GoalNotFullFilled();
        }
        campaign.claimed = true;
        // transfer to creator
        bool success = i_token.transfer(msg.sender, i_token.balanceOf(address(this)));
        if (!success) {
            revert CrowdFund__TransferFailed();
        }
        emit Claim(msg.sender, campaign.totalPledge);
    }

    /**
     * @notice for claiming the refund if the campaign goal does not match
     * @param _id for tracking the campaign
     */
    function refund(uint256 _id) external checkAddress(msg.sender) checkId(_id) {
        Campaign memory campaign = s_trackCampaign[_id];
        if (block.timestamp <= campaign.endAt) {
            revert CrowdFund__CampaignEnded();
        }
        if (campaign.goal <= campaign.totalPledge) {
            revert CrowdFund__GoalFullFilled();
        }
        uint256 balance = s_userAmount[_id][msg.sender];
        s_userAmount[_id][msg.sender] = 0;
        _calculateContractBalance(s_userAmount[_id][msg.sender]);
        // transfer to user
        bool success = i_token.transfer(msg.sender, s_userAmount[_id][msg.sender]);
        if (!success) {
            revert CrowdFund__TransferFailed();
        }
        emit RefundSuccessful(msg.sender, balance);
    }

    /////////////////////////////////
    ///// internal function /////////
    /////////////////////////////////
    function _calculateContractBalance(uint256 _amount) internal view {
        if (i_token.balanceOf(address(this)) < _amount) {
            revert CrowdFund__InsufficientContractBalance();
        }
    }

    /////////////////////////////////////
    ////// view and pure function //////
    ////////////////////////////////////
    // address creator; // setting the creator address
    // bool claimed; // does the creator claimed the amount
    // uint32 startAt; // starting campaign time
    // uint32 endAt; // ending campaign time
    // uint256 goal; // setting the goal amount
    // uint256 pledged; // no of people pledged
    // uint256 totalPledge; // to track the total amount for checking the goal
    /**
     * @notice to get the campaign details from struct
     * @param _id for campaign
     */
    function getTrackCampaign(uint256 _id)
        external
        view
        checkId(_id)
        returns (
            address creator,
            bool calimed,
            uint32 startAt,
            uint32 endAt,
            uint256 goal,
            uint256 pledged,
            uint256 totalPledge
        )
    {
        Campaign storage c = s_trackCampaign[_id];
        return (c.creator, c.claimed, c.startAt, c.endAt, c.goal, c.pledged, c.totalPledge);
    }

    function getUserAccount(uint256 _id, address _addr) external view returns (uint256) {
        return s_userAmount[_id][_addr];
    }
}
