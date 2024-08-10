// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MessageCenterContract {
    struct WorldMessage {
        uint256 id;
        address author;
        string content;
        uint256 createdAt;
    }

    struct PrivateMessage {
        uint256 id;
        address from;
        address to;
        string content;
        uint256 createdAt;
    }

    mapping(uint256 => WorldMessage) public messages;
    mapping(address => uint256[]) public messagesOf;
    mapping(address => PrivateMessage[]) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public following;

    uint256 public nextId;
    uint256 public nextMessageId;

    event WorldMessageSent(
        uint256 id,
        address indexed author,
        string content,
        uint256 timestamp
    );
    event PrivateMessageSent(
        uint256 id,
        address indexed from,
        address indexed to,
        string content,
        uint256 timestamp
    );
    event Followed(address indexed follower, address indexed followed);
    event OperatorAllowed(address indexed account, address indexed operator);
    event OperatorDisallowed(address indexed account, address indexed operator);

    modifier onlyAllowed(address _from) {
        require(
            msg.sender == _from || operators[_from][msg.sender],
            "Not allowed"
        );
        _;
    }

    function _worldMessageSender(address _from, string memory _content)
        private
    {
        messages[nextId] = WorldMessage(
            nextId,
            _from,
            _content,
            block.timestamp
        );
        messagesOf[_from].push(nextId);
        emit WorldMessageSent(nextId, _from, _content, block.timestamp);
        nextId++;
    }

    function _sendPrivateMessage(
        address _from,
        address _to,
        string memory _content
    ) private {
        conversations[_from].push(
            PrivateMessage(nextMessageId, _from, _to, _content, block.timestamp)
        );
        emit PrivateMessageSent(
            nextMessageId,
            _from,
            _to,
            _content,
            block.timestamp
        );
        nextMessageId++;
    }

    function worldMessageSender(string memory _content) external {
        _worldMessageSender(msg.sender, _content);
    }

    function worldMessageSender(address _from, string memory _content)
        external
        onlyAllowed(_from)
    {
        _worldMessageSender(_from, _content);
    }

    function sendPrivateMessage(address _to, string memory _content) external {
        _sendPrivateMessage(msg.sender, _to, _content);
    }

    function sendPrivateMessage(
        address _from,
        address _to,
        string memory _content
    ) external onlyAllowed(_from) {
        _sendPrivateMessage(_from, _to, _content);
    }

    function follow(address _followed) external {
        require(_followed != msg.sender, "Cannot follow yourself");
        require(!_isFollowing(msg.sender, _followed), "Already following");
        following[msg.sender].push(_followed);
        emit Followed(msg.sender, _followed);
    }

    function allow(address _operator) external {
        operators[msg.sender][_operator] = true;
        emit OperatorAllowed(msg.sender, _operator);
    }

    function disallow(address _operator) external {
        operators[msg.sender][_operator] = false;
        emit OperatorDisallowed(msg.sender, _operator);
    }

    function getLatestWorldMessages(uint256 count)
        external
        view
        returns (WorldMessage[] memory)
    {
        require(count > 0 && count <= nextId, "Invalid count");
        WorldMessage[] memory _messages = new WorldMessage[](count);
        uint256 startIndex = nextId - count;

        for (uint256 i = 0; i < count; i++) {
            WorldMessage storage _structure = messages[startIndex + i];
            _messages[i] = WorldMessage(
                _structure.id,
                _structure.author,
                _structure.content,
                _structure.createdAt
            );
        }
        return _messages;
    }

    function getLatestMessageofUser(address _user, uint256 count)
        public
        view
        returns (WorldMessage[] memory)
    {
        uint256[] memory ids = messagesOf[_user];
        uint256 messagesLength = ids.length;
        require(count > 0 && count <= messagesLength, "Invalid count");
        WorldMessage[] memory _messages = new WorldMessage[](count);
        uint256 startIndex = messagesLength - count;

        for (uint256 i = 0; i < count; i++) {
            WorldMessage storage _structure = messages[ids[startIndex + i]];
            _messages[i] = WorldMessage(
                _structure.id,
                _structure.author,
                _structure.content,
                _structure.createdAt
            );
        }
        return _messages;
    }

    function _isFollowing(address _follower, address _followed)
        private
        view
        returns (bool)
    {
        address[] memory _followings = following[_follower];
        for (uint256 i = 0; i < _followings.length; i++) {
            if (_followings[i] == _followed) {
                return true;
            }
        }
        return false;
    }
}
