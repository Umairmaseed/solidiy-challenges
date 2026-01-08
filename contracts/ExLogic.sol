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
        require(
            _buyer != address(0) &&
                _seller != address(0) &&
                _arbiter != address(0),
            "Invalid address"
        );

        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(!funded, "Already funded");
        require(msg.value > 0, "No ETH sent");

        amount = msg.value;
        funded = true;
    }

    function release() external {
        require(msg.sender == buyer || msg.sender == arbiter, "Not allowed");
        require(funded, "Not funded");

        funded = false;
        uint value = amount;
        amount = 0;

        payable(seller).transfer(value);
    }

    function refund() external {
        require(msg.sender == seller || msg.sender == arbiter, "Not allowed");
        require(funded, "Not funded");

        funded = false;
        uint value = amount;
        amount = 0;

        payable(buyer).transfer(value);
    }
}
