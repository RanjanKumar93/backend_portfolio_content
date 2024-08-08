// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniVotingSystem {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    uint public constant MAX_CANDIDATES = 10;
    Candidate[] public candidateList;
    mapping(address => bool) public hasVoted;
    mapping(uint => uint) public totalVotes;
    uint public candidateCount;
    bool public isVotingActive;

    modifier onlyWhenVotingActive() {
        require(isVotingActive, "Voting is not active");
        _;
    }

    function registerCandidate(string memory _name) public {
        require(candidateCount < MAX_CANDIDATES, "Maximum candidates reached");
        candidateList.push(Candidate(candidateCount, _name, 0));
        candidateCount++;
    }

    function startVoting() public {
        isVotingActive = true;
    }

    function endVoting() public {
        isVotingActive = false;
    }

    function castVote(uint _candidateId) public onlyWhenVotingActive {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateId < candidateCount, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidateList[_candidateId].voteCount++;
        totalVotes[_candidateId]++;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        return candidateList;
    }

    function getWinner() public view returns (string memory winnerName) {
        uint maxVotes = 0;
        uint winnerId;
        for (uint i = 0; i < candidateCount; i++) {
            if (candidateList[i].voteCount > maxVotes) {
                maxVotes = candidateList[i].voteCount;
                winnerId = i;
            }
        }
        winnerName = candidateList[winnerId].name;
    }
}
