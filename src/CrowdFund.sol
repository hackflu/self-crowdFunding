// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Crowd Fund Project
 * @author HackFlu
 * @notice creating by my self
 */
contract CrowdFund {
    struct EventDetails{
        uint256 goal;
        uint32 startAt;
        uint32 endAt;
    }
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {

    }

    function cancel(uint _id) external {}

    function cancel() external {}

    function pledge() external {}

    function unpledge() external{}

    function claim() external {}

    function refund() external {}
}