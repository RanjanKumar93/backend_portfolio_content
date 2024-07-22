// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PiggyBank {
    // This keeps track of how much money each person (address) has in the bank;
    mapping(address => uint256) public balances;

    // This function let people put money into the bank
    function deposiot() public payable {
        // Increase the balance of the person who called this function by the amount they sent.
        balances[msg.sender] += msg.value;
    }

    // This function lets people take money out of the bank
    function withdraw(uint256 amount) public {
        // Make sure the person has enough money to take out.
        require(balances[msg.sender] >= amount, "Not enough balance!");

        // Decreas their balance by the amount they want to take out.
        balances[msg.sender] -= amount;

        // Send the money to the person.
        payable(msg.sender).transfer(amount);
    }

    // This function shows how much money a person has in the bank.
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
