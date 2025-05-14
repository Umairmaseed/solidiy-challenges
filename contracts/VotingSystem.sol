// Challenge 2: Decentralized Voting System (Basic DAO)
// Objective: Build a simple voting contract where users can create proposals, vote on them, and check the results.

// Requirements:

// Proposal Creation:

// Only the owner should be able to create proposals.

// Each proposal should have a name and a unique ID.

// Voting Logic:

// Allow any user to vote on a proposal.

// Each address can vote only once per proposal.

// Use events to log when a vote is cast.

// Proposal Results:

// Implement a function to get the current vote count for a proposal.

// Allow the owner to close the voting on a proposal and declare the result.

// Security Considerations:

// Prevent duplicate voting.

// Handle edge cases like non-existent proposal IDs.

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract VotingSystem {
    struct ProposalType {
        string name;
        string description;
        uint vote;
        bool active;
        mapping(address => bool) voters;
    }

    address public owner;
    uint public proposalCount;
    mapping(uint => ProposalType) private proposals;

    event VoteCasted(address indexed from, string proposalName);
    event ProposalCreated(uint indexed proposalId, string proposalName);
    event VotingStopped(uint indexed proposalId, string proposalName);

    constructor() {
        owner = msg.sender;
    }

    function createProposal(
        string memory name,
        string memory description
    ) public returns (uint) {
        require(msg.sender == owner, "Only the owner can create proposals");

        ProposalType storage proposal = proposals[proposalCount];
        proposal.name = name;
        proposal.description = description;
        proposal.active = true;

        emit ProposalCreated(proposalCount, name);

        return proposalCount++;
    }

    function castVote(uint id) public returns (bool) {
        require(id < proposalCount, "Invalid proposal ID");
        ProposalType storage proposal = proposals[id];
        require(proposal.active, "Voting for this proposal is closed");
        require(!proposal.voters[msg.sender], "You have already voted");

        proposal.voters[msg.sender] = true;
        proposal.vote++;

        emit VoteCasted(msg.sender, proposal.name);
        return true;
    }

    function getVotes(uint id) public view returns (uint) {
        require(id < proposalCount, "Invalid proposal ID");
        return proposals[id].vote;
    }

    function stopVoting(uint id) public returns (bool) {
        require(msg.sender == owner, "Only the owner can stop voting");
        require(id < proposalCount, "Invalid proposal ID");

        ProposalType storage proposal = proposals[id];
        require(proposal.active, "Voting already stopped");

        proposal.active = false;

        emit VotingStopped(id, proposal.name);
        return true;
    }
}
