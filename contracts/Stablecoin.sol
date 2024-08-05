// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";

contract Stablecoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle
    ) ERC20(_name, _symbol, 18) {
        oracle = _oracle;
    }

    // mint stablecoin by sending eth, so use payable modifier here to accept ether
    function mint() external payable {
        uint256 mintStablecoinAmount = msg.value * oracle.getPrice();

        _mint(msg.sender, mintStablecoinAmount);
    }

    // burn stablecoin to get back eth
    function burn(uint256 burnStablecoinAmount) external {
        _burn(msg.sender, burnStablecoinAmount);

        uint256 refundingEth = burnStablecoinAmount / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Burn refund transaction failed");
    }

    function depositCollateralBuffer() external payable {
        uint256 surplusInUsd = _getSurplusInContractInUsd();

        uint256 usdInDpcPrice = depositorCoin.totalSupply() / surplusInUsd;

        uint256 mintDepositorCoinAmount = msg.value *
            oracle.getPrice() *
            usdInDpcPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(
        uint256 burnDepositorCoinAmount
    ) external {
        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        uint256 surplusInUsd = _getSurplusInContractInUsd();
        uint256 usdInDpcPrice = depositorCoin.totalSupply() / surplusInUsd;

        uint256 refundingUsd = burnDepositorCoinAmount / usdInDpcPrice;

        uint256 refundingEth = refundingUsd / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Withdraw refund transaction failed");
    }

    function _getSurplusInContractInUsd() private view returns (uint256) {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) *
            oracle.getPrice();

        uint256 totalStableCoinBalanceInUsd = totalSupply;

        uint256 surplus = ethContractBalanceInUsd - totalStableCoinBalanceInUsd;

        return surplus;
    }
}
