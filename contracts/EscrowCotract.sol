// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter;

    uint256 public depositedAmount;
    bool public isComplete;

    event Deposited(address indexed buyer, uint256 amount);
    event Released(address indexed seller, uint256 amount);
    event Refunded(address indexed buyer, uint256 amount);

    modifier notCompleted() {
        require(!isComplete, "Escrow is already completed");
        _;
    }

    constructor(address _buyer, address _seller, address _arbiter) {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }

    function deposit() external payable notCompleted {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(depositedAmount == 0, "Deposit already made");

        depositedAmount = msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    function releaseFunds() external notCompleted {
        require(
            msg.sender == buyer || msg.sender == arbiter,
            "Only buyer or arbiter can release"
        );
        require(depositedAmount > 0, "Nothing to release");

        uint256 amount = depositedAmount;
        depositedAmount = 0;
        isComplete = true;

        payable(seller).transfer(amount);

        emit Released(seller, amount);
    }

    function refundBuyer() external notCompleted {
        require(
            msg.sender == seller || msg.sender == arbiter,
            "Only seller or arbiter can refund"
        );
        require(depositedAmount > 0, "Nothing to refund");

        uint256 amount = depositedAmount;
        depositedAmount = 0;
        isComplete = true;

        payable(buyer).transfer(amount);

        emit Refunded(buyer, amount);
    }
}
