// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Lottery is ReentrancyGuard {
    address public manager;
    address[] public participants;

    constructor() payable {
        manager = msg.sender;
    }

    //  Modifier to restrict access to manager-only functions
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can perform this action"
        );
        _;
    }

    receive() external payable {
        require(
            msg.value == 1 ether,
            "Amount needed to register must be exactly 1 ether"
        );
        participants.push(msg.sender);
    }

    function getBalance() external view onlyManager returns (uint256) {
        return address(this).balance;
    }

    // Function to generate a pseudo-random number
    function getRandomNumber() private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.coinbase,
                    block.gaslimit,
                    block.prevrandao,
                    msg.sender,
                    block.number,
                    participants.length
                )
            )
        );
        return seed % participants.length;
    }

    // Function to announce the lottery result and transfer the balance to the winner
    function announceWinner()
        external
        onlyManager
        nonReentrant
        returns (address)
    {
        require(
            participants.length >= 5,
            "Number of participants must be at least 5"
        );

        uint256 randomIndex = getRandomNumber();
        address winner = participants[randomIndex];

        payable(winner).transfer(address(this).balance);

        // Reset participants for the next round
        delete participants;
        return winner;
    }
}
