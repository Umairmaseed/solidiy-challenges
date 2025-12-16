// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EscrowLogic {
    address public buyer;
    address public seller;
    address public arbiter;
    uint public amount;
    bool public funded;

    function initialize(
        address _buyer,
        address _seller,
        address _arbiter
    ) external {
        require(buyer == address(0), "Already initialized");
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(!funded, "Already funded");

        amount = msg.value;
        funded = true;
    }

    function release() external {
        require(msg.sender == buyer || msg.sender == arbiter, "Not allowed");
        require(funded, "Not funded");

        funded = false;
        payable(seller).transfer(amount);
    }

    function refund() external {
        require(msg.sender == seller || msg.sender == arbiter, "Not allowed");
        require(funded, "Not funded");

        funded = false;
        payable(buyer).transfer(amount);
    }
}
