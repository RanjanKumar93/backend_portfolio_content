// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Abstract contract
abstract contract Animal {
    string public name;

    // Constructor to set the name of the animal
    constructor(string memory _name) {
        name = _name;
    }

    // Abstract function: must be implemented by derived contracts
    function sound() public virtual returns (string memory);

    // A concrete function that can be inherited
    function getName() public view returns (string memory) {
        return name;
    }
}

// Derived contract implementing the abstract function
contract Dog is Animal {
    constructor() Animal("Dog") {}

    // Implementing the abstract function
    function sound() public pure override returns (string memory) {
        return "Woof!";
    }
}

contract Cat is Animal {
    constructor() Animal("Cat") {}

    // Implementing the abstract function
    function sound() public pure override returns (string memory) {
        return "Meow!";
    }
}

// Interface
interface IVehicle {
    // Function declarations only, no implementation
    function start() external returns (string memory);

    function stop() external returns (string memory);
}

// Contract implementing the interface
contract Car is IVehicle {
    function start() external pure override returns (string memory) {
        return "Car started";
    }

    function stop() external pure override returns (string memory) {
        return "Car stopped";
    }
}

contract Bike is IVehicle {
    function start() external pure override returns (string memory) {
        return "Bike started";
    }

    function stop() external pure override returns (string memory) {
        return "Bike stopped";
    }
}
