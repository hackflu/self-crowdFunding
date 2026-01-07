// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {Token} from "../../src/Token.sol";

contract TokenTest is Test {
    Token private token;
    address public user = makeAddr("user");
    address public owner = makeAddr("owner");

    uint256 private constant AMOUNT = 100 ether;

    function setUp() external {
        token = new Token();
        token.transferOwnership(owner);
    }

    //////////////////////////
    //////// mint ///////////
    /////////////////////////

    function testMint() public {
        vm.startBroadcast(owner);
        token.mint(user, AMOUNT);
        vm.stopBroadcast();
        assertEq(token.balanceOf(user), AMOUNT);
    }

    function testMintWithZeroAddress() public {
        vm.startBroadcast(owner);
        vm.expectRevert(abi.encodeWithSelector(Token.Token__InvalidAddress.selector));
        token.mint(address(0), AMOUNT);
    }

    function testMintWithZeroAmount() public {
        uint256 toGetError = 0;
        vm.startBroadcast(owner);
        vm.expectRevert(abi.encodeWithSelector(Token.Token__AmountCannotBeZero.selector));
        token.mint(user, toGetError);
        vm.stopBroadcast();
    }
}
