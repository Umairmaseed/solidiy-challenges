// Advanced Challenge 14: DAO Voting Contract
// 🧠 Objective:
// Implement a basic DAO where members can create proposals, vote on them with a 1-token-1-vote mechanism (based on an ERC20 token), and execute proposals if they pass.

// 📘 Expected Skills & Concepts:
// ERC20 token-based voting power

// Proposal lifecycle: creation → voting → execution

// block.timestamp or block.number based voting periods

// Event logging for proposals and votes

// Role restrictions (only token holders can vote)

// (Optional): OpenZeppelin IERC20, Ownable, ReentrancyGuard

// 🧾 Requirements:
// Create Proposal:

// Any token holder can create a proposal with a description.

// Proposals have a voting deadline (e.g., 3 days).

// Vote:

// Token holders vote for or against.

// Votes are weighted by their token balance at the time of voting.

// Execute Proposal:

// After deadline, if more votes are for than against, the proposal is marked passed.

// Security:

// Prevent double voting.

// Ensure only holders can vote.

// Events:

// Emit ProposalCreated, Voted, and ProposalExecuted.

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Voting {
    uint256 public proposalCount = 0;
    struct Proposal {
        address token;
        uint agree;
        uint disagree;
        uint deadline;
        bool executed;
        string description;
        address[] caster;
    }

    mapping(uint => Proposal) daoProposal;

    event ProposalCreated(uint id, string description, uint deadline);
    event VoteCasted(address caster, uint id);
    event ProposalExecuted(uint id);

    function createProposal(
        string calldata _description,
        address _token,
        uint deadlineSecondFromNow
    ) external returns (bool) {
        daoProposal[proposalCount + 1] = Proposal({
            token: _token,
            agree: 0,
            disagree: 0,
            deadline: block.timestamp + deadlineSecondFromNow,
            executed: false,
            description: _description,
            caster: new address[](0)
        });
        proposalCount += 1;
        emit ProposalCreated(
            proposalCount + 1,
            _description,
            block.timestamp + deadlineSecondFromNow
        );
        return true;
    }

    function vote(uint proposalId, bool support) external {
        require(
            daoProposal[proposalId].token != address(0),
            "There isnt any proposal available for the give id"
        );
        require(
            daoProposal[proposalId].executed != true,
            "The proposal is already executed"
        );
        require(
            daoProposal[proposalId].deadline > block.timestamp,
            "The deadline for the proposal has already been passed"
        );
        require(
            IERC20(daoProposal[proposalId].token).balanceOf(msg.sender) >= 1,
            "You dont have sufficient balance of token to cast vote"
        );

        for (uint i = 0; i < daoProposal[proposalId].caster.length; i++) {
            require(
                daoProposal[proposalId].caster[i] != msg.sender,
                "You have already casted your vote for this proposal"
            );
        }
        IERC20(daoProposal[proposalId].token).transfer(address(this), 1);
        if (support) {
            daoProposal[proposalId].agree += 1;
        } else {
            daoProposal[proposalId].disagree += 1;
        }
        daoProposal[proposalId].caster.push(msg.sender);
        emit VoteCasted(msg.sender, proposalId);
    }

    function executeProposal(uint proposalId) external {
        require(
            daoProposal[proposalId].token != address(0),
            "There isnt any proposal available for the give id"
        );
        require(
            daoProposal[proposalId].executed != true,
            "The proposal is already executed"
        );
        require(
            daoProposal[proposalId].deadline < block.timestamp,
            "The deadline has not yet reach for the proposal"
        );
        daoProposal[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function getProposal(uint id) external view returns (Proposal memory) {
        require(
            daoProposal[id].token != address(0),
            "There isnt any proposal available for the give id"
        );
        return daoProposal[id];
    }
}
