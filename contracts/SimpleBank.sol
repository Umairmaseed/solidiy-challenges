// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SimpleBank {
    mapping(address => uint256) balance;

    event Deposit(uint256 amount, address sender);
    event Withdraw(uint256 amount, address sender);

    function deposit() public payable returns (bool) {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.value, msg.sender);
        return true;
    }

    function withdraw(uint256 amount) public returns (bool) {
        require(
            amount <= balance[msg.sender],
            "Amount exceed your current balance"
        );
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdraw(amount, msg.sender);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }
}
