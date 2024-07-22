// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SmartTwitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
    }

    struct Message {
        uint256 id;
        string content;
        address receiver;
        uint256 timestamp;
    }

    uint256 private tweetCounter = 1;
    uint256 private messageCounter = 1;

    mapping(uint256 => Tweet) private tweets;
    mapping(address => Message[]) private messages;
    mapping(address => uint256[]) private tweetsOf;
    mapping(address => mapping(address => bool)) private operators;
    mapping(address => address[]) private following;

    event TweetCreated(
        uint256 indexed id,
        address indexed author,
        string content,
        uint256 timestamp
    );
    event MessageSent(
        uint256 indexed id,
        string content,
        address indexed sender,
        address indexed receiver,
        uint256 timestamp
    );
    event OperatorAllowed(address indexed owner, address indexed operator);
    event OperatorDisallowed(address indexed owner, address indexed operator);
    event Followed(address indexed follower, address indexed followed);

    modifier onlyOwnerOrOperator(address _from) {
        require(
            _from == msg.sender || operators[_from][msg.sender],
            "You don't have access"
        );
        _;
    }

    function _tweet(address _from, string memory _content)
        internal
        onlyOwnerOrOperator(_from)
    {
        require(bytes(_content).length > 0, "Content cannot be empty");
        tweets[tweetCounter] = Tweet(
            tweetCounter,
            _from,
            _content,
            block.timestamp
        );
        tweetsOf[_from].push(tweetCounter);
        emit TweetCreated(tweetCounter, _from, _content, block.timestamp);
        tweetCounter++;
    }

    function _sendMessage(
        address _from,
        address _to,
        string memory _content
    ) internal onlyOwnerOrOperator(_from) {
        require(_to != address(0), "Receiver address cannot be zero");
        require(bytes(_content).length > 0, "Content cannot be empty");
        messages[_from].push(
            Message(messageCounter, _content, _to, block.timestamp)
        );
        emit MessageSent(messageCounter, _content, _from, _to, block.timestamp);
        messageCounter++;
    }

    function tweet(string memory _content) external {
        _tweet(msg.sender, _content);
    }

    function tweetFrom(address _from, string memory _content) external {
        _tweet(_from, _content);
    }

    function sendMessage(string memory _content, address _to) external {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessageFrom(
        address _from,
        address _to,
        string memory _content
    ) external {
        _sendMessage(_from, _to, _content);
    }

    function allowOperator(address _operator) external {
        operators[msg.sender][_operator] = true;
        emit OperatorAllowed(msg.sender, _operator);
    }

    function disallowOperator(address _operator) external {
        operators[msg.sender][_operator] = false;
        emit OperatorDisallowed(msg.sender, _operator);
    }

    function follow(address _followed) external {
        require(_followed != address(0), "Cannot follow zero address");
        following[msg.sender].push(_followed);
        emit Followed(msg.sender, _followed);
    }

    function getLatestTweets(uint256 count)
        external
        view
        returns (Tweet[] memory)
    {
        uint256 availableCount = tweetCounter > count
            ? count
            : tweetCounter - 1;
        Tweet[] memory tweetList = new Tweet[](availableCount);
        for (uint256 i = 0; i < availableCount; i++) {
            tweetList[i] = tweets[tweetCounter - i - 1];
        }
        return tweetList;
    }

    function getLatestTweetsOf(address user, uint256 count)
        external
        view
        returns (Tweet[] memory)
    {
        uint256 length = tweetsOf[user].length;
        uint256 availableCount = length > count ? count : length;
        Tweet[] memory tweetsOfUser = new Tweet[](availableCount);
        for (uint256 i = 0; i < availableCount; i++) {
            tweetsOfUser[i] = tweets[tweetsOf[user][length - i - 1]];
        }
        return tweetsOfUser;
    }
}
