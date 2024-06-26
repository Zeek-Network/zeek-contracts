// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../base/ZeekBase.sol";
import "../interfaces/IGovernance.sol";
import "../libraries/ZeekDataTypes.sol";
import "../libraries/ZeekErrors.sol";
import "../libraries/Constants.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/**
 * @title IGovernanceLogic
 * @author zeeker
 *
 * @dev This is the interface for the GovernanceLogic contract.
 */
contract Governance is IGovernance, ZeekBase, AccessControlUpgradeable {
    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/
    /// @inheritdoc IGovernance
    function initialize(
        string memory name,
        string memory symbol
    ) external override initializer {
        // grant role first
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        // save storage
        GovernanceStorage storage governanceStorage = _getGovernanceStorage();
        governanceStorage._name = name;
        governanceStorage._symbol = symbol;
        governanceStorage._finance = _msgSender();

        emit ZeekEvents.ZeekInitialized(uint64(block.timestamp));
    }

    /// @inheritdoc IGovernance
    function whitelistApp(address app, bool whitelist) 
    external override onlyRole(Constants.GOVERANCE_ROLE) {
        _getGovernanceStorage()._appWhitelisted[app] = whitelist;
        emit ZeekEvents.AppWhitelisted(app, whitelist, block.timestamp);
    }

    /// @inheritdoc IGovernance
    function setFinance(
        address newFinance
    ) external override onlyRole(Constants.GOVERANCE_ROLE) {
        if (address(0) == newFinance) {
            revert ZeekErrors.InvalidAddress();
        }
        GovernanceStorage storage governanceStorage = _getGovernanceStorage();
        address priorFinance = governanceStorage._finance;
        governanceStorage._finance = newFinance;
        emit ZeekEvents.ZeekFinanceSet(
            msg.sender,
            priorFinance,
            newFinance,
            uint64(block.timestamp)
        );
    }

    /// @inheritdoc IGovernance
    function setOfferRatios(
        ZeekDataTypes.WishType[] calldata types,
        ZeekDataTypes.OfferRatio[] calldata ratios
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setOfferRatios(types, ratios);

        emit ZeekEvents.ZeekWishOfferRatioSet(
            ZeekDataTypes.OfferType.Direct,
            ratios[0],
            ratios[1]
        );
    }

    /// @inheritdoc IGovernance
    function setLinkOfferRatios(
        ZeekDataTypes.WishType[] calldata types,
        ZeekDataTypes.OfferRatio[] calldata ratios
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setLinkOfferRatios(types, ratios);

        emit ZeekEvents.ZeekWishOfferRatioSet(
            ZeekDataTypes.OfferType.Link,
            ratios[0],
            ratios[1]
        );
    }

    /// @inheritdoc IGovernance
    function setMinimumIssueTokens(
        address token,
        uint256 tokenVersion,
        uint256 value,
        bool valid
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setMinimumIssueTokens(token, tokenVersion, value, valid);
        emit ZeekEvents.ZeekWishMiniumIssueTokenSet(token, tokenVersion, value, valid);
    }

    /// @inheritdoc IGovernance
    function setEarlyUnlockRatio(
        uint issuer,
        uint owner,
        uint platform
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setEarlyUnlockRatio(issuer, owner, 0, platform);
        emit ZeekEvents.ZeekWishUnlockRatioSet(issuer, owner, 0, platform, true);
    }

    /// @inheritdoc IGovernance
    function setUnlockRatio(
        uint issuer,
        uint owner,
        uint talent,
        uint platform
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setUnlockRatio(issuer, owner, talent, platform);
        emit ZeekEvents.ZeekWishUnlockRatioSet(issuer, owner, talent, platform, false);
    }

    /// @inheritdoc IGovernance
    function setBidRatio(
        uint step,
        uint owner,
        uint talent,
        uint platform
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setBidRatio(step, owner, talent, platform);
        emit ZeekEvents.ZeekWishBidRatioSet(step, owner, talent, platform);
    }

    /// @inheritdoc IGovernance
    function setEarlyUnlockTokens(
        address token,
        uint256 tokenVersion,
        uint256 value,
        bool valid
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setEarlyUnlockTokens(token, tokenVersion, value, valid);
        emit ZeekEvents.ZeekWishUnlockTokenSet(token, tokenVersion, value, valid, true);
    }

    /// @inheritdoc IGovernance
    function setUnlockTokens(
        address token,
        uint256 tokenVersion,
        uint256 value,
        bool valid
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _setUnlockTokens(token, tokenVersion, value, valid);
        emit ZeekEvents.ZeekWishUnlockTokenSet(token, tokenVersion, value, valid, false);
    }

    /// @inheritdoc IGovernance
    function setCutDecimals(
        address token,
        uint256 decimals
    ) external override onlyRole(Constants.OPERATION_ROLE) {
        _getWishStorage()._cutDecimals[token] = decimals;
        emit ZeekEvents.ZeekCutDecimalSet(token, decimals, uint64(block.timestamp));
    }

    function _setOfferRatios(ZeekDataTypes.WishType[] calldata types, ZeekDataTypes.OfferRatio[] calldata ratios) internal {
        if (types.length != ratios.length) {
            revert ZeekErrors.InvalidParameters();
        }

        for (uint i; i < types.length; ) {
            if (ratios[i].linker > 0) {
                // linker ratio can only be set in the link case
                revert ZeekErrors.InvalidParameters();
            }
            _validateRatio(ratios[i].talent + ratios[i].linker + ratios[i].platform, 100);
            _getWishStorage()._offerRatios[types[i]] = ratios[i];
            unchecked {
                ++i;
            }
        }
    }

    function _setLinkOfferRatios(ZeekDataTypes.WishType[] calldata types, ZeekDataTypes.OfferRatio[] calldata ratios) internal {
        if (types.length != ratios.length) {
            revert ZeekErrors.InvalidParameters();
        }

        for (uint i; i < types.length; ) {
            _validateRatio(ratios[i].talent + ratios[i].linker + ratios[i].platform, 100);
            _getWishStorage()._linkOfferRatios[types[i]] = ratios[i];
            unchecked {
                ++i;
            }
        }
    }

    function _setMinimumIssueTokens(
        address token,
        uint tokenVersion,
        uint256 value,
        bool valid
    ) internal {
        _validateTokenValue(token, tokenVersion);
        _getWishStorage()._minIssueTokens[token] = ZeekDataTypes.TokenValueSet(token, tokenVersion, value, valid);
    }

    function _setEarlyUnlockTokens(
        address token,
        uint tokenVersion,
        uint256 value,
        bool valid
    ) internal {
        _validateTokenValue(token, tokenVersion);
        _getWishStorage()._earlyUnlockTokens[token] = ZeekDataTypes.TokenValueSet(token, tokenVersion, value, valid);
    }

    function _setUnlockTokens(address token, uint tokenVersion, uint256 value, bool valid) internal {
        _validateTokenValue(token, tokenVersion);
        _getWishStorage()._unlockTokens[token] = ZeekDataTypes.TokenValueSet(token, tokenVersion, value, valid);
    }

    function _setEarlyUnlockRatio(uint issuer, uint owner, uint talent, uint platform) internal {
        _validateRatio(issuer + owner + talent + platform, 100);
        _getWishStorage()._earlyUnlockRatio = ZeekDataTypes.UnlockRatio(issuer, owner, talent, platform);
    }

    function _setUnlockRatio(uint issuer, uint owner, uint talent, uint platform) internal {
        _validateRatio(issuer + owner + talent + platform, 100);
        _getWishStorage()._unlockRatio = ZeekDataTypes.UnlockRatio(issuer, owner, talent, platform);
    }

    function _setBidRatio(uint step, uint owner, uint talent, uint platform) internal {
        _validateRatio(owner + talent + platform, step);
        _getWishStorage()._bidRatio = ZeekDataTypes.BidRatio(step, owner, talent, platform);
    }

    function _validateRatio(uint256 given, uint256 required) internal pure {
        if (given != required) {
            revert ZeekErrors.InvalidParameters();
        }
    }
    /*///////////////////////////////////////////////////////////////
                        Public read functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC5267
    function eip712Domain()
        external
        view
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _getGovernanceStorage()._name,
            "1",
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
}
