// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract MyERC20 is IERC20 {
    uint256 public override totalSupply;
    uint8 public decimals;
    string public name;
    string public symbol;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor() {
        totalSupply = 1000;
        decimals = 0;
        name = "RanToken";
        symbol = "RTK";
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "ERC20: value must be greater than zero");
        require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "ERC20: value must be greater than zero");
        require(
            allowances[from][msg.sender] >= value,
            "ERC20: transfer amount exceeds allowance"
        );
        require(balanceOf[from] >= value, "ERC20: insufficient balance");

        allowances[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
        return true;
    }
}
