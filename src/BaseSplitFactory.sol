// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "./BaseSplitter.sol"; // Import the BaseSplitter contract

contract BaseSplitFactory {
    address public owner;
    address public splitter;
    address[] public splitters;

    constructor(address _owner) {
        owner = _owner;
    }

    function registerSplitter(
        address splitterOwner,
        address[] memory parties
    ) public {
        address factory = address(this);
        // require(msg.sender == owner, "Only owner can create splitter");
        require(splitter == address(0), "Splitter already created");
        splitter = address(new BaseSplitter(splitterOwner, parties, factory)); // Create a new instance of BaseSplitter
        splitters.push(splitter);
    }
}
