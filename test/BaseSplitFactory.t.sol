// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {BaseSplitFactory} from "../src/BaseSplitFactory.sol";

contract BaseSplitFactoryTest is Test {
    BaseSplitFactory public factory;

    function setUp() public {
        factory = new BaseSplitFactory(address(this));
    }

    function test_RegisterSplitter() public {
        address[] memory parties = new address[](3);
        parties[0] = address(0x1);
        parties[1] = address(0x2);
        parties[2] = address(0x3);

        factory.registerSplitter(address(this), parties);
        assertEq(factory.splitters(0), factory.splitter());
    }
}