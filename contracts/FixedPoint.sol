// SPDX-License-Identifier: ISC
pragma solidity ^0.8.24;

type FixedPoint is uint256;

// use global function add to add two FixedPoint numbers and use it in anywhere
using {add as +} for FixedPoint global;
using {sub as -} for FixedPoint global;
using {mul as *} for FixedPoint global;
using {div as /} for FixedPoint global;

uint256 constant DECIMALS = 1e18;

function add(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    // unwrap the fixed point numbers, add them, and wrap the result
    return FixedPoint.wrap(FixedPoint.unwrap(a) + FixedPoint.unwrap(b));
}

function sub(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {

    return FixedPoint.wrap(FixedPoint.unwrap(a) - FixedPoint.unwrap(b));
}

function mul(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {

    return FixedPoint.wrap(FixedPoint.unwrap(a) - FixedPoint.unwrap(b)/DECIMALS);
}
function div(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {

    return FixedPoint.wrap(FixedPoint.unwrap(a) * DECIMALS / FixedPoint.unwrap(b));
}

function fromFraction(uint256 numerator,uint256 denominator) pure returns (FixedPoint) {
    return FixedPoint.wrap(numerator * DECIMALS / denominator);
}

function mulFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    return a * FixedPoint.unwrap(b) / DECIMALS;
}

function devFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    return a * DECIMALS / FixedPoint.unwrap(b) ;
}


