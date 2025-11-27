// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AccessManager {
    address public owner;

    mapping(address => bool) public isAuthorized;
    event authorized(address indexed user, uint time);
    event unAuthorized(address indexed user, uint time);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner can execute the contract functionality"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function authorize(address user) public onlyOwner {
        if (isAuthorized[user] == true) {
            // return error saying already authorized
        }

        isAuthorized[user] = true;
        emit authorized(user, block.timestamp);
    }

    function unAuthorize(address user) public onlyOwner {
        if (isAuthorized[user] == false) {
            // return error saying already unAuthorize
        }

        isAuthorized[user] = false;
        emit unAuthorized(user, block.timestamp);
    }

    function checkStatus() public view returns (bool) {
        require(
            isAuthorized[msg.sender] == true,
            "You are not authorized for this contract"
        );
        return true;
    }

    function protectedAction() public view returns (string memory) {
        require(
            isAuthorized[msg.sender] == true,
            "You are not authorized for protection"
        );

        return "Access granted";
    }
}
