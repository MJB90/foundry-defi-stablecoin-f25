//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
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
    address wbtcUsdPriceFeed;
    address weth;
    address wbtc;
    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (s_dscEngine, s_dsc, s_helperConfig) = deployer.run();
        (wethUsdPriceFeed, wbtcUsdPriceFeed, weth, wbtc,,) = s_helperConfig.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    ////////////////////////////////////////////////////////////////////
    //                            Constructor Tests
    ////////////////////////////////////////////////////////////////////

    address[] public priceFeedAddresses;
    address[] public tokenAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeedLength() public {
        priceFeedAddresses.push(wethUsdPriceFeed);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine_TokenAddressAndPriceFeedAddressMismatch.selector));
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(s_dsc));
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

    function testGetTokenAmountFromUsd() public view {
        uint256 usdamount = 100 ether;
        uint256 expectedValue = 0.05 ether; // 15 * 2000
        uint256 actualValue = s_dscEngine.getTokenAmountFromUsd(weth, usdamount);
        assertEq(actualValue, expectedValue, "getTokenAmountFromUsd failed");
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

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock();
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine_TokenNotAllowed.selector));
        s_dscEngine.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(s_dscEngine), AMOUNT_COLLATERAL);
        s_dscEngine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = s_dscEngine.getAccountInformation(USER);
        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositAmountInEth = s_dscEngine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, expectedTotalDscMinted, "totalDscMinted is not 0");
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmountInEth, "expectedDepositAmountInEth is not 0");
    }
}
