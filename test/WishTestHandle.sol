// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../contracts/interfaces/IZeekHub.sol";
import "../contracts/core/Wish.sol";
import "../contracts/core/Governance.sol";
import "../contracts/core/Profile.sol";
import "../contracts/upgradeability/IRouter.sol";


contract WishTestHandle is Wish{

    function getWishHistorySalt( uint256 salt
    ) external view returns (bool){
        return _getWishStorage()._wishHistorySalt[salt];
    }

    function getWishStructOwner( uint256 id
    ) external view returns (uint256){
        return _getWishStorage()._wishById[id].owner;
    }

    function getWishStructWishType( uint256 id
    ) external view returns (ZeekDataTypes.WishType){
        return _getWishStorage()._wishById[id].wishType;
    }

    function getWishStructToken( uint256 id
    ) external view returns (address){
        return _getWishStorage()._wishById[id].price.token;
    }

    function getWishStructTokenVersion( uint256 id
    ) external view returns (uint256){
        return _getWishStorage()._wishById[id].price.tokenVersion;
    }

    function getWishStructBalance( uint256 id
    ) external view returns (uint256){
        return _getWishStorage()._wishById[id].price.value;
    }

    function getWishStructState( uint256 id
    ) external view returns (ZeekDataTypes.WishState){
        return _getWishStorage()._wishById[id].state;
    }

    function getWishStructCommissionRate( uint256 id, ZeekDataTypes.OfferType offerType
    ) external view returns (ZeekDataTypes.OfferRatio memory){
        return _getWishStorage()._wishById[id].offerRatios[offerType];
    }

    function getWishStructFeePerMonth( uint256 id
    ) external view returns (uint256){
        // return _getWishStorage()._wishById[id].feePerMonth;
        return 0;
    }

    function getWishStructFeeTokenVersion( uint256 id
    ) external view returns (uint256){
        // return _getWishStorage()._wishById[id].feeTokenVersion;
        return 0;
    }

    function getWishStructFeeToken( uint256 id
    ) external view returns (address){
        // return _getWishStorage()._wishById[id].feeToken;
        return address(0);
    }

    function getWishStructStart( uint256 id
    ) external view returns (uint){
        return _getWishStorage()._wishById[id].start;
    }

    function getWishStructDeadline( uint256 id
    ) external view returns (uint){
        return _getWishStorage()._wishById[id].deadline;
    }

    function getWishStructTimestamp( uint256 id
    ) external view returns (uint){
        return _getWishStorage()._wishById[id].timestamp;
    }

    function getWishStructLastModifyTime( uint256 id
    ) external view returns (uint){
        return _getWishStorage()._wishById[id].modifyTime;
    }

    function getWishStructLinkCode( uint256 id, uint linker
    ) external view returns (string memory){
        // return _getWishStorage()._wishById[id].linkers[linker];
        return "0";
    }

    // function getWishStructCandidatesTalent( uint256 id, uint talentId
    // ) external view returns (ZeekDataTypes.Candidate memory){
    //     return _getWishStorage()._wishById[id].candidates[talentId];
    // }

    function getWishStructOffer( uint256 id
    ) external view returns (ZeekDataTypes.Offer memory){
        return _getWishStorage()._wishById[id].offers[0];
    }

    function setWishStructCandidatesApproveTime(uint wishId, uint talent, uint64 newApproveTime) external{
        // _getWishStorage()._wishById[wishId].candidates[talent].approveTime = newApproveTime;
    }

    function getWishCommissionRate( ZeekDataTypes.WishType wishType
    ) external view returns (ZeekDataTypes.OfferRatio memory){
        return _getWishStorage()._offerRatios[wishType];
    }

    function getWishLinkCommissionRate( ZeekDataTypes.WishType wishType
    ) external view returns (ZeekDataTypes.OfferRatio memory){
        return _getWishStorage()._linkOfferRatios[wishType];
    }

    function getWishOfferRatio( ZeekDataTypes.WishType wishType
    ) external view returns (ZeekDataTypes.OfferRatio memory){
        return _getWishStorage()._offerRatios[wishType];
    }

    function getWishLinkOfferRatio( ZeekDataTypes.WishType wishType
    ) external view returns (ZeekDataTypes.OfferRatio memory){
        return _getWishStorage()._linkOfferRatios[wishType];
    }

    function getWishStructIssuer(uint256 id
    ) external view returns (uint256){
        return _getWishStorage()._wishById[id].issuer;
    }

    function getWishIssueFee(ZeekDataTypes.WishType wishType
    ) external view returns (uint){
        // return _getWishStorage()._issueFees[wishType];
        return 0;
    }

    function getWishIssueFeeToken(
    ) external view returns (address){
        // return _getWishStorage()._issueFeeToken;
        return address(0);
    }

    function getWishIssueFeeTokenVersion(
    ) external view returns (uint){
        // return _getWishStorage()._issueFeeTokenVersion;
        return 0;
    }

    function getWishUnlock(uint256 id, uint256 profileId
    ) external view returns (ZeekDataTypes.Unlock memory) {
        return _getWishStorage()._wishById[id].unlocks[profileId];
    }

    function getWishStructPrice(uint256 id)
    external view returns (ZeekDataTypes.WishTokenValue memory) {
        return _getWishStorage()._wishById[id].price;
    }

    function getWishStructRestricted(uint256 id)
    external view returns (bool) {
        return _getWishStorage()._wishById[id].restricted;
    }

    function getWishStructOfferRatio(uint256 id, ZeekDataTypes.OfferType offerType)
    external view returns (ZeekDataTypes.OfferRatio memory) {
        return _getWishStorage()._wishById[id].offerRatios[offerType];
    }

    function getWishStructFinishTime(uint256 id)
    external view returns (uint64) {
        return _getWishStorage()._wishById[id].finishTime;
    }

    function getWishStructTokenValue(uint256 id) external view returns (ZeekDataTypes.TokenValue memory) {
        return _getWishStorage()._wishById[id].quote;
    }

    function estimateFeeUseForTest(
        uint64 start,
        uint64 deadline,
        ZeekDataTypes.WishType wishType
    ) external view returns (ZeekDataTypes.EstimateFee memory) {
        return
        ZeekDataTypes.EstimateFee(
            _getWishStorage()._offerRatios[
            wishType
            ],
            _getWishStorage()._offerRatios[
            wishType
            ]
        );
    }

    function _calculateFeeUseForTest(
        uint64 start,
        uint64 deadline,
        uint feePerMonth
    ) internal pure returns (uint256) {
        // return ((deadline - start) / 2592000 + 1) * feePerMonth ;
        //        if (start == deadline){
        //            return feePerMonth;
        //        }
        //        if ((deadline - start ) % 2592000 != 0){
        //            return ((deadline - start ) / 2592000 + 1) * feePerMonth;
        //        }else {
        //            return ((deadline - start ) / 2592000) * feePerMonth;
        //        }
        return (deadline - start ) % 2592000 != 0 ? ((deadline - start ) / 2592000 + 1) * feePerMonth : ((deadline - start ) / 2592000) * feePerMonth;
    }

    function calculateWishFeeSharing(
        uint256 bountyFee, bool isLinked
    )  external pure returns (uint256 /*linker*/, uint256 /*platform*/) {
        return isLinked? (bountyFee * 9 / 10 , bountyFee * 1 / 10): (bountyFee * 0 / 10, bountyFee * 10 / 10);
    }

    function calculateQuestionFeeSharing(
        uint256 bountyFee, bool isLinked
    )  external pure returns (uint256 /*linker*/, uint256 /*platform*/) {
        return isLinked? (bountyFee * 9 / 10 , bountyFee * 1 / 10): (bountyFee * 9 / 10, bountyFee * 1 / 10);
    }

    function calculateWishFeeWhenDirectToPlatformAndLinker(
        uint256 bountyFee
    )  external pure returns (uint256, uint256) {
        return (bountyFee * 0 / 10, bountyFee * 10 / 10);
    }


}
