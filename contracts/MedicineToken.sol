// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MedicineToken is ERC20 {
    address public owner;

    constructor() ERC20("MedicineToken", "MT") {
        owner = msg.sender;
    
    }

    modifier onlyOwner() {
        require(tx.origin == owner, "Only owner can perform this action");
        _;
    }

    function mint(address _to, uint256 _amount) public  onlyOwner {
        _mint(_to, _amount);
    }

    function approve(uint256 _amount) public {
        _approve(tx.origin, msg.sender, _amount);
    }
    function getBalance() public view returns (uint256 balance) {
        return balanceOf(tx.origin);
    }
    
}