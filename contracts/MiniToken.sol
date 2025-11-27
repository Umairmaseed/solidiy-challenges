// SPDX-License-Identifier: UNLICENSEd
pragma solidity ^0.8.0;

contract MiniToken {
    mapping(address => uint256) public balances;
    address public owner;
    string public name;
    string public symbol;
    uint public totalSupply;
    uint public tokenMinted;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Mint(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner have the rights for this functionality"
        );
        _;
    }

    constructor(string memory token, string memory symb, uint supply) {
        owner = msg.sender;
        name = token;
        symbol = symb;
        totalSupply = supply;
    }

    function mint(uint amount) public onlyOwner {
        require(
            tokenMinted + amount <= totalSupply,
            "The amount exceed the total supply of the token"
        );
        tokenMinted += amount;
        balances[msg.sender] += amount;
        emit Mint(msg.sender, amount);
    }

    function transfer(uint amount, address to) public {
        require(
            amount <= balances[msg.sender],
            "Your balance is insufficient for this transaction"
        );

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}
