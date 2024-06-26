// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../libraries/ZeekDataTypes.sol";
import "@openzeppelin/contracts/interfaces/IERC5267.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title IGovernanceLogic
 * @author zeeker
 *
 * @dev This is the interface for the GovernanceLogic contract.
 */
interface IGovernance is IERC5267, IAccessControl {
    /**
     * Initializes the Profile SBT, setting the initial governance address as well as the name and symbol.
     *
     * @param name Zeek Name
     * @param symbol Zeek Symbol
     */
    function initialize(string calldata name, string calldata symbol) external;

    /**
     * @dev Sets the finance to receive and send zeek stake and fee
     *
     * @param newFinance new finance address
     */
    function setFinance(address newFinance) external;

    /**
     * Cut decimals for calculation scenario
     * @param token token 
     * @param decimals cut decimals
     */
    function setCutDecimals(address token, uint256 decimals) external;

    /**
     * Set CommissionRates
     * only for goverance
     *
     * @param types enum WishType
     * @param ratios enum OfferRatio
     */
    function setOfferRatios(ZeekDataTypes.WishType[] calldata types, ZeekDataTypes.OfferRatio[] calldata ratios) external;

    /**
     * Set CommissionRates for link case
     * only for goverance
     *
     * @param types enum CommissionType
     * @param rates enum CommissionRate
     */
    function setLinkOfferRatios(ZeekDataTypes.WishType[] calldata types, ZeekDataTypes.OfferRatio[] calldata rates) external;

    /**
     * Set Minimum Issue Tokens
     */
    function setMinimumIssueTokens(address token, uint256 tokenVersion, uint256 value, bool valid) external;

    /**
     * Set Unlock Tokens Config
     */
    function setUnlockTokens(address token, uint256 tokenVersion, uint256 value, bool valid) external;

    /**
     * Set Early Unlock Tokens Config
     */
    function setEarlyUnlockTokens(address token, uint256 tokenVersion, uint256 value, bool valid) external;

    /**
     * Set Early Unlock Ratio
     */
    function setEarlyUnlockRatio(uint issuer, uint owner, uint platform) external;

    /**
     * Set unlock Ratio
     */
    function setUnlockRatio(uint issuer, uint owner, uint talent, uint platform) external;

    /**
     * Set Bid Ratio
     */
    function setBidRatio(uint step, uint owner, uint talent, uint platform) external;

    /**
     * Set whitelist app address
     *
     * @param app address of the app contract
     * @param whitelist true or false
     */
    function whitelistApp(address app, bool whitelist) external;

}
