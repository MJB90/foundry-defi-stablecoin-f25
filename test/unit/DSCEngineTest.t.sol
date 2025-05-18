//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";

contract DSCEngineTest is Test {
    DSCEngine public s_dscEngine;
    DecentralizedStableCoin public s_dsc;
    HelperConfig public s_helperConfig;
    address wethUsdPriceFeed;
    address weth;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (s_dscEngine, s_dsc, s_helperConfig) = deployer.run();
        (wethUsdPriceFeed,, weth,,,) = s_helperConfig.activeNetworkConfig();
    }

    ////////////////////////////////////////////////////////////////////
    //                            Price Feed Tests
    ////////////////////////////////////////////////////////////////////
    function testGetUsdVal() public view {
        uint256 amount = 15e18;
        uint256 expectedValue = 30000e18; // 15 * 2000
        uint256 actualValue = s_dscEngine.getUsdValue(weth, amount);
        assertEq(actualValue, expectedValue, "getUsdValue failed");
    }
}
