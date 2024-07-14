// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Vote {
    // Define the voter structure
    struct Voter {
        string name;
        uint8 age;
        uint256 voterId;
        Gender gender;
        uint256 voteCandidateId; //candidate id to whom the voter has voted
        address voterAddress; //EOA of the voter
    }

    // Define the candidate structure
    struct Candidate {
        string name;
        string party;
        uint8 age;
        Gender gender;
        uint256 candidateId;
        address candidateAddress; //candidate EOA
        uint256 votes; //number of votes
    }

    // Election commissioner's address
    address public electionCommission;

    // Address of the winner
    address public winner;

    // Counters for next voter and candidate IDs
    uint256 private nextVoterId = 1;
    uint256 private nextCandidateId = 1;

    // Voting period parameters
    uint256 startTime;
    uint256 endTime;
    bool stopVoting;

    // Mappings to store voters and candidates details
    mapping(uint256 => Voter) private voterDetails;
    mapping(uint256 => Candidate) private candidateDetails;

    enum VotingStatus {
        NotStarted,
        InProgress,
        Ended
    }
    enum Gender {
        NotSpecified,
        Male,
        Female,
        Other
    }

    // Event declarations for logging
    event CandidateRegistered(
        uint256 candidateId,
        string name,
        string party,
        uint8 age,
        Gender gender,
        address candidateAddress
    );
    event VoterRegistered(
        uint256 voterId,
        string name,
        uint8 age,
        Gender gender,
        address voterAddress
    );
    event VoteCasted(uint256 voterId, uint256 candidateId);
    event VotingPeriodSet(uint256 startTime, uint256 endTime);
    event VotingStopped();
    event VotingResultAnnounced(address winner, uint256 votes);

    // Constructor to set the election commissioner
    constructor() {
        electionCommission = msg.sender; //msg.sender is a global variable
    }

    // Modifier to restrict access to the commissioner
    modifier onlyCommissioner() {
        require(msg.sender == electionCommission, "Not authorized");
        _;
    }

    // Modifier to validate age
    modifier isValidAge(uint8 _age) {
        require(_age >= 18, "Not eligible for voting");
        _;
    }

    // Function to register a candidate
    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint8 _age,
        Gender _gender
    ) external isValidAge(_age) {
        require(isCandidateNotRegistered(msg.sender), "Already registered");
        require(nextCandidateId < 3, "Candidate registration full");
        require(
            msg.sender != electionCommission,
            "Commissioner cannot register"
        );

        candidateDetails[nextCandidateId] = Candidate({
            name: _name,
            party: _party,
            age: _age,
            gender: _gender,
            candidateId: nextCandidateId,
            candidateAddress: msg.sender,
            votes: 0
        });

        emit CandidateRegistered(
            nextCandidateId,
            _name,
            _party,
            _age,
            _gender,
            msg.sender
        );
        nextCandidateId++;
    }

    // Function to check if a candidate is not registered
    function isCandidateNotRegistered(address _person)
        private
        view
        returns (bool)
    {
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
        return true;
    }

    // Function to register a voter
    function registerVoter(
        string calldata _name,
        uint8 _age,
        Gender _gender
    ) external isValidAge(_age) {
        require(isVoterNotRegistered(msg.sender), "Already registered");

        voterDetails[nextVoterId] = Voter({
            name: _name,
            age: _age,
            voterId: nextVoterId,
            gender: _gender,
            voteCandidateId: 0,
            voterAddress: msg.sender
        });

        emit VoterRegistered(nextVoterId, _name, _age, _gender, msg.sender);
        nextVoterId++;
    }

    // Function to check if a voter is not registered
    function isVoterNotRegistered(address _person) private view returns (bool) {
        for (uint256 i = 1; i < nextVoterId; i++) {
            if (voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
    }

    // Function to get the list of candidates
    function getCandidateList() external view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1);
        for (uint256 i = 0; i < candidateList.length; i++) {
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
    }

    // Function to get the list of voters
    function getVoterList() external view returns (Voter[] memory) {
        Voter[] memory voterList = new Voter[](nextVoterId - 1);
        for (uint256 i = 0; i < voterList.length; i++) {
            voterList[i] = voterDetails[i + 1];
        }
        return voterList;
    }

    // Function to cast a vote
    function castVote(uint256 _voterId, uint256 _candidateId) external {
        require(
            getVotingStatus() == VotingStatus.InProgress,
            "Voting not in progress"
        );
        require(voterDetails[_voterId].voteCandidateId == 0, "Already voted");
        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "Not authorized"
        );
        require(
            _candidateId >= 1 && _candidateId < nextCandidateId,
            "Invalid candidate ID"
        );

        voterDetails[_voterId].voteCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;

        emit VoteCasted(_voterId, _candidateId);
    }

    // Function to set the voting period
    function setVotingPeriod(
        uint256 _startTimeDuration,
        uint256 _endTimeDuration
    ) external onlyCommissioner {
        require(_endTimeDuration >= 3600, "End time must be >= 1 hour");

        startTime = block.timestamp + _startTimeDuration;
        endTime = startTime + _endTimeDuration;

        emit VotingPeriodSet(startTime, endTime);
    }

    // Function to get the current voting status
    function getVotingStatus() public view returns (VotingStatus) {
        if (startTime == 0) {
            return VotingStatus.NotStarted;
        } else if (
            block.timestamp >= startTime &&
            block.timestamp <= endTime &&
            !stopVoting
        ) {
            return VotingStatus.InProgress;
        } else {
            return VotingStatus.Ended;
        }
    }

    // Function to stop voting in an emergency
    function emergencyStopVoting() external onlyCommissioner {
        stopVoting = true;
        emit VotingStopped();
    }

    // Function to announce the voting result
    function announceVotingResult() external onlyCommissioner {
        require(getVotingStatus() == VotingStatus.Ended, "Voting not ended");

        uint256 maxVotes = 0;
        address winningCandidate;

        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].votes > maxVotes) {
                maxVotes = candidateDetails[i].votes;
                winningCandidate = candidateDetails[i].candidateAddress;
            }
        }

        winner = winningCandidate;
        emit VotingResultAnnounced(winner, maxVotes);
    }
}
