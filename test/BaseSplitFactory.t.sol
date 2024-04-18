// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSplitFactory} from "../src/BaseSplitFactory.sol";

contract BaseSplitFactoryTest is Test {
    BaseSplitFactory public factory;

    function setUp() public {
        factory = new BaseSplitFactory(address(this));
    }

    function test_SetFee() public {
        factory.setFee(3);
        assertEq(factory.getFee(), 3);
    }

    function test_RegisterSplitter() public {
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

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);
    }

    function test_GetSplittersByOwner() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);


        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter[] memory splitters = factory.getSplittersByOwner(address(this));
        console2.log("Splitters length: ", splitters.length);
        assertEq(splitters.length, 1);
    }

    function test_GetSplittersByOwner_InvalidOwner() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter[] memory splitters = factory.getSplittersByOwner(address(0x0));
        console2.log("Splitters length: ", splitters.length);
        assertEq(splitters.length, 0);
    }

    function test_GetAllSplitters() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter[] memory splitters = factory.getAllSplitters();
        console2.log("Splitters length: ", splitters.length);
        assertEq(splitters.length, 1);
    }

    function test_GetSplitterByAddress() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter memory splitter = factory.getSplitterByAddress(factory.getAllSplitters()[0].splitterAddress);
        console2.log("Splitter address: ", splitter.splitterAddress);
        assertEq(splitter.owner, address(this));
    }

    function test_GetSplittersByParty() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter[] memory splitters = factory.getSplittersByParty(address(0x1));
        console2.log("Splitters length: ", splitters.length);
        assertEq(splitters.length, 1);
    }

    function test_deactivateSplitter() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter memory splitter = factory.getSplitterByAddress(factory.getAllSplitters()[0].splitterAddress);

        factory.deactivateSplitter(splitter.splitterAddress);
        console2.log("Splitter isActive: ", splitter.isActive);

        BaseSplitFactory.Splitter memory splitter2 = factory.getSplitterByAddress(factory.getAllSplitters()[0].splitterAddress);
        console2.log("Splitter isActive: ", splitter2.isActive);
        
        assertEq(splitter2.isActive, false);
    }

    function test_isSplitterActive() public {
        address[] memory parties = new address[](2);
        parties[0] = address(0x1);
        parties[1] = address(0x2);

        uint256[] memory shares = new uint256[](2);
        shares[0] = 50;
        shares[1] = 50;

        factory.registerSplitter(address(this), parties, shares);
        assertEq(factory.getSplitterCount(), 1);

        BaseSplitFactory.Splitter memory splitter = factory.getSplitterByAddress(factory.getAllSplitters()[0].splitterAddress);

        factory.deactivateSplitter(splitter.splitterAddress);
        console2.log("Splitter isActive: ", splitter.isActive);

        assertEq(factory.isSplitterActive(splitter.splitterAddress), false);
    }
}