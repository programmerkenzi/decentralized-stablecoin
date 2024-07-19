// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";

contract Stablecoin is ERC20 {
    DepositorCoin public depositorCoin;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, 18) {}

    // mint stablecoin by sending eth, so use payable modifier here to accept ether
    function mint() external payable {
        uint256 ethUsdPrice = 1000;
        uint256 mintStablecoinAmount = msg.value * ethUsdPrice;

        _mint(msg.sender, mintStablecoinAmount);
    }

    // burn stablecoin to get back eth
    function burn(uint256 burnStablecoinAmount) external {
        _burn(msg.sender, burnStablecoinAmount);

        uint256 ethUsdPrice = 1000;
        uint256 refundingEth = burnStablecoinAmount / ethUsdPrice;

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Burn refund transaction failed");
    }
}
