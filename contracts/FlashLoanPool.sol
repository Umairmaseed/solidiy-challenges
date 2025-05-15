// Challenge 6: Flash Loan Pool Contract
// Objective:
// Create a simple flash loan pool where users can deposit ETH and borrowers can take zero-interest loans provided they repay them within the same transaction.

// Expected Skills & Concepts:
// Smart contract reentrancy protection

// Custom function interfaces for borrower callbacks

// Balance tracking with address(this).balance

// msg.sender trust assumptions (callbacks, impersonation risks)

// Advanced require statements and flow guards

// (Optional) Interfaces for flash loan receivers

// Requirements:
// Deposit Functionality:

// Users can deposit ETH into the loan pool.

// Track total available liquidity.

// Flash Loan Mechanism:

// Borrower contract must implement a receiveFlashLoan(uint amount) function.

// Loan must be repaid in the same transaction.

// Repayment Validation:

// Use balanceBefore and balanceAfter logic to ensure full repayment.

// Revert if funds are not fully returned.

// Reentrancy Protection:

// Prevent re-entrancy via mutex or function modifier.

// Event Logging:

// Emit events for deposit, loan issued, and loan repaid.

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IFlashLoanReceiver {
    function executeOperation(uint256 amount) external payable;
}

contract FlashLoan {
    bool lock;
    mapping(address => uint) depositorsBalance;

    event DepositMade(address depositor, uint amount);
    event AmountWithdraw(address depositor, uint amount);
    event FlashLoanUsed(address requester, uint amount);

    modifier onlySmartContracts() {
        require(
            msg.sender.code.length > 0,
            "Only a smart contract have permission to receive flash loan"
        );
        _;
    }

    constructor() {
        lock = false;
    }

    function deposit() external payable returns (bool) {
        require(msg.value > 0, "You cant deposit 0 eth");
        depositorsBalance[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);

        return true;
    }

    function withdraw(uint amount) external {
        require(
            amount <= depositorsBalance[msg.sender],
            "Amount exceeds you deposited value"
        );

        payable(msg.sender).transfer(amount);
        depositorsBalance[msg.sender] -= amount;
        emit AmountWithdraw(msg.sender, amount);
    }

    function getLiquidity() external view returns (uint) {
        return address(this).balance;
    }

    function receiveFlashLoan(uint amount) external onlySmartContracts {
        uint256 balanceBefore = address(this).balance;

        require(amount > 0, "You Cant request for 0 amount");
        require(
            amount <= balanceBefore,
            "You request amount is greater than liquidity available"
        );

        require(!lock, "Liquidity already lock please wait for it to unlock");
        lock = true;
        payable(msg.sender).transfer(amount);

        IFlashLoanReceiver(msg.sender).executeOperation{value: 0}(amount);
        require(address(this).balance >= balanceBefore, "Loan not repaid");
        lock = false;
        emit FlashLoanUsed(msg.sender, amount);
    }
}
