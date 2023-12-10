// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SwarmLM is ERC20 {
    constructor(uint256 initialSupply) ERC20("Swarm LM Token", "SLM") {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }
}
