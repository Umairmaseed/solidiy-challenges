// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract NumDelegate {
    uint public num; // SLOT 0 (must match)
    address public refContract; // SLOT 1

    constructor(address _ref) {
        refContract = _ref;
    }

    function setNumber(uint _num) external {
        (bool success, ) = refContract.delegatecall(
            abi.encodeWithSignature("setNum(uint256)", _num)
        );
        require(success, "Delegatecall failed");
    }
}
