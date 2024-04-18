// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSplitter} from "../src/BaseSplitter.sol";
import {BaseSplitFactory} from "../src/BaseSplitFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockToken is ERC20 {
    constructor() ERC20("MockToken", "MKT") {
        _mint(msg.sender, 1000000 * 1e18);  // Mint 1,000,000 tokens to deployer
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract BaseSplitterTest is Test {
    BaseSplitter public splitter;
    BaseSplitFactory public factory;
    MockToken public token; // Mock token contract

    // Ensure the contract can receive Ether
    receive() external payable {}
    fallback() external payable {}

    function setUp() public {
        address[] memory parties = new address[](4);
        parties[0] = address(0x1);
        parties[1] = address(0x2);
        parties[2] = address(0x3);
        parties[3] = address(0x4);

        uint256[] memory shares = new uint256[](4);
        shares[0] = 25;
        shares[1] = 25;
        shares[2] = 25;
        shares[3] = 25;

        factory = new BaseSplitFactory(address(this));
        // set fee
        factory.setFee(3);
        factory.registerSplitter(address(this), parties, shares);
        
        // get instance of splitter
        BaseSplitFactory.Splitter[] memory splitters = factory.getSplittersByOwner(address(this));
        splitter = BaseSplitter(payable(splitters[0].splitterAddress));



        // Ensure the test contract has enough Ether
        vm.deal(address(this), 10 ether);

        // Send some eth to the splitter
        payable(address(splitter)).transfer(1 ether);

        // Deploy the mock token and set up for tests
        token = new MockToken();
        token.mint(address(this), 10000 * 1e18);
        token.approve(address(splitter), 10000 * 1e18);
        token.transfer(address(splitter), 1000 * 1e18);
    }

    function test_GetBalance() public view {
        assertEq(splitter.getBalance(), 1 ether);
    }

     function test_GetTokenBalance() public view {
        assertEq(splitter.getTokenBalance(address(token)), 1000 * 1e18);
    }

    function test_GetShares() public view {
        uint256[] memory shares = splitter.getShares();
        assertEq(shares.length, 4);
        assertEq(shares[0], 25);
        assertEq(shares[1], 25);
        assertEq(shares[2], 25);
        assertEq(shares[3], 25);
    }

    function test_GetParties() public view {
        address[] memory parties = splitter.getParties();
        assertEq(parties.length, 4);
        assertEq(parties[0], address(0x1));
        assertEq(parties[1], address(0x2));
        assertEq(parties[2], address(0x3));
        assertEq(parties[3], address(0x4));
    }

    function test_ownerWithdraw() public {
        uint256 initialSplitterBalance = splitter.getBalance();

        // Act: Perform the withdrawal.
        splitter.ownerWithdraw();

        // Assert: Check the final balances.
        uint256 finalSplitterBalance = splitter.getBalance();
        assertEq(finalSplitterBalance, 0, "Splitter balance should be zero after withdraw.");
    }

    function test_withdrawToken() public {
        // Setup: Ensure the splitter has some tokens.
        
        uint256 initialSplitterTokenBalance = splitter.getTokenBalance(address(token));
        splitter.withdrawToken(address(token));
        uint256 finalSplitterTokenBalance = splitter.getTokenBalance(address(token));
        assertEq(finalSplitterTokenBalance, 0, "Splitter token balance should be zero after withdraw.");
    }

    function test_split() public {
        // Setup: Ensure the splitter has some ETH.
        // vm.deal(address(splitter), 1 ether);  // Manually assign some ETH to the splitter for testing.

        uint256 initialSplitterBalance = splitter.getBalance();
        console.log("Initial splitter balance: ", initialSplitterBalance);
        
        // Act: Perform the split.
        splitter.split();


        // Assert: Check the final balances.
        uint256 finalSplitterBalance = splitter.getBalance();
        console.log("Final splitter balance: ", finalSplitterBalance);
        assertEq(finalSplitterBalance, 0, "Splitter balance should be zero after split.");

        // Check the balances of the parties
        address[] memory parties = splitter.getParties();
        // check first party balance
        uint256 party1Balance = parties[0].balance;
        console.log("Party 1 balance: ", party1Balance);
        assertEq(party1Balance, 0.249925000000000000 ether, "Party 1 balance should be 0.25 ether after split.");
    }

    function test_splitToken() public {

        uint256 initialSplitterTokenBalance = splitter.getTokenBalance(address(token));
        console.log("Initial splitter token balance: ", initialSplitterTokenBalance);
        
        // Act: Perform the split.
        splitter.splitToken(address(token));

        uint256 finalSplitterTokenBalance = splitter.getTokenBalance(address(token));
        console.log("Final splitter token balance: ", finalSplitterTokenBalance);

         // Check the balances of the parties
        address[] memory parties = splitter.getParties();
        // check first party balance
        uint256 party1TokenBalance = token.balanceOf(parties[0]);
        console.log("Party 1 token balance: ", party1TokenBalance);
        assertEq(party1TokenBalance, 249925000000000000000, "Party 1 token balance should be 2500 tokens after split.");
    }

}
