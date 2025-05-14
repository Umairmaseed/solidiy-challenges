// Challenge 3: Simple Staking Contract
// Objective: Build a basic staking contract where users can deposit tokens to earn rewards over time.

// Requirements:

// Deposit and Withdraw Logic:

// Users should be able to stake tokens.

// Users should be able to withdraw their staked tokens along with the earned rewards.

// Reward Calculation:

// Implement a basic reward calculation based on the time the tokens were staked.

// Use a simple fixed annual interest rate for now.

// Security Considerations:

// Prevent double withdrawals.

// Use safe math for calculations (though Solidity 0.8+ has built-in overflow protection).

// Events for Transparency:

// Emit events on deposits, withdrawals, and reward claims.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Staking {
    struct UserStake {
        uint256 amountStaked;
        uint256 stakedDate;
        uint256 rewards;
    }

    uint256 public rate;
    address public tokenAddress;
    mapping(address => UserStake) public stakes;

    event TokenStaked(address indexed account, uint256 amount);
    event TokenWithdrawn(address indexed account, uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);

    constructor(address token, uint256 stakeRate) {
        require(stakeRate > 0, "Stake rate must be greater than 0");
        tokenAddress = token;
        rate = stakeRate;
    }

    function stake(uint256 amount) public returns (bool) {
        require(amount > 0, "Cannot stake 0 tokens");
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // If user has already staked, update rewards first
        if (stakes[msg.sender].amountStaked > 0) {
            _calculateRewards(msg.sender);
        }

        stakes[msg.sender].amountStaked += amount;
        stakes[msg.sender].stakedDate = block.timestamp;

        emit TokenStaked(msg.sender, amount);
        return true;
    }

    function withdraw(uint256 amount) public returns (bool) {
        UserStake storage userStake = stakes[msg.sender];
        require(
            userStake.amountStaked >= amount,
            "Withdraw amount exceeds staked balance"
        );

        // Calculate and reset rewards before withdrawal
        _calculateRewards(msg.sender);
        uint256 totalPayout = amount + userStake.rewards;
        userStake.amountStaked -= amount;
        userStake.rewards = 0;

        IERC20 token = IERC20(tokenAddress);
        require(
            token.transfer(msg.sender, totalPayout),
            "Token transfer failed"
        );

        emit TokenWithdrawn(msg.sender, amount);
        return true;
    }

    function claimRewards() public returns (bool) {
        _calculateRewards(msg.sender);
        uint256 rewards = stakes[msg.sender].rewards;
        require(rewards > 0, "No rewards to claim");

        stakes[msg.sender].rewards = 0;

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, rewards), "Reward transfer failed");

        emit RewardClaimed(msg.sender, rewards);
        return true;
    }

    function _calculateRewards(address staker) internal {
        UserStake storage stake = stakes[staker];
        require(stake.amountStaked > 0, "No staked tokens");

        uint256 timeStaked = block.timestamp - stake.stakedDate;
        uint256 newRewards = (stake.amountStaked * rate * timeStaked) /
            (365 days * 100);

        stake.rewards += newRewards;
        stake.stakedDate = block.timestamp;
    }

    function getStakedBalance(address staker) public view returns (uint256) {
        return stakes[staker].amountStaked;
    }

    function getTotalRewards(address staker) public view returns (uint256) {
        UserStake storage stake = stakes[staker];
        uint256 timeStaked = block.timestamp - stake.stakedDate;
        return
            stake.rewards +
            (stake.amountStaked * rate * timeStaked) /
            (365 days * 100);
    }
}
