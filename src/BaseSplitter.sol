//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract BaseSplitter {
    address public owner;
    address[] public parties;
    address public factory;
    address[] public splitters;

    constructor(address _owner, address[] memory _parties, address _factory) {
        owner = _owner;
        parties = _parties;
        factory = _factory;
    }

    function split(address token, uint256 amount) public {
        require(msg.sender == owner, "Only owner can split");
        require(amount > 0, "Amount must be greater than 0");
        require(token != address(0), "Token address must be valid");

        // Split the amount among all splitters
        uint256 splitAmount = amount / splitters.length;
        for (uint256 i = 0; i < splitters.length; i++) {
            (bool success, ) = splitters[i].call(abi.encodeWithSignature("receive(uint256)", splitAmount));
            require(success, "Splitter call failed");
        }
    }

    function addSplitter(address splitter) public {
        require(msg.sender == owner, "Only owner can add splitter");
        splitters.push(splitter);
    }

    function removeSplitter(address splitter) public {
        require(msg.sender == owner, "Only owner can remove splitter");
        for (uint256 i = 0; i < splitters.length; i++) {
            if (splitters[i] == splitter) {
                splitters[i] = splitters[splitters.length - 1];
                splitters.pop();
                break;
            }
        }
    }
}