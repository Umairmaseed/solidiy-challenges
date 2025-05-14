// Challenge 5: Time-Locked Escrow Contract
// bjective:
// Create a simple escrow smart contract where a payer can deposit ETH, and the payee can claim it only after a specific unlock time. The payer can cancel and withdraw the funds before the unlock time if needed.

// Expected Skills & Concepts:
// ETH transfer mechanics (payable, address(this).balance, transfer)

// block.timestamp for time-based conditions

// Modifiers for role-based access control

// Mappings for multiple escrows

// Events for deposit and withdrawal tracking

// Require statements for contract state validation

// (Optional) Reentrancy guards (nonReentrant pattern if using call or send)

// Requirements:
// Create Escrow:

// The payer deposits ETH and specifies the payee and unlock time.

// Use a struct to track each escrow deal.

// Withdraw Funds:

// Only the payee can withdraw after the unlock time.

// Cancel Escrow:

// The payer can cancel and retrieve funds before the unlock time.

// Event Logging:

// Emit events for deposit, withdrawal, and cancellation.

// Edge Case Handling:

// Handle attempts to withdraw early, cancel late, or replay the same escrow.

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract TimeLockEscrow {
    struct Escrow {
        uint amount;
        uint time;
        address sender;
        bool payed;
        bool canceled;
    }

    mapping(address => Escrow[]) escrowListing;

    event PaymentLocked(
        address sender,
        address receiver,
        uint lockTime,
        uint amount
    );
    event AmountWithdraw(address receiver, uint time, uint amount);
    event AmountReturn(address sender, address receiver, uint amount);

    function lockPayment(
        uint timeSeconds,
        address receiver
    ) external payable returns (bool) {
        require(msg.value > 0, "Cant Lock 0 ETh");
        require(timeSeconds > 0, "Cant lock Eth for 0 seconds");

        Escrow[] storage receiverEscrows = escrowListing[receiver];

        receiverEscrows.push(
            Escrow({
                amount: msg.value,
                time: block.timestamp + timeSeconds,
                sender: msg.sender,
                payed: false,
                canceled: false
            })
        );

        emit PaymentLocked(
            msg.sender,
            receiver,
            block.timestamp + timeSeconds,
            msg.value
        );
        return true;
    }

    function withdrawAmount() external returns (bool) {
        Escrow[] storage userEscrows = escrowListing[msg.sender];

        require(userEscrows.length > 0, "No escrow found");

        uint amount = 0;

        for (uint i = 0; i < userEscrows.length; i++) {
            if (
                userEscrows[i].time < block.timestamp &&
                !userEscrows[i].payed &&
                !userEscrows[i].canceled
            ) {
                amount += userEscrows[i].amount;
                userEscrows[i].payed = true;
            }
        }

        require(amount > 0, "No amount is yet unlocked for withdrawal");

        payable(msg.sender).transfer(amount);

        emit AmountWithdraw(msg.sender, amount, block.timestamp);

        return true;
    }

    function cancelLockAmount(address account) external returns (bool) {
        Escrow[] storage userEscrows = escrowListing[account];
        uint amount = 0;
        for (uint i = 0; i < userEscrows.length; i++) {
            if (
                userEscrows[i].sender == msg.sender &&
                userEscrows[i].time > block.timestamp
            ) {
                require(
                    userEscrows[i].canceled == false,
                    "The locked amount is already cancelled and returned"
                );
                userEscrows[i].canceled = true;
                amount += userEscrows[i].amount;
                payable(msg.sender).transfer(userEscrows[i].amount);
            }
        }
        emit AmountReturn(msg.sender, account, amount);
        return true;
    }
}
