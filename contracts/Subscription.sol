// Challenge 9: Subscription Payment Contract
// 🧠 Objective:
// Implement a subscription-based payment system where users can subscribe to a service by paying recurring ETH fees. The service provider can withdraw collected fees.

// 📘 Expected Skills & Concepts:
// ETH payment handling (msg.value, payable, transfer)

// Time-based logic with block.timestamp

// Mappings for tracking subscriber status and payment history

// Events for subscription activity logging

// Access control for service provider withdrawals

// (Optional) Ownable from OpenZeppelin

// 🧾 Requirements:
// Subscribe:

// Users can subscribe by paying a fixed ETH amount.

// Each subscription lasts a specific time (e.g., 30 days).

// Extend subscription if already active.

// Unsubscribe:

// Users can cancel their subscription (no refund needed).

// Withdraw:

// Service provider (owner) can withdraw all collected ETH.

// View Functions:

// Allow users to view their subscription status and expiry time.

// Security:

// Prevent double payments for inactive periods.

// Ensure only the owner can withdraw.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Subscription is Ownable {
    struct Subscribers {
        string name;
        uint subscriptionExpiryDate;
    }
    uint fee;

    struct StatusAndTime {
        bool status;
        uint expiryTime;
    }

    mapping(address => Subscribers) SubscribersList;

    constructor(uint _fee) Ownable(msg.sender) {
        fee = _fee;
    }

    function subscribe(string memory _name) external payable returns (bool) {
        require(msg.value >= fee, "Amount is lower than the subscription fee");
        require(
            SubscribersList[msg.sender].subscriptionExpiryDate <
                block.timestamp,
            "User already have subscription"
        );

        SubscribersList[msg.sender] = Subscribers({
            name: _name,
            subscriptionExpiryDate: block.timestamp + 30 days
        });

        return true;
    }

    function unsubscribe() external returns (bool) {
        require(
            SubscribersList[msg.sender].subscriptionExpiryDate >
                block.timestamp,
            "Your Subscription is already expired"
        );

        SubscribersList[msg.sender].subscriptionExpiryDate = block.timestamp;

        return true;
    }

    function withdraw() external onlyOwner returns (bool) {
        require(
            address(this).balance > 0,
            "There no amount available for withdrawal"
        );
        payable(owner()).transfer(address(this).balance);
        return true;
    }

    function getFee() external view returns (uint) {
        return fee;
    }

    function changeFee(uint _fee) external onlyOwner returns (bool) {
        require(_fee > 0, "You cant set fee to 0 or below");
        fee = _fee;
        return true;
    }

    function checkStatusAndTime() external view returns (StatusAndTime memory) {
        bool stat;
        Subscribers memory user = SubscribersList[msg.sender];

        if (user.subscriptionExpiryDate > block.timestamp) {
            stat = true;
        } else {
            stat = false;
        }

        return StatusAndTime(stat, user.subscriptionExpiryDate);
    }
}
