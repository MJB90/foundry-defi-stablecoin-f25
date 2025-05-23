//SPDX-License-Identifier: MIT
// Should contain the properties of the contracts that should always hold true

//1. The total supply of DSC should always be less than the total values of the collateral
//2. Getter view functions should never revert
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine public s_dscEngine;
    DecentralizedStableCoin public s_dsc;
    HelperConfig public s_helperConfig;
    address wethUsdPriceFeed;
    address wbtcUsdPriceFeed;
    address weth;
    address wbtc;
    address public USER = makeAddr("user");
    Handler public handler;

    function setUp() external {
        deployer = new DeployDSC();
        (s_dscEngine, s_dsc, s_helperConfig) = deployer.run();
        (wethUsdPriceFeed, wbtcUsdPriceFeed, weth, wbtc,,) = s_helperConfig.activeNetworkConfig();
        handler = new Handler(s_dscEngine, s_dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = s_dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(s_dscEngine));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(s_dscEngine));

        uint256 totalCollateralValue =
            s_dscEngine.getUsdValue(weth, totalWethDeposited) + s_dscEngine.getUsdValue(wbtc, totalWbtcDeposited);

        // console.log("Times Mint DSC Called: ", handler.timesMintDscCalled);
        // Try logging only the value to debug the issue
        console.log("Times Mint DSC Called: ", handler.timesMintDscCalled());
        assert(totalCollateralValue >= totalSupply);
    }
}
