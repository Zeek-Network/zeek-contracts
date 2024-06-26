// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './ZeekDataTypes.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

/**
 * @title ZeekStorage
 * @author zeeker
 *
 * @dev This abstract contract defines storage for the talent project.
 */
abstract contract ZeekStorage {
    using EnumerableSet for EnumerableSet.AddressSet;
    /*///////////////////////////////////////////////////////////////
                            ProfileStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant PROFILE_STORAGE_POSITION = keccak256('zeek.profile.storage');
    struct ProfileStorage {
        // Array with all token ids, used for enumeration
        uint256[] _allTokens;
        // Mapping from token id to position in the allTokens array
        mapping(uint256 => uint256) _allTokensIndex;
        mapping(bytes32 => uint256) _profileIdByLinkCodeHash;
        mapping(uint256 => ZeekDataTypes.ProfileStruct) _profileById;
        mapping(address => uint256) _profileIdByAddress;
        uint256 _profileCounter;
        mapping(address => uint256) _sigNonces;
        mapping(uint256 => mapping(address => ZeekDataTypes.Vault)) _vaults;
        mapping(uint256 => address[]) _vaultTokens;
    }

    function _getProfileStorage() internal pure returns (ProfileStorage storage profileStorage) {
        bytes32 position = PROFILE_STORAGE_POSITION;
        assembly {
            profileStorage.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                            BountyStorage change to wish
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant BOUNTY_STORAGE_POSITION = keccak256('zeek.wish.storage');
    struct WishStorage {
        mapping(uint256 => bool) _wishHistorySalt;
        mapping(uint256 => ZeekDataTypes.WishStruct) _wishById;
        uint256 _wishCounter;
        mapping(ZeekDataTypes.WishType => ZeekDataTypes.OfferRatio) _offerRatios;
        mapping(ZeekDataTypes.WishType => ZeekDataTypes.OfferRatio) _linkOfferRatios;
        mapping(address => ZeekDataTypes.TokenValueSet) _minIssueTokens;
        mapping(address => ZeekDataTypes.TokenValueSet) _earlyUnlockTokens;
        mapping(address => ZeekDataTypes.TokenValueSet) _unlockTokens;
        mapping(address => uint256) _cutDecimals;
        ZeekDataTypes.UnlockRatio _earlyUnlockRatio;
        ZeekDataTypes.UnlockRatio _unlockRatio;
        ZeekDataTypes.BidRatio _bidRatio;
    }

    function _getWishStorage() internal pure returns (WishStorage storage wishStorage) {
        bytes32 position = BOUNTY_STORAGE_POSITION;
        assembly {
            wishStorage.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                            GovernanceStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant GOVERNANCE_STORAGE_POSITION = keccak256('zeek.governance.storage');
    struct GovernanceStorage {
        string _name;
        string _symbol;
        address _finance;
        address _vault;
        mapping(address => bool) _appWhitelisted;
    }

    function _getGovernanceStorage() internal pure returns (GovernanceStorage storage governanceStorage) {
        bytes32 position = GOVERNANCE_STORAGE_POSITION;
        assembly {
            governanceStorage.slot := position
        }
    }
}
