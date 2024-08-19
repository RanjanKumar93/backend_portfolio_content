// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HotelRoomBooking {
    enum Statuses {
        Vacant,
        Occupied
    }
    Statuses public currentStatus;

    uint256 public timeTotal;
    uint256 public price;

    event Occupy(address indexed _occupant, uint256 _value);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Statuses.Vacant;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Not allowed: Only owner can execute this"
        );
        _;
    }

    modifier onlyWhileVacant() {
        require(currentStatus == Statuses.Vacant, "Room is currently occupied");
        _;
    }
    modifier onlyWhileOccupied() {
        require(currentStatus == Statuses.Occupied, "Room is not occupied");
        _;
    }

    modifier costs(uint256 _amount) {
        require(msg.value >= _amount, "Insufficient Ether provided");
        _;
    }

    modifier canBeRemoved() {
        require(block.timestamp > timeTotal, "Booking cannot be removed yet");
        _;
    }

    function setPrice(uint256 _price) external onlyOwner onlyWhileVacant {
        require(_price > 0, "Price must be greater than 0");
        price = _price;
    }

    function book() external payable onlyWhileVacant costs(price) {
        currentStatus = Statuses.Occupied;

        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        timeTotal = block.timestamp + 1 days;
        emit Occupy(msg.sender, msg.value);
    }

    function removeBooking() external onlyOwner onlyWhileOccupied canBeRemoved {
        currentStatus = Statuses.Vacant;
        timeTotal = 0;
    }

    receive() external payable {
        revert("Direct Ether transfers not allowed");
    }

    fallback() external payable {
        revert("Direct Ether transfers not allowed");
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available for withdrawal");

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to withdraw Ether");
    }
}
