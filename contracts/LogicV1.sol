// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LogicV1 {
    uint number;

    function setNumber(uint num) external returns (bool) {
        number = num;
        return true;
    }

    function getNumber() external view returns (uint) {
        return number;
    }
}
