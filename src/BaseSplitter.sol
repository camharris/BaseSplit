//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./BaseSplitFactory.sol";

contract BaseSplitter {
    address public owner;
    address[] public parties;
    uint256[] public shares;
    address payable factory;
    

    constructor(address _owner, address[] memory _parties, uint256[] memory _shares, address _factory) {
        owner = _owner;
        parties = _parties;
        shares = _shares;
        factory = payable(_factory);
    }

    receive() external payable {}


    modifier isActive() {
        require(BaseSplitFactory(factory).isSplitterActive(address(this)), "Splitter is not active");
        _;
    }

    // Get the eth balance of the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Get the token balance of the contract
    function getTokenBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getShares() public view returns (uint256[] memory) {
        return shares;
    }

    function getParties() public view returns (address[] memory) {
        return parties;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getFactory() public view returns (address) {
        return factory;
    }

   function getFee() public view returns (uint256) {
        return BaseSplitFactory(factory).getFee();
   }

   function calculateFee(uint256 amount) public view returns (uint256) {
        return amount * getFee() / 10000;
   }

   
    // Owner withdraw function
    function ownerWithdraw() public isActive {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = getBalance();
        require(balance > 0, "Insufficient balance");

        uint256 feeAmount = calculateFee(balance);
        uint256 ownerAmount = balance - feeAmount;


        (bool sent, ) = payable(owner).call{value: ownerAmount}("");
        require(sent, "Failed to send Ether");

        (sent, ) = payable(factory).call{value: feeAmount}("");
        require(sent, "Failed to send fee");
    }

    // Owner withdraw function
    function withdrawToken(address token) public isActive {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = getTokenBalance(token);
        require(balance > 0, "Insufficient balance");
        uint256 feeAmount = calculateFee(balance);
        IERC20(token).transfer(owner, balance - feeAmount);
        IERC20(token).transfer(factory, feeAmount);
    }

    // Split eth balance among parties
    function split() public payable isActive {
        // Ensure the contract has enough balance
        require(getBalance() > 0, "Insufficient balance");
        uint256 balance = getBalance();
        uint256 feeAmount = calculateFee(balance);
        uint256 amountToSplit = balance - feeAmount;

        require(amountToSplit > 0, "Insufficient balance after fee");

        for (uint i = 0; i < parties.length; i++) {
            uint256 partyShare = amountToSplit * shares[i] / 100;
            (bool sent, ) = payable(parties[i]).call{value: partyShare}("");
            require(sent, "Failed to send Ether");
        }

        (bool sent, ) = payable(factory).call{value: feeAmount}("");
        require(sent, "Failed to send fee");

    }

    // Split token balance among parties
    function splitToken(address token) public isActive {
        // Ensure the contract has enough balance
        require(getTokenBalance(token) > 0, "Insufficient balance");
        uint256 balance = getTokenBalance(token);
        uint256 feeAmount = calculateFee(balance);
        uint256 amountToSplit = balance - feeAmount;

        require(amountToSplit > 0, "Insufficient balance after fee");

        for (uint i = 0; i < parties.length; i++) {
            uint256 partyShare = amountToSplit * shares[i] / 100;
            IERC20(token).transfer(parties[i], partyShare);
        }

        IERC20(token).transfer(factory, feeAmount);
    }
 


}