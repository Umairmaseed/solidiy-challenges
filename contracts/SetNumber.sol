// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract SetNumber {
    uint private num;

    function setNum(uint _num) external {
        num = _num;
    }
}
