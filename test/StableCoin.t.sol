// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test, console2, StdStyle} from "forge-std/Test.sol";

import {Oracle} from "../contracts/Oracle.sol";
import {Stablecoin} from "../contracts/Stablecoin.sol";

contract BaseSetup is Stablecoin, Test {
    constructor()
        Stablecoin("Stablecoin", "STC", oracle = new Oracle(), 0, 10, 0)
    {}

    function setUp() public virtual {
        oracle.setPrice(4000);
        vm.deal(address(this), 0);
    }

    receive() external payable {
        console.log("Received ETH: %s", msg.value);
    }
}

contract StablecoinDeployedTests is BaseSetup {
    function testSetsFeeRatePercentage() public view {
        assertEq(feeRatePercentage, 0);
    }

    function testAllowsMinting() public {
        uint256 ethAmount = 1e18;
        vm.deal(address(this), address(this).balance + ethAmount);
        this.mint{value: ethAmount}();

        assertEq(totalSupply, ethAmount * oracle.getPrice());
    }
}

contract WhenStablecoinMintedTokens is BaseSetup {
    uint256 internal mintAmount;

    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("When user has minted tokens");

        uint256 ethAmount = 1e18;
        mintAmount = ethAmount * oracle.getPrice();

        vm.deal(address(this), address(this).balance + ethAmount);
        this.mint{value: ethAmount}();
    }
}

contract MintedTokenTests is WhenStablecoinMintedTokens {
    function testShouldAllowBurning() public {
        uint256 remainingStablecoinAmount = 100;

        this.burn(mintAmount - remainingStablecoinAmount);
        assertEq(totalSupply, remainingStablecoinAmount);
    }

    function testCannotDepositBelowMin() public {
        uint256 stableCoinCollateralBuffer = 0.05e18;

        vm.deal(
            address(this),
            address(this).balance + stableCoinCollateralBuffer
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                InitialCollateralRatioError.selector,
                "STC: Initial collateral ratio not met, minimum is",
                stableCoinCollateralBuffer
            )
        );
        this.depositCollateralBuffer{value: stableCoinCollateralBuffer}();
    }
}
