// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// CallingOtherContract

contract Alice {
    uint256 public x;
    uint256 public valueReceived;

    event ValueSet(uint256 x, uint256 value);

    /**
     * @notice Sets the value of x.
     * @param _x The new value for x.
     */
    function setX(uint256 _x) public {
        x = _x;
        emit ValueSet(x, 0); // Emitting event for transparency
    }

    /**
     * @notice Returns the value of x.
     * @return The current value of x.
     */
    function getX() public view returns (uint256) {
        return x;
    }

    /**
     * @notice Sets the value of x and records the Ether sent with the transaction.
     * @param _x The new value for x.
     */
    function setXWithPayment(uint256 _x) public payable {
        x = _x;
        valueReceived = msg.value;
        emit ValueSet(x, valueReceived); // Emitting event with payment details
    }
}

contract Bob {
    /**
     * @notice Calls the setX function on the Alice contract.
     * @param _alice The address of the Alice contract.
     * @param _x The new value for x.
     */
    function setXOnAlice(Alice _alice, uint256 _x) public {
        _alice.setX(_x);
    }

    /**
     * @notice Calls the getX function on the Alice contract.
     * @param _alice The address of the Alice contract.
     * @return The current value of x from the Alice contract.
     */
    function getXFromAlice(Alice _alice) public view returns (uint256) {
        return _alice.getX();
    }

    /**
     * @notice Calls the setX function on the Alice contract using its address.
     * @param _aliceAddr The address of the Alice contract.
     * @param _x The new value for x.
     */
    function setXOnAliceByAddress(address _aliceAddr, uint256 _x) public {
        Alice alice = Alice(_aliceAddr);
        alice.setX(_x);
    }

    /**
     * @notice Calls the setXWithPayment function on the Alice contract, forwarding any Ether sent.
     * @param _alice The address of the Alice contract.
     * @param _x The new value for x.
     */
    function setXWithPaymentOnAlice(Alice _alice, uint256 _x) public payable {
        _alice.setXWithPayment{value: msg.value}(_x);
    }
}
