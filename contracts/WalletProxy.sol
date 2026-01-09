// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WalletProxy {
    address public owner; // slot 0
    uint256 public balance; // slot 1
    address public implementation; // slot 2

    constructor(address _implementation) {
        implementation = _implementation;

        (bool ok, ) = _implementation.delegatecall(
            abi.encodeWithSignature("initialize(address)", msg.sender)
        );
        require(ok, "Init failed");
    }

    fallback() external payable {
        (bool ok, bytes memory data) = implementation.delegatecall(msg.data);
        require(ok, "Delegatecall failed");

        assembly {
            return(add(data, 32), mload(data))
        }
    }

    receive() external payable {}
}
