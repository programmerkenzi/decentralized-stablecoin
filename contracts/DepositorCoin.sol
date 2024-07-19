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
}
