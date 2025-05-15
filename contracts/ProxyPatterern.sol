// Challenge 7: Upgradeable Smart Contract (Proxy Pattern)
//  Objective:
// Implement a basic transparent proxy pattern that separates logic and storage, enabling contract upgrades without losing on-chain data. This introduces a common production-ready design used in many DeFi protocols.

// 📘 Expected Skills & Concepts:
// Low-level delegatecall usage

// Understanding storage layout consistency across logic contracts

// Managing admin privileges for upgrades

// fallback() and receive() functions

// constructor logic isolation

// Transparent Proxy vs UUPS Proxy distinction (we’ll do Transparent now)

//  (New): Use of OpenZeppelin contracts optional for comparison/extension

//  Requirements:
// Proxy Contract:

// Stores the address of the logic contract.

// Uses delegatecall to forward all calls to the current implementation.

// Has upgradeTo(address) function callable only by admin.

// Logic Contract (Version 1):

// Has a setNumber(uint) and getNumber() functionality stored in storage slot uint256 number.

// Upgrade:

// Deploy a second version of the logic contract with a new function: incrementNumber().

// Security:

// Only admin can perform the upgrade.

// Prevent storage clashes between proxy and logic contracts.

// Events:

// Emit Upgraded(address newImplementation) on upgrade.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ProxyPatterern {
    address contractAddress;
    uint version;
    address admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin can call this function");
        _;
    }

    event Upgraded(address newImplementation);

    constructor(address _contAdd) {
        require(
            _contAdd.code.length > 0,
            "Please provide a address for a contract"
        );
        contractAddress = _contAdd;
        admin = msg.sender;
        version = 1;
    }

    function upgrateTo(address _contAdd) external onlyAdmin {
        require(
            _contAdd.code.length > 0,
            "Please provide a address for a contract"
        );

        contractAddress = _contAdd;
        version += 1;
        emit Upgraded(_contAdd);
    }

    function getVersion() external view returns (uint) {
        return version;
    }

    fallback() external {
        address impl = contractAddress;
        require(impl != address(0), "Implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
