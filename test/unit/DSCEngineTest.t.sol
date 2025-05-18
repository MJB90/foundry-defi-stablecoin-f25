//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DSCEngine public s_dscEngine;
    DecentralizedStableCoin public s_dsc;
    HelperConfig public s_helperConfig;
    address wethUsdPriceFeed;
    address weth;
    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (s_dscEngine, s_dsc, s_helperConfig) = deployer.run();
        (wethUsdPriceFeed,, weth,,,) = s_helperConfig.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
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

    ////////////////////////////////////////////////////////////////////
    //                            Deposit Collateral Tests
    ////////////////////////////////////////////////////////////////////
    function testRevertIfCollateralIsZero() public {
        vm.prank(USER);
        ERC20Mock(weth).approve(address(s_dscEngine), AMOUNT_COLLATERAL);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine_NeedsMoreThanZero.selector));
        s_dscEngine.depositCollateral(weth, 0);
    }
}
