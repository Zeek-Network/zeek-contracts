// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../base/WishBase.sol";
import "../interfaces/IWish.sol";
import "../libraries/ZeekDataTypes.sol";
import "../libraries/ZeekErrors.sol";
import "../libraries/Constants.sol";

/**
 *  Wish Logic
 *
 * @title Wish
 * @author zeeker
 *
 * @dev zeeker
 */
contract Wish is IWish, WishBase {
    /// @inheritdoc IWish
    function issueWish(
        ZeekDataTypes.WishIssueData calldata data
    ) public payable override returns (uint256) {
        return _issueWish(data, _msgSender());
    }

    /// @inheritdoc IWish
    function issueWishPlug(
        ZeekDataTypes.WishIssueData calldata data,
        address issuer
    ) public payable override returns (uint256) {
        if (!_getGovernanceStorage()._appWhitelisted[_msgSender()]) {
            revert ZeekErrors.AppNotWhitelisted();
        }
        return _issueWish(data, issuer);
    }

    /// @inheritdoc IWish
    function bidWish(ZeekDataTypes.WishBidData calldata data) external payable {
        return _bidWish(data);
    }

    /// @inheritdoc IWish
    function cutWish(ZeekDataTypes.WishCutData calldata data) external {
        return _cutWish(data);
    }

    /// @inheritdoc IWish
    function askWish(ZeekDataTypes.WishAskData calldata data) external payable {
        return _askWish(data);
    }

    /// @inheritdoc IWish
    function offerWish(
        ZeekDataTypes.WishApplyData calldata vars,
        ZeekDataTypes.EIP712Signature calldata applySig
    ) external override {
        _validateRecoveredAddress(
            _calculateDigest(
                keccak256(
                    abi.encode(
                        ZeekDataTypes.OFFER_WISH_WITH_SIG_TYPEHASH,
                        vars.wishId,
                        vars.talent,
                        vars.linker,
                        vars.applyTime,
                        vars.applyNonce,
                        applySig.deadline
                    )
                )
            ),
            vars.talent,
            applySig
        );

        _offerWish(vars);
    }

    /// @inheritdoc IWish
    function unlockWish(
        ZeekDataTypes.WishUnlockData calldata data
    ) external payable override {
        _unlockWish(data);
    }

    /// @inheritdoc IWish
    function refundWish(
        ZeekDataTypes.WishRefundData calldata data
    ) external override {
        // _refundWish(data);
    }

    /// @inheritdoc IWish
    function modifyWish(
        ZeekDataTypes.WishModifyData calldata data
    ) external payable override {
        // _modifyWish(data);
    }

    /// @inheritdoc IWish
    function getWish(
        uint256 wishId
    )
        external
        view
        override
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
        )
    {
        ZeekDataTypes.WishStruct storage wish = _getWish(wishId);
        ZeekDataTypes.Offer memory bo = _bestOffer(wish);
        return (
            wish.issuer,
            wish.owner,
            wish.wishType,
            wish.restricted,
            wish.price,
            wish.quote,
            wish.state,
            bo,
            wish.offerRatios[ZeekDataTypes.OfferType.Link],
            wish.offerRatios[ZeekDataTypes.OfferType.Direct],
            wish.start,
            wish.deadline,
            wish.finishTime
        );
    }

    /// @inheritdoc IWish
    function offerRatios(
        uint256 wishId
    )
        external
        view
        override
        returns (
            ZeekDataTypes.OfferRatio memory offerRatio,
            ZeekDataTypes.OfferRatio memory offerBonus,
            ZeekDataTypes.OfferRatio memory linkOfferRatio,
            ZeekDataTypes.OfferRatio memory linkOfferBonus
        )
    {
        ZeekDataTypes.WishStruct storage wish = _getWish(wishId);
        return (
            wish.offerRatios[ZeekDataTypes.OfferType.Direct],
            _calOfferBonus(wish.price.balance, wish.offerRatios[ZeekDataTypes.OfferType.Direct]),
            wish.offerRatios[ZeekDataTypes.OfferType.Link],
            _calOfferBonus(wish.price.balance, wish.offerRatios[ZeekDataTypes.OfferType.Link])
        );
    }

    /// @inheritdoc IWish
    function offerRatiosByType(
        ZeekDataTypes.WishType t,
        uint256 bonus
    )
        external
        view
        override
        returns (
            ZeekDataTypes.OfferRatio memory offerRatio,
            ZeekDataTypes.OfferRatio memory offerBonus,
            ZeekDataTypes.OfferRatio memory linkOfferRatio,
            ZeekDataTypes.OfferRatio memory linkOfferBonus
        )
    {
        return (
            _getWishStorage()._offerRatios[t],
            _calOfferBonus(bonus, _getWishStorage()._offerRatios[t]),
            _getWishStorage()._linkOfferRatios[t],
            _calOfferBonus(bonus, _getWishStorage()._linkOfferRatios[t])
        );
    }

    /// @inheritdoc IWish
    function getWishToken(
        address token
    )
        external
        view
        override
        returns (
            ZeekDataTypes.TokenValueSet memory minIssueTokens,
            ZeekDataTypes.TokenValueSet memory earlyUnlockRatio,
            ZeekDataTypes.TokenValueSet memory unlockRatio,
            uint256 cutDecimals
        )
    {
        return (
            _getWishStorage()._minIssueTokens[token],
            _getWishStorage()._earlyUnlockTokens[token],
            _getWishStorage()._unlockTokens[token],
            _getWishStorage()._cutDecimals[token]
        );
    }

    /// @inheritdoc IWish
    function getWishRatios()
        external
        view
        override
        returns (
            ZeekDataTypes.UnlockRatio memory earlyUnlockRatio,
            ZeekDataTypes.UnlockRatio memory unlockRatio,
            ZeekDataTypes.BidRatio memory bidRatio
        )
    {
        return (
            _getWishStorage()._earlyUnlockRatio,
            _getWishStorage()._unlockRatio,
            _getWishStorage()._bidRatio
        );
    }

    /**
     * Issue Wish Proxy Function
     * @param data data
     * @param issuer issuer
     */
    function _issueWish(
        ZeekDataTypes.WishIssueData calldata data,
        address issuer
    ) internal returns (uint256) {
        (ZeekDataTypes.WishStruct storage wish, uint256 wishId) = _issue(
            data,
            issuer
        );

        emit ZeekEvents.WishIssued(
            wishId,
            wish.issuer,
            wish.owner,
            wish.wishType,
            wish.restricted,
            ZeekDataTypes.WishTokenValue(
                wish.price.token,
                wish.price.tokenVersion,
                wish.price.value,
                wish.price.bidValue,
                wish.price.balance
            ),
            _calOfferBonus(wish.price.balance, wish.offerRatios[ZeekDataTypes.OfferType.Direct]),
            _calOfferBonus(wish.price.balance, wish.offerRatios[ZeekDataTypes.OfferType.Link]),
            wish.start,
            wish.deadline,
            data.salt
        );
        return wishId;
    }

    /**
     * Issue Wish Action function
     * @param data issue wish data
     */
    function _issue(
        ZeekDataTypes.WishIssueData calldata data,
        address issuer
    ) internal returns (ZeekDataTypes.WishStruct storage, uint256) {
        // issue validation
        _issueValidation(data);
        // storage and logic change
        (
            uint wishId,
            ZeekDataTypes.WishStruct storage wish
        ) = _createWishStorage(data, issuer);
        // then stake
        _stakeTokens(wishId, payable(issuer), data.bonus);

        return (wish, wishId);
    }

    /**
     * Unlock Wish Proxoy Function
     * @param data data
     */
    function _unlockWish(ZeekDataTypes.WishUnlockData calldata data) internal {
        (, uint256 unlocker) = _unlock(
            data
        );

        emit ZeekEvents.WishUnlocked(data.wishId, unlocker, data.timestamp);
    }

    function _unlock(
        ZeekDataTypes.WishUnlockData calldata data
    ) internal returns (ZeekDataTypes.WishStruct storage, uint256 talent) {
        ZeekDataTypes.WishStruct storage wish = _getWish(data.wishId);

        uint256 unlocker = _unlockValidation(data, wish);

        // storage change
        wish.unlocks[unlocker].token = data.token;
        wish.unlocks[unlocker].tokenVersion = data.tokenVersion;
        wish.unlocks[unlocker].value = data.value;
        wish.unlocks[unlocker].timestamp = uint64(block.timestamp);

        // token allocation
        _unlockAllocate(
            data.wishId,
            data.token,
            data.tokenVersion,
            data.value,
            _bestOffer(wish).talent
        );

        return (wish, unlocker);
    }

    /**
     * Sponsor Wish Proxy Function
     * @param data data
     */
    function _bidWish(ZeekDataTypes.WishBidData calldata data) internal {
        ZeekDataTypes.WishStruct storage wish = _bid(data);

        // emit event
        emit ZeekEvents.WishTransferred(
            data.wishId,
            wish.owner,
            ZeekDataTypes.WishTransferType.Bid,
            wish.price.value,
            wish.price.bidValue,
            wish.modifyTime
        );
    }

    /**
     * Bid Wish Action Function
     * @param data data
     */
    function _bid(
        ZeekDataTypes.WishBidData calldata data
    ) internal returns (ZeekDataTypes.WishStruct storage) {
        ZeekDataTypes.WishStruct storage wish = _getWish(data.wishId);

        uint256 lastPrice = wish.price.value;
        uint256 lastOwner = wish.owner;
        uint256 nextPrice = wish.price.bidValue;
        uint256 bidder = _bidValidation(wish, nextPrice);

        // switch best answer is not allowed
        // storage change
        wish.price.value = nextPrice;
        wish.price.bidValue = _bidPrice(wish.price.token, nextPrice);
        wish.owner = bidder;
        wish.modifyTime = uint64(block.timestamp);

        // offer Bonus to all
        _bidAllocate(data.wishId, wish, lastOwner, lastPrice, nextPrice);

        return wish;
    }

    /**
     * Sponsor Wish Proxy Function
     * @param data data
     */
    function _askWish(ZeekDataTypes.WishAskData calldata data) internal {
        ZeekDataTypes.WishStruct storage wish = _ask(data);

        // emit event
        emit ZeekEvents.WishTransferred(
            data.wishId,
            wish.owner,
            ZeekDataTypes.WishTransferType.Ask,
            wish.price.value,
            wish.price.bidValue,
            wish.modifyTime
        );
    }

    /**
     * Bid Wish Action Function
     * @param data data
     */
    function _ask(
        ZeekDataTypes.WishAskData calldata data
    ) internal returns (ZeekDataTypes.WishStruct storage) {
        ZeekDataTypes.WishStruct storage wish = _getWish(data.wishId);

        // not zero,
        uint256 asker = _askValidation(wish);

        uint256 lastOwner = wish.owner;
        // switch best answer is not allowed
        // storage change
        wish.price.token = wish.quote.token;
        wish.price.tokenVersion = wish.quote.tokenVersion;
        wish.price.value = wish.quote.value;
        wish.price.bidValue = _bidPrice(
            wish.price.token,
            wish.price.value
        );
        wish.quote.value = 0; // clear quote
        wish.owner = asker;
        wish.modifyTime = uint64(block.timestamp);

        // offer Bonus to all
        _askAllocate(lastOwner, wish.price);

        return wish;
    }

    /**
     * Sponsor Wish Proxy Function
     * @param data data
     */
    function _cutWish(ZeekDataTypes.WishCutData calldata data) internal {
        ZeekDataTypes.WishStruct storage wish = _cut(data);
        // emit event
        emit ZeekEvents.WishCut(data.wishId, wish.quote, wish.modifyTime);
    }

    /**
     * Cut Wish Action Function
     * @param data data
     */
    function _cut(
        ZeekDataTypes.WishCutData calldata data
    ) internal returns (ZeekDataTypes.WishStruct storage) {
        ZeekDataTypes.WishStruct storage wish = _getWish(data.wishId);
        _cutValidation(data, wish);
        // switch best answer is not allowed
        // storage change
        wish.quote = ZeekDataTypes.TokenValue(
            wish.price.token,
            wish.price.tokenVersion,
            data.quote
        );
        // wish.quote.tokenVersion = newQuote.tokenVersion;
        // wish.quote.tokenVersion = newQuote.tokenVersion;
        wish.modifyTime = uint64(block.timestamp);

        return wish;
    }

    /**
     * Offer Wish Proxy Function
     * @param data data
     */
    function _offerWish(ZeekDataTypes.WishApplyData calldata data) internal {
        // change wish first
        (ZeekDataTypes.Offer memory offerData, uint256 owner, ZeekDataTypes.OfferRatio memory offerValues) = _offer(data);

        // emit wish offered event
        emit ZeekEvents.WishOffered(
            data.wishId,
            offerData.talent,
            offerData.linker,
            owner,
            offerValues,
            offerData.applyTime,
            offerData.applyNonce,
            uint64(block.timestamp)
        );
    }

    /**
     * Offer Wish Action Function
     * @param data offer wish data
     */
    function _offer(
        ZeekDataTypes.WishApplyData calldata data
    ) internal returns (ZeekDataTypes.Offer memory, uint256 owner, ZeekDataTypes.OfferRatio memory offerBonus) {
        ZeekDataTypes.WishStruct storage wishStruct = _getWish(data.wishId);

        (uint256 talent, uint256 linker) = _offerValidation(data, wishStruct);

        // storage change
        ZeekDataTypes.Offer memory offer = ZeekDataTypes.Offer(
            talent,
            linker,
            data.applyNonce,
            data.applyTime,
            uint64(block.timestamp)
        );
        wishStruct.offers.push(offer);
        wishStruct.finishTime = uint64(block.timestamp);
        wishStruct.state = ZeekDataTypes.WishState.Finished;

        // offer Bonus to all
        ZeekDataTypes.OfferRatio memory ob = _bonusAllocate(data.wishId, offer);

        return (offer, wishStruct.owner, ob);
    }

    /**
     * Modify Wish Proxy Function
     * @param data data
     */
    function _modifyWish(ZeekDataTypes.WishModifyData calldata data) internal {
        ZeekDataTypes.WishStruct storage wish = _modify(data);

        emit ZeekEvents.WishModified(
            data.wishId,
            wish.price.balance,
            wish.deadline,
            wish.modifyTime
        );
    }

    /**
     * Modify Wish Action Function
     * @param data modify wish data
     */
    function _modify(
        ZeekDataTypes.WishModifyData calldata data
    ) internal returns (ZeekDataTypes.WishStruct storage) {
        ZeekDataTypes.WishStruct storage wish = _getWish(data.wishId);

        _modifyValidation(data, wish);

        // storage change
        wish.deadline = data.deadline;
        wish.modifyTime = uint64(block.timestamp);

        // stake more, only append by the original token
        // only do stake for the increaseValue greater than 0
        if (data.increaseBonus > 0) {
            _stakeTokens(
                data.wishId,
                payable(_msgSender()),
                ZeekDataTypes.TokenValue(
                    wish.price.token,
                    wish.price.tokenVersion,
                    data.increaseBonus
                )
            );
        }

        return wish;
    }

    /**
     * Refund Wish Proxy Function
     *
     * @param data data
     */
    function _refundWish(ZeekDataTypes.WishRefundData calldata data) internal {
        _refund(data);

        emit ZeekEvents.WishClosed(data.wishId, uint64(block.timestamp));
    }

    /**
     * Refund Wish Action Function
     * @param data data
     */
    function _refund(ZeekDataTypes.WishRefundData calldata data) internal {
        ZeekDataTypes.WishStruct storage wishStruct = _getWish(data.wishId);

        _refundValidation(wishStruct);

        // storage change
        wishStruct.state = ZeekDataTypes.WishState.Closed;
        wishStruct.finishTime = uint64(block.timestamp);

        // refund to wish owner part
        // _getWishStorage()._wishById[data.wishId].value;

        // story1: no application. refund all to wish owner
        _sendTokens(
            data.wishId,
            payable(_msgSender()),
            wishStruct.price.balance
        );

        // TODO punishment, depends on product
    }

    /**
     * Create Wish storage change function
     * @param data issue wish data
     */
    function _createWishStorage(
        ZeekDataTypes.WishIssueData calldata data,
        address issuer
    ) internal returns (uint256, ZeekDataTypes.WishStruct storage) {
        WishStorage storage wishStorage = _getWishStorage();

        uint256 profileId = _validateHasProfile(issuer);

        wishStorage._wishHistorySalt[data.salt] = true;
        // storage change
        uint256 tokenId = ++wishStorage._wishCounter;

        wishStorage._wishById[tokenId].issuer = profileId;
        wishStorage._wishById[tokenId].owner = profileId;
        wishStorage._wishById[tokenId].wishType = data.wishType;

        wishStorage._wishById[tokenId].price.token = data.bonus.token;
        wishStorage._wishById[tokenId].price.tokenVersion = data
            .bonus
            .tokenVersion;
        wishStorage._wishById[tokenId].price.value = data.bonus.value;
        wishStorage._wishById[tokenId].price.bidValue = _bidPrice(
            data.bonus.token,
            data.bonus.value
        );
        // balance will be append in stake stage
        wishStorage._wishById[tokenId].price.balance = 0;

        wishStorage._wishById[tokenId].state = ZeekDataTypes.WishState.Active;
        wishStorage._wishById[tokenId].restricted = data.restricted;
        wishStorage._wishById[tokenId].offerRatios[
            ZeekDataTypes.OfferType.Direct
        ] = wishStorage._offerRatios[data.wishType];
        wishStorage._wishById[tokenId].offerRatios[
            ZeekDataTypes.OfferType.Link
        ] = wishStorage._linkOfferRatios[data.wishType];
        // time related
        wishStorage._wishById[tokenId].start = data.start;
        wishStorage._wishById[tokenId].deadline = data.deadline;
        wishStorage._wishById[tokenId].timestamp = uint64(block.timestamp);

        return (tokenId, wishStorage._wishById[tokenId]);
    }
}
