// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ToDoList {
    using SafeMath for uint256;

    struct Task {
        uint256 id;
        string content;
        bool completed;
    }

    // Track tasks for each user
    mapping(address => mapping(uint256 => Task)) private tasks;
    // Track task count for each user
    mapping(address => uint256) private taskCounts;

    event TaskCreated(
        address indexed user,
        uint256 indexed taskId,
        string content,
        bool completed
    );
    event TaskStatusToggled(
        address indexed user,
        uint256 indexed taskId,
        string content,
        bool completed
    );

    event TaskStatusToggled(
        uint256 indexed taskId,
        string content,
        bool completed
    );

    constructor() {
        // Initialize with an example task for the contract deployer
        _createTask(msg.sender, "Initial Task");
    }

    function _createTask(address _user, string memory _content) private {
        uint256 taskId = taskCounts[_user];
        tasks[_user][taskId] = Task(taskId, _content, false);
        emit TaskCreated(_user, taskId, _content, false);
        taskCounts[_user] = taskCounts[_user].add(1);
    }

    function createTask(string memory _content) external {
        _createTask(msg.sender, _content);
    }

    function toggleTaskCompleted(uint256 _taskId) external {
        require(_taskId < taskCounts[msg.sender], "Invalid task ID");
        Task storage task = tasks[msg.sender][_taskId];
        task.completed = !task.completed;
        emit TaskStatusToggled(
            msg.sender,
            _taskId,
            task.content,
            task.completed
        );
    }

    function getTask(uint256 _taskId)
        external
        view
        returns (
            uint256 id,
            string memory content,
            bool completed
        )
    {
        require(_taskId < taskCounts[msg.sender], "Invalid task ID");
        Task storage task = tasks[msg.sender][_taskId];
        return (task.id, task.content, task.completed);
    }

    function getTaskCount() external view returns (uint256) {
        return taskCounts[msg.sender];
    }
}
