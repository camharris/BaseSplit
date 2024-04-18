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



 


}