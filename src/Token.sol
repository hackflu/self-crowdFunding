// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    //////////////////
    ///// error /////
    ////////////////
    error Token__InvalidAddress();
    error Token__AmountCannotBeZero();

    constructor() ERC20("Mini", "MI") Ownable(msg.sender) {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        if (address(0) == _to) {
            revert Token__InvalidAddress();
        }
        if (_amount == 0) {
            revert Token__AmountCannotBeZero();
        }
        _mint(_to, _amount);
    }
}
