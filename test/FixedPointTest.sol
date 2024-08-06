// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

import {FixedPoint} from "../contracts/FixedPoint.sol";

contract FixedPointTest {
    function testAddition(
        FixedPoint a,
        FixedPoint b
    ) external pure returns (FixedPoint) {
        // unwrap the fixed point numbers, add them, and wrap the result
        return a + b;
    }

    function testSubstation(
        FixedPoint a,
        FixedPoint b
    ) external pure returns (FixedPoint) {
        // unwrap the fixed point numbers, add them, and wrap the result
        return a - b;
    }

    function testMultiplication(
        FixedPoint a,
        FixedPoint b
    ) external pure returns (FixedPoint) {
        // unwrap the fixed point numbers, add them, and wrap the result
        return a * b;
    }

    function testDivision(
        FixedPoint a,
        FixedPoint b
    ) external pure returns (FixedPoint) {
        // unwrap the fixed point numbers, add them, and wrap the result
        return a / b;
    }
}
