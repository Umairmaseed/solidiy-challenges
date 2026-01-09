// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WalletLogic {
    address public owner; // slot 0
    uint256 public balance; // slot 1

    function initialize(address _owner) external {
        require(owner == address(0), "Already initialized");
        owner = _owner;
    }

    function deposit() external payable {
        balance += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(balance >= amount, "Insufficient balance");

        balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return balance;
    }
}
