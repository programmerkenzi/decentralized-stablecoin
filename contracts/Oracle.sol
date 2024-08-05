// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

// a oracle is a contract that provides real world data to the blockchain, the data is usually not available on the blockchain
// this is a oracle contract to get the price of eth in usd from real world
contract Oracle {
    uint256 private price;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function setPrice(uint256 newPrice) external {
        require(msg.sender == owner, "EthUsdPrice: Only owner can set price");
        price = newPrice;
    }
}
