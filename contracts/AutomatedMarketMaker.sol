// Advanced Challenge 12: Constant Product AMM (Uniswap V1-Style DEX)
// 🧠 Objective:
// Implement a minimal Automated Market Maker (AMM) that allows users to swap between two ERC20 tokens using the constant product formula x * y = k.

// 📘 Expected Skills & Concepts:
// AMM math: constant product formula (x * y = k)

// Token-to-token swaps with slippage

// Liquidity provision and LP token minting

// Liquidity withdrawal (burning LP tokens)

// ERC20 transfers, approvals

// Event logging (Swap, Mint, Burn)

// (Optional): use OpenZeppelin’s IERC20, Ownable, ERC20

// 🧾 Requirements:
// Liquidity Provision:

// Users deposit tokenA and tokenB in equal value.

// Mint LP tokens to represent pool share.

// Swapping:

// Users can swap tokenA ↔ tokenB at price determined by pool reserves.

// Apply 0.3% fee (like Uniswap).

// Liquidity Withdrawal:

// Burn LP tokens and return proportional amounts of tokenA and tokenB.

// Security:

// Check input/output balance before and after swap to validate invariants.

// Handle edge cases (zero input, draining pool, division-by-zero).

// Events:

// Emit Swap, Mint, and Burn.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ConstantProductAMM is ERC20 {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public constant FEE_PERCENT = 3; // 0.3% fee
    uint256 public constant FEE_DENOMINATOR = 1000;

    event Swap(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        address indexed tokenOut,
        uint256 amountOut
    );
    event Mint(
        address indexed user,
        uint256 amountA,
        uint256 amountB,
        uint256 lpTokens
    );
    event Burn(
        address indexed user,
        uint256 amountA,
        uint256 amountB,
        uint256 lpTokens
    );

    constructor(address _tokenA, address _tokenB) ERC20("LP Token", "LPT") {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external returns (uint256 lpTokens) {
        require(amountA > 0 && amountB > 0, "Zero amount");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        if (totalSupply() == 0) {
            lpTokens = sqrt(amountA * amountB);
        } else {
            lpTokens = min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }

        _mint(msg.sender, lpTokens);

        reserveA += amountA;
        reserveB += amountB;

        emit Mint(msg.sender, amountA, amountB, lpTokens);
    }

    function removeLiquidity(
        uint256 lpAmount
    ) external returns (uint256 amountA, uint256 amountB) {
        require(lpAmount > 0, "Zero LP amount");

        amountA = (lpAmount * reserveA) / totalSupply();
        amountB = (lpAmount * reserveB) / totalSupply();

        _burn(msg.sender, lpAmount);

        reserveA -= amountA;
        reserveB -= amountB;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit Burn(msg.sender, amountA, amountB, lpAmount);
    }

    function swap(
        address tokenIn,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");

        bool isAtoB = tokenIn == address(tokenA);
        require(isAtoB || tokenIn == address(tokenB), "Invalid token");

        (
            IERC20 fromToken,
            IERC20 toToken,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isAtoB
                ? (tokenA, tokenB, reserveA, reserveB)
                : (tokenB, tokenA, reserveB, reserveA);

        fromToken.transferFrom(msg.sender, address(this), amountIn);

        uint256 amountInWithFee = (amountIn * (FEE_DENOMINATOR - FEE_PERCENT)) /
            FEE_DENOMINATOR;
        amountOut =
            (amountInWithFee * reserveOut) /
            (reserveIn + amountInWithFee);

        require(amountOut > 0, "Insufficient output");
        toToken.transfer(msg.sender, amountOut);

        if (isAtoB) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }

        emit Swap(msg.sender, tokenIn, amountIn, address(toToken), amountOut);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function sqrt(uint256 x) private pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
