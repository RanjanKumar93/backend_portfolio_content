// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimplePersonalWallet {
    address public owner;

    event FundsSent(address indexed receiver, uint256 amount);
    event FundsReceived(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have access");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Allows the owner to deposit funds to the contract
    function deposit() external payable onlyOwner {
        require(msg.value > 0, "Value must be greater than zero");
        emit FundsReceived(msg.sender, msg.value);
    }

    // Allows the owner to transfer funds from the contract to a specified address
    function transfer(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid address");
        require(address(this).balance >= _amount, "Insufficient Balance");
        _to.transfer(_amount);
        emit FundsSent(_to, _amount);
    }

    // Allows the owner to withdraw funds from the contract
    function withdraw(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insuffficient balance");
        payable(owner).transfer(_amount);
        emit FundsSent(owner, _amount);
    }

    // Returns the balance of the contract in wei
    function getContractBalanceInWei() external view returns (uint256) {
        return address(this).balance;
    }

    // Allows anyone to send funds to the contract
    function receiveFunds() external payable {
        require(msg.value > 0, "Value must be greater than zero");
        emit FundsReceived(msg.sender, msg.value);
    }

    // Fallback function to handle unexpected calls
    // fallback() external payable {
    //     emit FundsReceived(msg.sender, msg.value);
    // }

    // Fallback function to receive funds
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
}
