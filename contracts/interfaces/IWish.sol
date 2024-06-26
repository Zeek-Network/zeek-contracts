// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../libraries/ZeekDataTypes.sol";

interface IWish {
    /**
     * Publish Wish
     *
     * @param data vars
     */
    function issueWish(
        ZeekDataTypes.WishIssueData calldata data
    ) external payable returns (uint);

    /**
     * Publish Wish Plugin
     *
     * @param data vars
     * @param issuer payer
     */
    function issueWishPlug(
        ZeekDataTypes.WishIssueData calldata data,
        address issuer
    ) external payable returns (uint256);

    /**
     * Unlock Wish
     *
     * @param data vars
     */
    function unlockWish(
        ZeekDataTypes.WishUnlockData calldata data
    ) external payable;

    /**
     * Returns the wish struct of the given wish id.
     * @param wishId The wish id to query.
     */
    function getWish(
        uint256 wishId
    )
        external
        view
        returns (
            uint256 issuer,
            uint256 owner,
            ZeekDataTypes.WishType wishType,
            bool restricted,
            ZeekDataTypes.WishTokenValue memory price,
            ZeekDataTypes.TokenValue memory quote,
            ZeekDataTypes.WishState state,
            ZeekDataTypes.Offer memory offer,
            ZeekDataTypes.OfferRatio memory linkOfferRatio,
            ZeekDataTypes.OfferRatio memory directOfferRatio,
            uint64 start,
            uint64 deadline,
            uint64 finishTime
        );

    /**
     * Modity wish
     *
     * @param data vars
     */
    function modifyWish(
        ZeekDataTypes.WishModifyData calldata data
    ) external payable;

    /**
     * View offer ratios
     *
     * @param wishId wish type
     */
    function offerRatios(
        uint256 wishId
    )
        external
        view
        returns (
            ZeekDataTypes.OfferRatio memory offerRatio,
            ZeekDataTypes.OfferRatio memory offerBonusRatio,
            ZeekDataTypes.OfferRatio memory linkOfferRatio,
            ZeekDataTypes.OfferRatio memory linkOfferBonusRatio
        );

    function offerRatiosByType(
        ZeekDataTypes.WishType t,
        uint256 bonus
    )
        external
        view
        returns (
            ZeekDataTypes.OfferRatio memory offerRatio,
            ZeekDataTypes.OfferRatio memory offerBonusRatio,
            ZeekDataTypes.OfferRatio memory linkOfferRatio,
            ZeekDataTypes.OfferRatio memory linkOfferBonusRatio
        );

    /**
     * View Unlock Tokens including fore unlock token and normal unlock token
     */
    function getWishToken(
        address token
    )
        external
        view
        returns (
            ZeekDataTypes.TokenValueSet memory minIssueTokens,
            ZeekDataTypes.TokenValueSet memory earlyUnlockRatio,
            ZeekDataTypes.TokenValueSet memory unlockRatio,
            uint256 cutDecimals
        );

    /**
     * View Unlock Ratios
     *
     * @return foreUnlockRatio unlock ratio for fore case
     * @return unlockRatio unlock ratio for normal case
     */
    function getWishRatios()
        external
        view
        returns (
            ZeekDataTypes.UnlockRatio memory foreUnlockRatio,
            ZeekDataTypes.UnlockRatio memory unlockRatio,
            ZeekDataTypes.BidRatio memory bidRatio
        );

    /**
     * Refund wish
     * It'll lead wish to Closed state
     *
     * @param data vars
     */
    function refundWish(ZeekDataTypes.WishRefundData calldata data) external;

    /**
     * Offer wish
     * It'll lead wish to Finished state
     *
     * @param vars data
     * @param applySig apply signature by the applier
     */
    function offerWish(
        ZeekDataTypes.WishApplyData calldata vars,
        ZeekDataTypes.EIP712Signature calldata applySig
    ) external;

    /**
     * Bid Wish
     *  - who: anyone who has profile
     * @param data vars
     */
    function bidWish(ZeekDataTypes.WishBidData calldata data) external payable;

    /**
     * Ask Wish
     *  - who: owner
     * @param data vars
     */
    function askWish(ZeekDataTypes.WishAskData calldata data) external payable;

    /**
     * Cut Wish
     * @param data vars
     */
    function cutWish(ZeekDataTypes.WishCutData calldata data) external;
}
