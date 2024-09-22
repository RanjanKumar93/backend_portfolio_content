// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

contract MyToken is IERC20 {
    address public contractOwner;
    uint256 public override totalSupply;
    uint8 public decimals;
    string public name;
    string public symbol;
    bool public isPaused = false;
    address[] public blacklist;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public isFrozen;
    mapping(address => bool) private addressExistsInBlacklist;

    event Minted(address indexed account, uint256 amount);
    event Burned(address indexed account, uint256 amount);
    event Paused();
    event Unpaused();
    event FrozenAccount(address indexed account);
    event UnfrozenAccount(address indexed account);
    event blacklistAccount(address indexed account);
    event unBlacklistAccount(address indexed account);

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private status;

    modifier nonReentrant() {
        require(status != ENTERED, "ReentrancyGuard: reentrant call");
        status = ENTERED;
        _;
        status = NOT_ENTERED;
    }

    constructor() {
        contractOwner = msg.sender;
        totalSupply = 1_000_000 * 10**18;
        decimals = 18;
        name = "MyToken";
        symbol = "MTK";
        balanceOf[msg.sender] = totalSupply;

        status = NOT_ENTERED;
    }

    modifier onlyOwner() {
        require(
            msg.sender == contractOwner,
            "Ownable: caller is not the owner"
        );
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    modifier whenAccountNotStopped(address account) {
        require(
            !isFrozen[account] && !addressExistsInBlacklist[account],
            "Account is stopped"
        );
        _;
    }

    function transfer(address to, uint256 value)
        external
        override
        whenNotPaused
        whenAccountNotStopped(msg.sender)
        whenAccountNotStopped(to)
        nonReentrant
        returns (bool)
    {
        require(to != address(0), "Invalid address");
        require(value > 0, "Transfer value must be greater than zero");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

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
        public
        override
        whenNotPaused
        whenAccountNotStopped(msg.sender)
        whenAccountNotStopped(spender)
        returns (bool success)
    {
        require(spender != address(0), "Invalid spender address");
        require(value > 0, "Value must be greater than zero");

        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        override
        whenNotPaused
        whenAccountNotStopped(from)
        whenAccountNotStopped(msg.sender)
        whenAccountNotStopped(to)
        nonReentrant
        returns (bool)
    {
        require(to != address(0), "Invalid address");
        require(value > 0, "Transfer value must be greater than zero");
        require(
            allowances[from][msg.sender] >= value,
            "Transfer exceeds allowance"
        );
        require(balanceOf[from] >= value, "Insufficient balance");

        allowances[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
        return true;
    }

    function mint(address account, uint256 value)
        external
        onlyOwner
        whenNotPaused
        whenAccountNotStopped(account)
    {
        require(account != address(0), "Invalid account address");
        require(value > 0, "Value must be greater than zero");

        totalSupply += value;
        balanceOf[account] += value;

        emit Minted(account, value);
    }

    function burn(uint256 amount)
        external
        whenNotPaused
        whenAccountNotStopped(msg.sender)
    {
        require(amount > 0, "Amount must be greater than zero");
        require(
            balanceOf[msg.sender] >= amount,
            "Insufficient balance to burn"
        );

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burned(msg.sender, amount);
    }

    function freezeAccount(address account) external onlyOwner {
        require(!isFrozen[account], "Account already frozen");

        isFrozen[account] = true;
        emit FrozenAccount(account);
    }

    function unfreezeAccount(address account) external onlyOwner {
        require(isFrozen[account], "Account not frozen");

        isFrozen[account] = false;
        emit UnfrozenAccount(account);
    }

    function pause() external onlyOwner {
        require(!isPaused, "Contract already paused");

        isPaused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        require(isPaused, "Contract is not paused");

        isPaused = false;
        emit Unpaused();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        contractOwner = newOwner;
    }

    function addToBlacklist(address account) external onlyOwner {
        require(account != address(0), "Invalid account address");
        require(!addressExistsInBlacklist[account], "Address already exists");
        blacklist.push(account);
        addressExistsInBlacklist[account] = true;
        emit blacklistAccount(account);
    }

    function unblacklist(address account) external onlyOwner {
        require(account != address(0), "Invalid account address");
        require(addressExistsInBlacklist[account], "Address not in blacklist");
        uint256 length = blacklist.length;

        for (uint256 i = 0; i < length; i++) {
            if (blacklist[i] == account) {
                blacklist[i] = blacklist[length - 1];
                blacklist.pop();
                addressExistsInBlacklist[account] = false;
                emit unBlacklistAccount(account);
                return;
            }
        }
    }
}
