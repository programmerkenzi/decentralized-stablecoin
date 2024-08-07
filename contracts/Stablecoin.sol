// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";
import {FixedPoint, fromFraction, mulFixedPoint, devFixedPoint} from "./FixedPoint.sol";

contract Stablecoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 public initialCollateralRatioPercentage;
    uint256 public depositorCoinLockTime;

    error InitialCollateralRatioError(
        string message,
        uint256 minimumDepositAmount
    );

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRatioPercentage,
        uint256 _depositorCoinLockTime
    ) ERC20(_name, _symbol, 18) {
        oracle = _oracle;
        feeRatePercentage = _feeRatePercentage;
        initialCollateralRatioPercentage = _initialCollateralRatioPercentage;
        depositorCoinLockTime = _depositorCoinLockTime;
    }

    // mint stablecoin by sending eth, so use payable modifier here to accept ether
    function mint() external payable {
        // the fee will be own by the depositor coin holders automatically, no need to transfer fee to them because the fee is already in the contract
        uint256 fee = _getFee(msg.value);
        uint256 mintStablecoinAmount = (msg.value - fee) * oracle.getPrice();

        _mint(msg.sender, mintStablecoinAmount);
    }

    // burn stablecoin to get back eth
    function burn(uint256 burnStablecoinAmount) external {
        _burn(msg.sender, burnStablecoinAmount);
        uint256 refundingEth = burnStablecoinAmount / oracle.getPrice();
        uint256 fee = _getFee(refundingEth);

        (bool success, ) = msg.sender.call{value: (refundingEth - fee)}("");
        require(success, "STC: Burn refund transaction failed");
    }

    function _getFee(uint256 ethAmount) private view returns (uint256) {
        return (ethAmount * feeRatePercentage) / 100;
    }

    function depositCollateralBuffer() external payable {
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();

        if (deficitOrSurplusInUsd <= 0) {
            uint256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1);
            uint256 deficitInEth = deficitInUsd / oracle.getPrice();

            uint256 addedSurplusEth = msg.value - deficitInEth;

            uint256 requiredInitialSupplyInUsd = (initialCollateralRatioPercentage *
                    totalSupply) / 100;

            uint256 requiredInitialSupplyInEth = requiredInitialSupplyInUsd /
                oracle.getPrice();

            if (addedSurplusEth <= requiredInitialSupplyInEth) {
                uint256 minimumDeposit = requiredInitialSupplyInEth -
                    addedSurplusEth;
                revert InitialCollateralRatioError(
                    "STC: Initial collateral ratio not met, minimum is",
                    minimumDeposit
                );
            }

            uint256 initialDepositorSupply = addedSurplusEth *
                oracle.getPrice() *
                msg.value;

            depositorCoin.mint(msg.sender, initialDepositorSupply);

            depositorCoin = new DepositorCoin(
                "Depositor Coin",
                "DPC",
                depositorCoinLockTime,
                msg.sender,
                initialDepositorSupply
            );
            return;
        }
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);

        FixedPoint usdInDpcPrice = fromFraction(
            depositorCoin.totalSupply(),
            surplusInUsd
        );

        uint256 mintDepositorCoinAmount = mulFixedPoint(
            msg.value * oracle.getPrice(),
            (usdInDpcPrice)
        );

        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(
        uint256 burnDepositorCoinAmount
    ) external {
        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        require(
            deficitOrSurplusInUsd > 0,
            "STC: No depositor funds to withdraw"
        );

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        FixedPoint usdInDpcPrice = fromFraction(
            depositorCoin.totalSupply(),
            surplusInUsd
        );

        uint256 refundingUsd = devFixedPoint(
            burnDepositorCoinAmount,
            usdInDpcPrice
        );

        uint256 refundingEth = refundingUsd / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Withdraw refund transaction failed");
    }

    function _getDeficitOrSurplusInContractInUsd()
        private
        view
        returns (int256)
    {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) *
            oracle.getPrice();

        uint256 totalStableCoinBalanceInUsd = totalSupply;

        int256 surplusOrDeficit = int256(ethContractBalanceInUsd) -
            int256(totalStableCoinBalanceInUsd);

        return surplusOrDeficit;
    }
}
