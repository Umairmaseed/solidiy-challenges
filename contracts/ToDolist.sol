// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ToDoList {
    struct Task {
        string text;
        bool completed;
    }

    mapping(address => Task[]) private tasks;

    function createTask(string memory text) external {
        Task[] storage userTasks = tasks[msg.sender];

        for (uint i = 0; i < userTasks.length; i++) {
            if (keccak256(bytes(userTasks[i].text)) == keccak256(bytes(text))) {
                return; // Task already exists, do nothing
            }
        }

        userTasks.push(Task(text, false));
    }

    // Get all tasks for caller
    function getMyTasks() external view returns (Task[] memory) {
        return tasks[msg.sender];
    }

    // Mark a task completed by index
    function markCompleted(uint index) external {
        require(index < tasks[msg.sender].length, "Invalid index");
        tasks[msg.sender][index].completed = true;
    }

    // Edit a task text
    function updateTask(uint index, string memory newText) external {
        require(index < tasks[msg.sender].length, "Invalid index");
        tasks[msg.sender][index].text = newText;
    }
}
