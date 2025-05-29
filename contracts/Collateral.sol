// Advanced Challenge 11: Collateralized Lending Protocol
// 🧠 Objective:
// Build a simplified version of a lending protocol (like Compound or Aave) where users can deposit an ERC20 token as collateral and borrow another ERC20 token against it. If the collateral ratio drops below a threshold, their position can be liquidated.

// 📘 Expected Skills & Concepts:
// ERC20 interactions (IERC20, transferFrom, approve)

// Collateralization logic (loan-to-value ratio)

// Price oracle mock (simplified, hardcoded price feed or Chainlink)

// Liquidation mechanics

// Reentrancy guards, access control, overflow-safe math

// Events and position tracking

// (Optional) OpenZeppelin libraries for IERC20, Ownable, ReentrancyGuard

// 🧾 Requirements:
// Deposit Collateral:

// Users deposit token A (e.g., DAI) as collateral.

// Track how much each user has deposited.

// Borrow Token:

// Users borrow token B (e.g., WETH) up to a % of their collateral value (e.g., 60% LTV).

// Repay Loan:

// Users repay borrowed amount to regain collateral rights.

// Liquidate:

// If a user’s loan exceeds allowed collateral value, anyone can liquidate and seize part of their collateral.

// Oracle:

// Use a mock getPrice() function that returns a hardcoded price for simplicity.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Collateral is Ownable, ReentrancyGuard {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint public constant LTV = 60;
    uint public constant LIQUIDATION_THRESHOLD = 70;

    struct Position {
        uint collateralAmount;
        uint borrowedAmount;
    }

    mapping(address => Position) public positions;

    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function getPrice(address token) public view returns (uint) {
        if (token == address(0)) revert("Invalid token");
        if (token == address(tokenA)) return 1e18;
        if (token == address(tokenB)) return 2e18;
        return 1e18;
    }

    function depositCollateral(uint amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        tokenA.transferFrom(msg.sender, address(this), amount);
        positions[msg.sender].collateralAmount += amount;
    }

    function borrow(uint amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        Position storage pos = positions[msg.sender];
        uint collateralValueUSD = (pos.collateralAmount *
            getPrice(address(tokenA))) / 1e18;
        uint newBorrowedValueUSD = ((pos.borrowedAmount + amount) *
            getPrice(address(tokenB))) / 1e18;

        require(
            newBorrowedValueUSD * 100 <= collateralValueUSD * LTV,
            "Exceeds max borrow limit"
        );

        pos.borrowedAmount += amount;
        tokenB.transfer(msg.sender, amount);
    }

    function repay(uint amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        Position storage pos = positions[msg.sender];

        tokenB.transferFrom(msg.sender, address(this), amount);
        if (amount >= pos.borrowedAmount) {
            pos.borrowedAmount = 0;
        } else {
            pos.borrowedAmount -= amount;
        }
    }

    function liquidate(address user) external nonReentrant {
        Position storage pos = positions[user];
        require(pos.collateralAmount > 0, "No position");

        uint collateralValueUSD = (pos.collateralAmount *
            getPrice(address(tokenA))) / 1e18;
        uint borrowedValueUSD = (pos.borrowedAmount *
            getPrice(address(tokenB))) / 1e18;

        uint ratio = (borrowedValueUSD * 100) / collateralValueUSD;
        require(ratio > LIQUIDATION_THRESHOLD, "Not eligible for liquidation");

        uint seized = pos.collateralAmount / 2;
        pos.collateralAmount -= seized;
        tokenA.transfer(msg.sender, seized);
    }

    function withdrawTokens(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}
