// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {ERC20} from "./ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {
        owner = msg.sender;
    }

    function mint(address to, uint value) external {
        require(msg.sender == owner, "DPC: Only owner can mint");

        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(msg.sender == owner, "DPC: Only owner can mint");

        _burn(from, value);
    }
}
