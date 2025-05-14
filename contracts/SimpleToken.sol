// Challenge 1: Simple Token Contract
// Objective: Create a basic ERC20-like token contract.

// Requirements:

// The contract should allow the deployment of a token with a fixed supply.

// Implement basic ERC20 functions like balanceOf, transfer, approve, allowance, and transferFrom.

// Use events like Transfer and Approval to log important state changes.

// Ensure the contract is secure against overflows (consider Solidity versions >= 0.8).

// Add a constructor to initialize the token with a fixed supply and assign the entire supply to the deployer.

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract SimpleToken {
    uint256 totalSupply;
    address owner;
    mapping(address => uint256) balance;
    mapping(address => mapping(address => bool)) allowance;
    event Transfer(address to, address from, uint256 amount);
    event Approve(address owner, address spender);

    constructor(uint256 supply) {
        require(supply > 0, "total supply cant be 0");
        totalSupply = supply;
        owner = msg.sender;
        balance[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balance[account];
    }

    function transfer(address account, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount should be grater than 0");
        require(balance[msg.sender] >= amount, "Insufficient balance");

        balance[msg.sender] -= amount;
        balance[account] += amount;

        emit Transfer(account, msg.sender, amount);

        return true;
    }

    function approve(address account) public returns (bool) {
        allowance[msg.sender][account] = true;
        emit Approve(msg.sender, account);
        return true;
    }

    function transferFrom(
        address to,
        address from,
        uint256 amount
    ) public returns (bool) {
        require(amount > 0, "amount should be greater than 0");
        require(balance[from] >= 0, "insufficient balance in account");
        require(
            allowance[from][msg.sender] == true,
            "you are not authorized by the account to send tokens"
        );

        balance[from] -= amount;
        balance[to] += amount;

        emit Transfer(to, from, amount);

        return true;
    }
}
