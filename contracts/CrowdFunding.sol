// Challenge 10: Crowdfunding Smart Contract
// 🧠 Objective:
// Create a crowdfunding contract where multiple users can contribute ETH towards a project. If the funding goal is met before a deadline, the creator can withdraw the funds; otherwise, contributors can claim refunds.

// 📘 Expected Skills & Concepts:
// Time-based conditionals using block.timestamp

// ETH payment handling (msg.value, transfer, call)

// Mappings to track contributor balances

// Access control for creator-only withdrawals

// Refund logic per contributor

// Events for contributions, success, and refunds

// (Optional) Use of Ownable or ReentrancyGuard from OpenZeppelin

// 🧾 Requirements:
// Campaign Setup:

// Creator defines a goal amount and deadline.

// Campaign is active until deadline or goal reached.

// Contribute:

// Anyone can contribute ETH.

// Record how much each contributor sends.

// Withdraw:

// If goal met before deadline, creator can withdraw total raised.

// Refunds:

// If deadline passes and goal not met, contributors can claim refunds.

// Security:

// Prevent double withdrawals or double refunds.

// Handle reentrancy risk on withdraw and refund.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrowdFunding is Ownable, ReentrancyGuard {
    uint fundRaise;
    bool active;

    struct Fund {
        uint amount;
    }

    uint deadline;

    event Refund(address user, uint amount);
    event Success(address user, uint amount);
    event contribution(address user, uint amount);

    mapping(address => Fund) FundsList;

    constructor(uint _days, uint _amount) Ownable(msg.sender) {
        require(_days > 0, "Days can not be set to 0");
        require(_amount > 0, "Amount can not be 0");
        active = true;
        fundRaise = _amount;
        deadline = block.timestamp + (_days * 1 days);
    }

    function contribute() external payable nonReentrant returns (bool) {
        require(msg.value > 0, " You can not contribute 0 amount");
        require(active == true, "Funding is not active to contribute");
        FundsList[msg.sender].amount += msg.value;
        emit contribution(msg.sender, msg.value);
        return true;
    }

    function withDrawFunds() external nonReentrant onlyOwner returns (bool) {
        require(
            address(this).balance >= fundRaise,
            "Funds have not reach the require limit to withdraw"
        );
        require(active == true, "Funding is not active to contribute");

        payable(owner()).transfer(address(this).balance);
        active = false;
        fundRaise = 0;
        emit Success(msg.sender, fundRaise);
        return true;
    }

    function claimRefund() external nonReentrant {
        require(
            deadline < block.timestamp,
            "You can not claim your funds as the deadline have not yet passed"
        );
        require(
            FundsList[msg.sender].amount > 0,
            "You cant refund amount as your contribution are 0"
        );
        FundsList[msg.sender].amount = 0;
        payable(msg.sender).transfer(FundsList[msg.sender].amount);
        emit Refund(msg.sender, FundsList[msg.sender].amount);
    }

    function getContribution(address user) external view returns (uint) {
        return FundsList[user].amount;
    }
}
