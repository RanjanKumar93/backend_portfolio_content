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

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public isFrozen;

    event Minted(address indexed account, uint256 amount);
    event Burned(address indexed account, uint256 amount);
    event Paused();
    event Unpaused();
    event FrozenAccount(address indexed account);
    event UnfrozenAccount(address indexed account);

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
        totalSupply = 1_000_000 * 10**18; // 1 million tokens with 18 decimals
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

    modifier whenAccountNotFrozen(address account) {
        require(!isFrozen[account], "Account is frozen");
        _;
    }

    function transfer(address to, uint256 value)
        external
        override
        whenNotPaused
        whenAccountNotFrozen(msg.sender)
        whenAccountNotFrozen(to)
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
        whenAccountNotFrozen(msg.sender)
        whenAccountNotFrozen(spender)
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
        whenAccountNotFrozen(from)
        whenAccountNotFrozen(msg.sender)
        whenAccountNotFrozen(to)
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
        whenAccountNotFrozen(account)
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
        whenAccountNotFrozen(msg.sender)
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
}

// pragma solidity ^0.8.24;

// interface IERC20 {
//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(
//         address indexed owner,
//         address indexed spender,
//         uint256 value
//     );

//     function totalSupply() external view returns (uint256);

//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address to, uint256 value) external returns (bool);

//     function allowance(address owner, address spender)
//         external
//         view
//         returns (uint256);

//     function approve(
//         address _spender,
//         uint256 _currentValue,
//         uint256 _newValue
//     ) external returns (bool);

//     function transferFrom(
//         address from,
//         address to,
//         uint256 value
//     ) external returns (bool);
// }

// contract MyToken is IERC20 {
//     address public contractOwner;
//     uint256 public override totalSupply;
//     uint8 public decimals;
//     string public name;
//     string public symbol;
//     bool public isPause = false;

//     mapping(address => uint256) public override balanceOf;
//     mapping(address => mapping(address => uint256)) public allowances;
//     mapping(address => bool) public freezedAcc;

//     constructor() {
//         contractOwner = msg.sender;
//         totalSupply = 1000000;
//         decimals = 18;
//         name = "MyToken";
//         symbol = "MTK";
//         balanceOf[contractOwner] = totalSupply;
//     }

//     event Minted(address indexed account, uint256 amount);
//     event Burned(address indexed account, uint256 amount);
//     event FreezedAccount(address indexed account);
//     event UnfreezeAccount(address indexed account);

//     modifier pauseCheck() {
//         require(!isPause, "p");
//         _;
//     }

//     function transfer(address to, uint256 value)
//         external
//         override
//         pauseCheck
//         returns (bool)
//     {
//         require(to != address(0), "ERC20: transfer to the zero address");
//         require(value > 0, "ERC20: value must be greater than zero");
//         require(freezedAcc[msg.sender], "freezed by owner");
//         require(freezedAcc[to], "freezed by owner");
//         require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance");

//         balanceOf[msg.sender] -= value;
//         balanceOf[to] += value;

//         emit Transfer(msg.sender, to, value);
//         return true;
//     }

//     function allowance(address owner, address spender)
//         external
//         view
//         override
//         pauseCheck
//         returns (uint256)
//     {
//         return allowances[owner][spender];
//     }

//     function approve(
//         address _spender,
//         uint256 _currentValue,
//         uint256 _newValue
//     ) public override pauseCheck returns (bool success) {
//         require(freezedAcc[msg.sender], "freezed by owner");
//         require(freezedAcc[_spender], "freezed by owner");
//         if (allowances[msg.sender][_spender] == _currentValue) {
//             allowances[msg.sender][_spender] = _newValue;
//             emit Approval(msg.sender, _spender, _newValue);
//             return true;
//         } else {
//             return false;
//         }
//     }

//     function transferFrom(
//         address from,
//         address to,
//         uint256 value
//     ) external override pauseCheck returns (bool) {
//         require(freezedAcc[msg.sender], "freezed by owner");
//         require(freezedAcc[from], "freezed by owner");
//         require(freezedAcc[to], "freezed by owner");
//         require(to != address(0), "ERC20: transfer to the zero address");
//         require(value > 0, "ERC20: value must be greater than zero");
//         require(
//             allowances[from][msg.sender] >= value,
//             "ERC20: transfer amount exceeds allowance"
//         );
//         require(balanceOf[from] >= value, "ERC20: insufficient balance");

//         allowances[from][msg.sender] -= value;
//         balanceOf[from] -= value;
//         balanceOf[to] += value;

//         emit Transfer(from, to, value);
//         return true;
//     }

//     function mint(address account, uint256 value) external pauseCheck {
//         require(msg.sender == contractOwner, "not allowed");
//         require(freezedAcc[account], "freezed account");
//         require(account != address(0), "ad0");

//         totalSupply += value;
//         balanceOf[account] += value;
//         emit Minted(account, value);
//     }

//     function burn(uint256 amount) external pauseCheck {
//         require(amount > 0, "oooo");
//         require(balanceOf[msg.sender] >= amount, "ooe");

//         balanceOf[msg.sender] -= amount;
//         totalSupply -= amount;
//         emit Burned(msg.sender, amount);
//     }

//     function freezeAccount(address account) external pauseCheck {
//         require(msg.sender == contractOwner, "ab");
//         freezedAcc[account] = false;
//         emit FreezedAccount(account);
//     }

//     function unfreezeAccount(address account) external pauseCheck {
//         require(msg.sender == contractOwner, "ab");
//         freezedAcc[account] = true;
//         emit UnfreezeAccount(account);
//     }

//     function pause() external {
//         require(msg.sender == contractOwner);
//         isPause = true;
//     }
//     function unpause()external {
//         require(msg.sender == contractOwner);
//         isPause = false;
//     }
// }
