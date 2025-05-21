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

contract InvariantsTest {}
