// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ExpenseTracker {
    struct Expense {
        string title;
        uint amount;
        string category;
        uint timestamp;
    }

    mapping(address => Expense[]) private userExpenses;

    function addExpense(
        string memory title,
        uint amount,
        string memory category
    ) external {
        userExpenses[msg.sender].push(
            Expense(title, amount, category, block.timestamp)
        );
    }

    function getExpenses() external view returns (Expense[] memory) {
        return userExpenses[msg.sender];
    }

    function getTotalExpenses() external view returns (uint) {
        uint totalExp = 0;
        for (uint i = 0; i < userExpenses[msg.sender].length; i++) {
            totalExp += userExpenses[msg.sender][i].amount;
        }
        return totalExp;
    }

    function getCategoryTotal(
        string memory category
    ) external view returns (uint) {
        uint totalExp = 0;
        for (uint i = 0; i < userExpenses[msg.sender].length; i++) {
            if (
                keccak256(bytes(userExpenses[msg.sender][i].category)) ==
                keccak256(bytes(category))
            ) {
                totalExp += userExpenses[msg.sender][i].amount;
            }
        }
        return totalExp;
    }
}
