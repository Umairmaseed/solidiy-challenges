// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract PollSystem {
    struct Poll {
        string question;
        string[] options;
        mapping(uint => uint) votes;
        mapping(address => bool) hasVoted;
        address creator;
        bool isActive;
    }

    Poll[] private polls;

    function createPoll(
        string memory question,
        string[] memory options
    ) external {
        require(bytes(question).length > 0, "Question cannot be empty");
        require(options.length >= 2, "At least 2 options required");

        Poll storage newPoll = polls.push();
        newPoll.question = question;
        newPoll.creator = msg.sender;
        newPoll.isActive = true;

        for (uint i = 0; i < options.length; i++) {
            require(bytes(options[i]).length > 0, "Empty option not allowed");
            newPoll.options.push(options[i]);
        }
    }

    function vote(uint pollId, uint optionIndex) external {
        require(pollId < polls.length, "Poll does not exist");

        Poll storage poll = polls[pollId];
        require(poll.isActive, "Poll is closed");
        require(!poll.hasVoted[msg.sender], "Already voted");
        require(optionIndex < poll.options.length, "Invalid option");

        poll.hasVoted[msg.sender] = true;
        poll.votes[optionIndex] += 1;
    }

    function closePoll(uint pollId) external {
        require(pollId < polls.length, "Poll does not exist");

        Poll storage poll = polls[pollId];
        require(msg.sender == poll.creator, "Only creator can close poll");
        require(poll.isActive, "Poll already closed");

        poll.isActive = false;
    }

    function getPoll(
        uint pollId
    )
        external
        view
        returns (
            string memory question,
            string[] memory options,
            uint[] memory voteCounts,
            bool isActive
        )
    {
        require(pollId < polls.length, "Poll does not exist");

        Poll storage poll = polls[pollId];

        question = poll.question;
        isActive = poll.isActive;

        options = poll.options;

        voteCounts = new uint[](options.length);
        for (uint i = 0; i < options.length; i++) {
            voteCounts[i] = poll.votes[i];
        }
    }

    function totalPolls() external view returns (uint) {
        return polls.length;
    }
}
