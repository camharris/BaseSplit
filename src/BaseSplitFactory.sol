// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "./BaseSplitter.sol"; // Import the BaseSplitter contract

contract BaseSplitFactory {
    address public owner;
    uint256 public fee;

    struct Splitter {
        address owner;
        address[] parties;
        uint256[] shares;
        address splitterAddress;
    }

    Splitter[] public splitters;

    constructor(address _owner) {
        owner = _owner;
    }

    // Set protocol fee in basis points (1 basis point = 0.01%)
    function setFee(uint256 _feeInBasisPoints) public {
        require(msg.sender == owner, "Only owner can set fee");
        require(_feeInBasisPoints <= 10000, "Fee cannot be more than 100%");
        fee = _feeInBasisPoints;
        // uint256 feeAmount = amount * fee / 10000;
    }

    // get protocol fee
    function getFee() public view returns (uint256) {
        return fee;
    }

    function registerSplitter(
        address splitterOwner,
        address[] memory parties,
        uint256[] memory shares
    ) public {
        address factory = address(this);
        
        require(parties.length == shares.length, "Parties and shares length mismatch");
        // Verify shares are not greater than 100
        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            require(shares[i] <= 100, "Shares must be less than or equal to 100");
            totalShares += shares[i];
        }
        require(totalShares == 100, "Total shares must be equal to 100");

        address splitterAddress = address(new BaseSplitter(splitterOwner, parties, factory)); // Create a new instance of BaseSplitter
        splitters.push(Splitter(splitterOwner, parties, shares, splitterAddress)); // Add the new splitter to the list of splitters
    }

    // Get splitters by owner
    function getSplittersByOwner(address splitterOwner) public view returns (Splitter[] memory) {
        Splitter[] memory ownerSplitters = new Splitter[](splitters.length);
        uint256 count = 0;
        for (uint256 i = 0; i < splitters.length; i++) {
            if (splitters[i].owner == splitterOwner) {
                ownerSplitters[count] = splitters[i];
                count++;
            }
        }
        
        if (count == 0) {
            return new Splitter[](0); // Return an empty array if no splitters found
        } else {
            Splitter[] memory result = new Splitter[](count);
            for (uint256 i = 0; i < count; i++) {
                result[i] = ownerSplitters[i];
            }
            return result;
        }
    }

    // Get all splitters
    function getAllSplitters() public view returns (Splitter[] memory) {
        return splitters;
    }

    // Get count of all splitters
    function getSplitterCount() public view returns (uint256) {
        return splitters.length;
    }

    // Get splitter by address
    function getSplitterByAddress(address splitterAddress) public view returns (Splitter memory) {
        for (uint256 i = 0; i < splitters.length; i++) {
            if (splitters[i].splitterAddress == splitterAddress) {
                return splitters[i];
            }
        }
        revert("Splitter not found");
    }

    // make payable to receive fees
    receive() external payable {}

}
