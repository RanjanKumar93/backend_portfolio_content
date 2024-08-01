// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimplePersonalWallet {
    address private owner;

    struct Transaction {
        address from;
        address to;
        uint256 timestamp;
        uint256 amount;
    }

    bool private emergencyStop;

    bool private _entered;

    Transaction[] public transactionHistory;

    event FundsSent(address indexed receiver, uint256 amount);
    event FundsReceived(address indexed sender, uint256 amount);
    event EmergencyToggled(bool status);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have access");
        _;
    }

    modifier emergencyCheck() {
        require(!emergencyStop, "Emergency declared");
        _;
    }

    modifier nonReentrant() {
        require(!_entered, "ReentrancyGuard: reentrant call");
        _entered = true;
        _;
        _entered = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function toggleEmergency() external onlyOwner {
        emergencyStop = !emergencyStop;
        emit EmergencyToggled(emergencyStop);
    }

    // Allows the owner to deposit funds to the contract
    function deposit() external payable onlyOwner emergencyCheck {
        require(msg.value > 0, "Value must be greater than zero");
        transactionHistory.push(
            Transaction(owner, address(this), block.timestamp, msg.value)
        );
        emit FundsReceived(owner, msg.value);
    }

    function changeOwner(address newOwner) external onlyOwner emergencyCheck {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    // Allows the owner to transfer funds from the contract to a specified address
    function transfer(address payable _to, uint256 _amount)
        external
        onlyOwner
        emergencyCheck
        nonReentrant
    {
        require(_to != address(0), "Invalid address");
        require(address(this).balance >= _amount, "Insufficient Balance");
        transactionHistory.push(
            Transaction(owner, _to, block.timestamp, _amount)
        );
        emit FundsSent(_to, _amount);
        _to.transfer(_amount);
    }

    // Allows the owner to withdraw funds from the contract
    function withdraw(uint256 _amount)
        external
        onlyOwner
        emergencyCheck
        nonReentrant
    {
        require(address(this).balance >= _amount, "Insufficient balance");
        transactionHistory.push(
            Transaction(address(this), owner, block.timestamp, _amount)
        );
        emit FundsSent(owner, _amount);
        payable(owner).transfer(_amount);
    }

    // Returns the balance of the contract in wei
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Allows anyone to send funds to the contract
    function receiveFunds() external payable emergencyCheck nonReentrant {
        require(msg.value > 0, "Value must be greater than zero");
        transactionHistory.push(
            Transaction(msg.sender, address(this), block.timestamp, msg.value)
        );
        emit FundsReceived(msg.sender, msg.value);
    }

    // Fallback function to handle unexpected calls
    fallback() external payable emergencyCheck nonReentrant {
        // Returning the funds to the sender
        require(msg.value > 0, "Value must be greater than zero");
        emit FundsReceived(msg.sender, msg.value);
        emit FundsSent(msg.sender, msg.value);
        payable(msg.sender).transfer(msg.value);
    }

    // Fallback function to receive funds
    receive() external payable emergencyCheck nonReentrant {
        transactionHistory.push(
            Transaction(msg.sender, address(this), block.timestamp, msg.value)
        );
        emit FundsReceived(msg.sender, msg.value);
    }
}
