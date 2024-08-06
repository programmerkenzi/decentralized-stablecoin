// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {ERC20} from "./ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;
    uint256 public unlockTime;

    modifier isUnlocked() {
        require(block.timestamp >= unlockTime, "DPC: Still locked");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _lockTime,
        address _initialOwner,
        uint256 _initialSupply
    ) ERC20(_name, _symbol, 18) {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockTime;
        // mint initial supply to the initial owner
        _mint(_initialOwner, _initialSupply);
    }

    function mint(address to, uint value) external isUnlocked {
        require(msg.sender == owner, "DPC: Only owner can mint");

        _mint(to, value);
    }

    function burn(address from, uint256 value) external isUnlocked {
        require(msg.sender == owner, "DPC: Only owner can mint");

        _burn(from, value);
    }
}
