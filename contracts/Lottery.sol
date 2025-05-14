// Challenge 4: Decentralized Lottery Contract
// Objective: Build a decentralized lottery system where users can buy tickets and a winner is randomly selected. This is a great way to get hands-on with randomness, player management, and contract payouts.

// Requirements:

// Ticket Purchase:

// Users should be able to buy lottery tickets for a fixed price.

// Track each participant’s entries.

// Random Winner Selection:

// Implement a secure (or as close as possible) random winner selection mechanism.

// Ensure the randomness can’t be easily manipulated by miners.

// Prize Distribution:

// Transfer the total pool to the winner and reset the lottery.

// Ensure the contract owner can’t accidentally drain the pool.

// Security Considerations:

// Prevent double withdrawals.

// Use events for transparency.

// Implement access control for key functions like drawing the winner.

// Testing for Edge Cases:

// Handle cases like drawing without participants or insufficient funds.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);

    function transfer(address to, uint amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Lottery {
    struct Participant {
        string name;
        uint date;
        uint ticketNumber;
        address addr;
    }

    uint public ticketPrice;
    uint public maxTickets;
    bool public lotteryActive;
    address public owner;
    uint public ticketNumber;
    address public tokenAdd;
    Participant[] private participants;
    mapping(address => bool) public hasPurchased;

    event LotteryActivated(uint time, address account);
    event TicketPurchased(uint time, address account, uint price);
    event LotteryWinner(uint time, address winner, uint amount);
    event LotteryInactive(uint time);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setTokenAddress(address _tokenAdd) external onlyOwner {
        require(_tokenAdd != address(0), "Invalid token address");
        tokenAdd = _tokenAdd;
    }

    function startLottery(
        uint price,
        uint max
    ) external onlyOwner returns (bool) {
        require(price > 0, "Price cannot be zero");
        require(max > 0, "Max tickets cannot be zero");
        require(!lotteryActive, "Lottery already active");

        ticketPrice = price;
        maxTickets = max;
        ticketNumber = 1;
        lotteryActive = true;

        emit LotteryActivated(block.timestamp, msg.sender);
        return true;
    }

    function purchaseTicket(string calldata name) external returns (bool) {
        require(lotteryActive, "Lottery is inactive");
        require(!hasPurchased[msg.sender], "Ticket already purchased");
        require(ticketNumber <= maxTickets, "All tickets sold");

        IERC20 token = IERC20(tokenAdd);
        require(
            token.transferFrom(msg.sender, address(this), ticketPrice),
            "Ticket payment failed"
        );

        participants.push(
            Participant(name, block.timestamp, ticketNumber, msg.sender)
        );
        hasPurchased[msg.sender] = true;
        ticketNumber++;

        emit TicketPurchased(block.timestamp, msg.sender, ticketPrice);
        return true;
    }

    function luckyDraw() external onlyOwner returns (bool) {
        require(lotteryActive, "Lottery is not active");
        require(participants.length > 0, "No participants");

        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    participants.length
                )
            )
        ) % participants.length;

        address winner = participants[randomIndex].addr;
        IERC20 token = IERC20(tokenAdd);
        uint256 prize = token.balanceOf(address(this));

        require(token.transfer(winner, prize), "Prize transfer failed");

        emit LotteryWinner(block.timestamp, winner, prize);
        emit LotteryInactive(block.timestamp);

        // Reset state
        delete participants;
        lotteryActive = false;
        ticketNumber = 1;
        for (uint i = 0; i < participants.length; i++) {
            hasPurchased[participants[i].addr] = false;
        }

        return true;
    }

    function getParticipants() external view returns (Participant[] memory) {
        return participants;
    }
}
