// contracts/CTEToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CTEToken
 * @dev Implementation of the ERC20 Token standard using OpenZeppelin's ERC20 contract
 */
contract CTEToken is ERC20 {
    /**
     * @dev Sets the values for {name} and {symbol}, and mints `initialSupply` tokens
     * to the deployer account.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     *
     * @param initialSupply The initial supply of tokens to be minted to the deployer's account
     */
    constructor(uint256 initialSupply) ERC20("RKToken", "RTN") {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `1`, a balance of `50` tokens should
     * be displayed to a user as `5.0` (`50 / 10 ** 1`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is purely for display purposes.
     */
    function decimals() public pure override returns (uint8) {
        return 1;
    }
}
