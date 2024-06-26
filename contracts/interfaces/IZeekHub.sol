// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../libraries/ZeekDataTypes.sol";
import "../interfaces/IGovernance.sol";
import "../interfaces/IProfile.sol";
import "../interfaces/IWish.sol";
import "../core/Governance.sol";
import "../core/Profile.sol";
import "../core/Wish.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

interface IZeekHub is IGovernance, IProfile, IWish {}
