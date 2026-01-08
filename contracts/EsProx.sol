// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EscrowProxy {
    address public buyer;
    address public seller;
    address public arbiter;
    uint public amount;
    bool public funded;

    address public implementation;

    constructor(address _implementation) {
        require(_implementation != address(0), "Invalid implementation");
        implementation = _implementation;
    }

    receive() external payable {}

    function initialize(
        address _buyer,
        address _seller,
        address _arbiter
    ) external {
        (bool ok, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "initialize(address,address,address)",
                _buyer,
                _seller,
                _arbiter
            )
        );
        require(ok, "Initialization failed");
    }

    function deposit() external payable {
        (bool ok, ) = implementation.delegatecall(
            abi.encodeWithSignature("deposit()")
        );
        require(ok, "Deposit failed");
    }

    function release() external {
        (bool ok, ) = implementation.delegatecall(
            abi.encodeWithSignature("release()")
        );
        require(ok, "Release failed");
    }

    function refund() external {
        (bool ok, ) = implementation.delegatecall(
            abi.encodeWithSignature("refund()")
        );
        require(ok, "Refund failed");
    }
}
