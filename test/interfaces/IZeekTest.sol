// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../contracts/libraries/ZeekDataTypes.sol";
import "../../contracts/libraries/ZeekStorage.sol";
import "../../contracts/interfaces/IGovernance.sol";
import "../../contracts/interfaces/IProfile.sol";
import "../../contracts/interfaces/IWish.sol";

interface IZeekTest is IGovernance, IProfile, IWish {

    function getProfileCounter() external view returns (uint256);

    // function getProfileById(uint256 profileId) external view returns (ZeekDataTypes.ProfileStruct memory);

    function getProfileTokenByIndex(uint256 index) external view returns (uint256);

    function getProfileAllTokens() external view returns (uint256[] memory);

    function getProfileIdByAddress(address owner) external view returns (uint256);

    function getProfileIdByLinkCodeHash(bytes32 hash) external view returns (uint256);

    function setProfileCounter(uint newCounter) external;

    function getProfileConnection(uint256 from, uint256 to) external view returns (bool);

    function deleteProfileByAddress(address owner) external;

    function getWishHistorySalt(uint256 salt) external view returns (bool);

    function getWishStructOwner(uint256 id) external view returns (uint256);

    function getWishStructWishType(uint256 id) external view returns (ZeekDataTypes.WishType);

    function getWishStructToken(uint256 id) external view returns (address);

    function getWishStructTokenVersion(uint256 id) external view returns (uint256);

    function getWishStructBalance(uint256 id) external view returns (uint256);

    function getWishStructState(uint256 id) external view returns (ZeekDataTypes.WishState);

    function getWishStructCommissionRate(uint256 id, ZeekDataTypes.OfferType offerType)
    external view returns (ZeekDataTypes.OfferRatio memory);

    function getWishStructFeePerMonth(uint256 id) external view returns (uint256);

    function getWishStructFeeTokenVersion(uint256 id) external view returns (uint256);

    function getWishStructFeeToken(uint256 id) external view returns (address);

    function getWishStructStart(uint256 id) external view returns (uint);

    function getWishStructDeadline(uint256 id) external view returns (uint);

    function getWishStructTimestamp(uint256 id) external view returns (uint);

    function getWishStructLastModifyTime(uint256 id) external view returns (uint);

    function getWishStructLinkCode(uint256 id, uint linker) external view returns (string memory);

    // function getWishStructCandidatesTalent(uint256 id, uint talentId) external view returns (ZeekDataTypes.Candidate memory);

    function getWishStructOffer(uint256 id) external view returns (ZeekDataTypes.Offer memory);

    function setWishStructCandidatesApproveTime(uint wishId, uint talent, uint64 newApproveTime) external;

    function getWishOfferRatio(ZeekDataTypes.WishType wishType) external view returns (ZeekDataTypes.OfferRatio memory);

    function getWishLinkOfferRatio(ZeekDataTypes.WishType wishType) external view returns (ZeekDataTypes.OfferRatio memory);

    function getWishStructIssuer(uint256 id) external view returns (uint256);

    function getWishIssueFee(ZeekDataTypes.WishType wishType) external view returns (uint);

    function getWishIssueFeeToken() external view returns (address);

    function getWishIssueFeeTokenVersion() external view returns (uint);

    function getWishUnlock(uint256, uint256) external view returns (ZeekDataTypes.Unlock memory);

    function getWishStructPrice(uint256 id) external view returns (ZeekDataTypes.WishTokenValue memory);

    function getWishStructRestricted(uint256 id) external view returns (bool);

    function getWishStructOfferRatio(uint256 id, ZeekDataTypes.OfferType offerType) external view returns (ZeekDataTypes.OfferRatio memory);

    function getWishStructFinishTime(uint256 id) external view returns (uint64);

    function getWishStructTokenValue(uint256 id) external view returns (ZeekDataTypes.TokenValue memory);

    function getWishStorageEarlyUnlockToken(address token) external view returns (ZeekDataTypes.TokenValueSet memory);

    function getWishStorageUnlockToken(address token) external view returns (ZeekDataTypes.TokenValueSet memory);

    function getWishStorageEarlyUnlockRatio() external view returns (ZeekDataTypes.UnlockRatio memory);

    function getWishStorageUnlockRatio() external view returns (ZeekDataTypes.UnlockRatio memory);

    function getMinimumIssueTokens(address token) external view returns (ZeekDataTypes.TokenValueSet memory);

    function grantRoleForTest(bytes32 role, address _address) external returns (bool);

    function estimateFeeUseForTest(uint64 start, uint64 deadline, ZeekDataTypes.WishType wishType)
    external view returns (ZeekDataTypes.EstimateFee memory);

    function calculateWishFeeSharing(
        uint256 bountyFee, bool isLinked
    ) external pure returns (uint256 /*linker*/, uint256 /*platform*/);

    function calculateQuestionFeeSharing(
        uint256 bountyFee, bool isLinked
    ) external pure returns (uint256, uint256);

    function calculateWishFeeWhenDirectToPlatformAndLinker(
        uint256 bountyFee
    ) external pure returns (uint256, uint256);


    function getGovernanceStorageName(
    ) external view returns (string memory);

    function getGovernanceStorageSymbol(
    ) external view returns (string memory);

    function getGovernanceStorageFinance(
    ) external view returns (address);

    function getProfileOwnerById(uint256 profileId)
    external view returns (address) ;

    function getProfileLinkCodeById(uint256 profileId)
    external view returns (string memory) ;

    function getProfileTimestampById(uint256 profileId)
    external view returns (uint256) ;

    function getProfileVaults(uint256 profileId, address token)
    external view returns (ZeekDataTypes.Vault memory vault) ;

    function getProfileVaultTokens(uint256 profileId)
    external view returns (address[] memory addresses) ;

}
