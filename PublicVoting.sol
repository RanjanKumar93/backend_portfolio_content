// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PublicVoting is Ownable, ReentrancyGuard {
    struct Proposal {
        uint256 proposalId;
        string title;
        string description;
        uint256 voteCount;
        bool isAllowed;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Tracks if a user has voted on a specific proposal
    uint256 public proposalCount;

    // Events
    event ProposalCreated(
        uint256 indexed proposalId,
        string title,
        string description
    );
    event ProposalAllowed(uint256 indexed proposalId);
    event Voted(uint256 indexed proposalId, address indexed voter);

    // Constructor initializes ownership
    constructor(address initialOwner) Ownable(initialOwner) {}

    // Create a new proposal
    function createProposal(string memory title, string memory description)
        external
    {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");

        proposals[proposalCount] = Proposal({
            proposalId: proposalCount,
            title: title,
            description: description,
            voteCount: 0,
            isAllowed: false,
            exists: true
        });

        emit ProposalCreated(proposalCount, title, description);

        proposalCount++;
    }

    // Allow a proposal to be voted on (onlyOwner)
    function allowProposal(uint256 proposalId) external onlyOwner {
        require(proposals[proposalId].exists, "Proposal does not exist");
        require(
            !proposals[proposalId].isAllowed,
            "Proposal is already allowed"
        );

        proposals[proposalId].isAllowed = true;

        emit ProposalAllowed(proposalId);
    }

    // Vote on a proposal
    function vote(uint256 proposalId) external nonReentrant {
        require(proposals[proposalId].exists, "Proposal does not exist");
        require(
            proposals[proposalId].isAllowed,
            "Proposal is not allowed for voting"
        );
        require(
            !hasVoted[proposalId][msg.sender],
            "You have already voted on this proposal"
        );

        proposals[proposalId].voteCount++;
        hasVoted[proposalId][msg.sender] = true;

        emit Voted(proposalId, msg.sender);
    }

    // Fetch proposal details
    function getProposal(uint256 proposalId)
        external
        view
        returns (Proposal memory)
    {
        require(proposals[proposalId].exists, "Proposal does not exist");
        return proposals[proposalId];
    }
}
