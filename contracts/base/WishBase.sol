// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../base/ZeekBase.sol";
import "../libraries/ZeekDataTypes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract WishBase is ZeekBase {

    using SafeERC20 for IERC20;

    function _getWish(
        uint256 wishId
    ) internal view returns (ZeekDataTypes.WishStruct storage) {
        return _getWishStorage()._wishById[wishId];
    }

    /**
     * Issue Wish Validation
     * 
     * @param data wish issue data
     */
    function _issueValidation(
        ZeekDataTypes.WishIssueData calldata data
    ) internal returns (bool) {
        if (_getWishStorage()._wishHistorySalt[data.salt]) {
            revert ZeekErrors.WishSaltProcessed();
        }
        
        _validateMsgValue(data.bonus.tokenVersion, data.bonus.value);
        _validateWishTime(data.start, data.deadline);
        _validateMinimumTokens(data.bonus.token, data.bonus.value);

        return true;
    }

    function _offerValidation(ZeekDataTypes.WishApplyData calldata data,
        ZeekDataTypes.WishStruct storage wishStruct
    ) internal view returns (uint256 t, uint256 l) {
        _validateWishOwner(wishStruct.owner);
        _validateWishState(wishStruct.state, ZeekDataTypes.WishState.Active);

        uint256 talent = _validateHasProfile(data.talent);
        _validateImproperProfile(wishStruct.owner, talent);
        // validate linker if given
        uint256 linker;
        if (data.linker != address(0)) {
            linker = _validateHasProfile(data.linker);
            _validateImproperProfile(linker, talent);
            _validateImproperProfile(wishStruct.owner, linker);
        }
        return (talent, linker);
    }

    function _refundValidation(ZeekDataTypes.WishStruct storage wishStruct) internal view {
        _validateWishOwner(wishStruct.owner);
        _validateWishState(wishStruct.state, ZeekDataTypes.WishState.Active);
    }

    function _modifyValidation(ZeekDataTypes.WishModifyData calldata data,
        ZeekDataTypes.WishStruct storage wish
    ) internal {
        _validateMsgValue(wish.price.tokenVersion, data.increaseBonus);
        _validateWishOwner(wish.owner);
        _validateWishTime(wish.start, data.deadline);
    }

    function _unlockValidation(ZeekDataTypes.WishUnlockData calldata data, 
        ZeekDataTypes.WishStruct storage wish
    ) internal returns (uint256 u) {
        _validateRestricted(wish);
        uint256 unlocker = _validateHasProfile(_msgSender());
        if (wish.unlocks[unlocker].timestamp != 0) {
            revert ZeekErrors.WishAlreadyUnlocked();
        }
        _validateImproperProfile(wish.issuer, unlocker);
        _validateImproperProfile(wish.owner, unlocker);
        _validateUnlockValue(data, wish.state == ZeekDataTypes.WishState.Active);

        return unlocker;
    }

    function _bidValidation(ZeekDataTypes.WishStruct storage wish, uint256 checkValue
    ) internal returns (uint256 b) {
        _validateRestricted(wish);
        _validateWishState(wish.state, ZeekDataTypes.WishState.Finished);
        uint256 bidder = _validateHasProfile(_msgSender());
        _validateImproperProfile(wish.owner, bidder);
        _validateMsgValue(wish.price.tokenVersion, checkValue);
        return bidder;
    }

    function _askValidation(ZeekDataTypes.WishStruct storage wish
    ) internal returns (uint256 b) {
        _validateRestricted(wish);
        _validateWishState(wish.state, ZeekDataTypes.WishState.Finished);
        if (wish.quote.value == 0) {
            revert ZeekErrors.WishInvalidParameter();
        }
        _validateMsgValue(wish.quote.tokenVersion, wish.quote.value);
        uint256 asker = _validateHasProfile(_msgSender());
        _validateImproperProfile(wish.owner, asker);

        return asker;
    }

    function _cutValidation(ZeekDataTypes.WishCutData memory data,
        ZeekDataTypes.WishStruct storage wish
    ) internal view returns (uint256 b) {
        _validateRestricted(wish);
        _validateWishOwner(wish.owner);
        _validateWishState(wish.state, ZeekDataTypes.WishState.Finished);
        _validateMinimumTokens(wish.price.token, data.quote);
        if (data.quote > wish.price.value) {
            revert ZeekErrors.WishInvalidParameter();
        }
        return wish.quote.value;
    }

    function _validateUnlockValue(ZeekDataTypes.WishUnlockData calldata data, bool earlyBird) internal {
        (uint tokenVersion, uint256 value) = _unlockToken(data.token, earlyBird);
        if (tokenVersion != data.tokenVersion || value != data.value) {
            revert ZeekErrors.IncorrectTokenValue();
        }
        _validateMsgValue(tokenVersion, value);
    }

    function _unlockToken(address token, bool earlyBird) internal view returns (uint tokenVersion, uint256 value) {
        if (earlyBird) {
            return (_getWishStorage()._earlyUnlockTokens[token].tokenVersion, _getWishStorage()._earlyUnlockTokens[token].value);
        } else {
            return (_getWishStorage()._unlockTokens[token].tokenVersion, _getWishStorage()._unlockTokens[token].value);
        }
    }

    function _unlockRatio(bool earlyBird) internal view returns (ZeekDataTypes.UnlockRatio storage unlockRatio) {
        if (earlyBird) {
            return _getWishStorage()._earlyUnlockRatio;
        } else {
            return _getWishStorage()._unlockRatio;
        }
    }

    /**
     * Wish Time Validation
     * 
     * @param start start time
     * @param deadline end time
     */
    function _validateWishTime(uint256 start, uint256 deadline) internal view {
        if (start >= deadline) {
            revert ZeekErrors.WishInvalidParameter();
        }
        if (deadline < uint64(block.timestamp)) {
            revert ZeekErrors.WishInvalidParameter();
        }
    }

    /**
     * Msg.Value Validation
     * 
     * @param tokenVersion token version
     * @param tokenValue token value
     */
    function _validateMsgValue(
        uint256 tokenVersion,
        uint256 tokenValue
    ) internal {
        // check ETH required
        uint256 valueRequired;
        if (tokenVersion == 0) {
            valueRequired = tokenValue;
        }
        if (msg.value != valueRequired) {
            revert ZeekErrors.InsufficientBalance();
        }
    }

    /**
     * Validate the wish owner prilligcy
     * 
     * @param ownerProfileId wish owner profile id
     */
    function _validateWishOwner(
        uint256 ownerProfileId
    ) internal view returns (uint256) {
        uint256 profileId = _validateHasProfile(_msgSender());
        if (profileId != ownerProfileId) {
            revert ZeekErrors.NotWishOwner();
        }
        return profileId;
    }

    /**
     * Wish operator cannot be wish owner
     */
    function _validateImproperProfile(uint256 owner, uint256 profile) internal pure {
        if (owner == profile) {
            revert ZeekErrors.WishInvalidParameter();
        }
    }

    /**
     * Wish State Validation
     * 
     * @param state check state 
     * @param expectState expect state
     */
    function _validateWishState(
        ZeekDataTypes.WishState state,
        ZeekDataTypes.WishState expectState
    ) internal pure {
        if (state != expectState) {
            revert ZeekErrors.InvalidWishState();
        }
    }

    function _validateMinimumTokens(address token, uint256 value) internal view {
        ZeekDataTypes.TokenValueSet memory restrict = _getWishStorage()._minIssueTokens[token];
        if (restrict.value == 0) {
            revert ZeekErrors.WishInvalidParameter();
        }
        if (value < restrict.value) {
            revert ZeekErrors.WishInvalidParameter();
        }
    }

    function _validateRestricted(ZeekDataTypes.WishStruct storage wish) internal view{
        if (!wish.restricted) {
            revert ZeekErrors.UnsupportedOperation();
        }
    }

    function _stakeTokens(
        uint wishId,
        address payable from,
        ZeekDataTypes.TokenValue memory bonus
    ) internal {
        if (bonus.value == 0) {
            revert ZeekErrors.InvalidWishAmount();
        }

        WishStorage storage wishStorage = _getWishStorage();
        wishStorage._wishById[wishId].price.balance =
            wishStorage._wishById[wishId].price.balance +
            bonus.value; // increments the balance of the wish

        if (bonus.tokenVersion == 20) {
            if (msg.value != 0) {
                // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
            }

            IERC20(bonus.token).safeTransferFrom(
                from,
                address(this),
                bonus.value
            );
        } else if (bonus.tokenVersion != 0) {
            revert ZeekErrors.WishUnsupportedToken();
        }
    }

    function _sendTokens(
        uint wishId,
        address payable to,
        uint256 amount
    ) internal {
        if (amount == 0) {
            revert ZeekErrors.InvalidWishAmount();
        }

        ZeekDataTypes.WishStruct storage wish = _getWish(wishId);

        if (amount > wish.price.balance) {
            revert ZeekErrors.WishInsufficientBalance();
        }
        unchecked {
            // sub from contract
            wish.price.balance = wish.price.balance - amount;
        }

        _baseTransfer(wish.price.tokenVersion, wish.price.token, amount, address(this), to);
    }

    function _bonusAllocate(
        uint wishId,
        ZeekDataTypes.Offer memory offer
    ) internal returns (ZeekDataTypes.OfferRatio memory b) {
        ZeekDataTypes.WishStruct storage wish = _getWish(wishId);

        ZeekDataTypes.OfferType cType = ZeekDataTypes.OfferType.Direct;
        if (offer.linker != 0) {
            cType = ZeekDataTypes.OfferType.Link;
        }
        ZeekDataTypes.OfferRatio memory bonus = _calOfferBonus(wish.price.balance, wish.offerRatios[cType]);
        // start to distribute
        if (bonus.talent > 0) {
            _sendTokens(
                wishId,
                payable(_getProfileStorage()._profileById[offer.talent].owner),
                bonus.talent
            );
        }
        if (bonus.linker > 0 && offer.linker > 0) {
            _sendTokens(
                wishId,
                payable(_getProfileStorage()._profileById[offer.linker].owner),
                bonus.linker
            );
        }
        if (bonus.platform > 0) {
            _sendTokens(
                wishId,
                payable(_getGovernanceStorage()._finance),
                bonus.platform
            );
        }
        return bonus;
    }

    function _unlockAllocate(
        uint wishId,
        address token,
        uint256 tokenVersion,
        uint256 value,
        uint256 talent
    ) internal {
        ZeekDataTypes.WishStruct storage wish = _getWish(wishId);
        ZeekDataTypes.UnlockRatio storage rate = _unlockRatio(wish.state == ZeekDataTypes.WishState.Active);

        uint256 posterNum = value * rate.issuer / 100;
        if (posterNum > value) {
            revert ZeekErrors.InvalidWishRatio();
        }
        uint256 ownerNum = value * rate.owner / 100;
        if (ownerNum + posterNum > value) {
            revert ZeekErrors.InvalidWishRatio();
        }
        uint256 talentNum = value * rate.talent / 100;
        if (talentNum > 0 && talent == 0) {
            revert ZeekErrors.InvalidWishRatio();
        }

        uint256 clientNum = posterNum + ownerNum + talentNum;
        if (clientNum > value) {
            revert ZeekErrors.InvalidWishRatio();
        }
        uint256 platformNum = value - clientNum;
        // start to allocate
        _vault(wish.issuer, wishId, token, tokenVersion, posterNum, ZeekDataTypes.WishScene.Unlock, ZeekDataTypes.WishParticipant.Issuer);
        _vault(wish.owner, wishId, token, tokenVersion, ownerNum, ZeekDataTypes.WishScene.Unlock, ZeekDataTypes.WishParticipant.Owner);
        _vault(talent, wishId, token, tokenVersion, talentNum, ZeekDataTypes.WishScene.Unlock, ZeekDataTypes.WishParticipant.Talent);

        if (platformNum > 0) {
            _baseTransfer(tokenVersion, token, platformNum, payable(_msgSender()), payable(_getGovernanceStorage()._finance));
        }
        if (clientNum > 0) {
            _baseCustody(tokenVersion, token, clientNum, payable(_msgSender()));
        }

    }

    function _bidAllocate(
        uint wishId,
        ZeekDataTypes.WishStruct storage wish,
        uint256 lastOwner,
        uint256 lastValue,
        uint256 value
    ) internal {
        ZeekDataTypes.BidRatio storage rate = _getWishStorage()._bidRatio;

        uint256 ownerValue = lastValue + lastValue * rate.owner / 100;
        uint256 talentValue = lastValue * rate.talent / 100;

        uint256 committeeValue = value - ownerValue - talentValue;
        // start to allocate
        // only best answer to vault
        _vault(_bestOffer(wish).talent, wishId, wish.price.token, wish.price.tokenVersion, talentValue, ZeekDataTypes.WishScene.Bid, ZeekDataTypes.WishParticipant.Talent);

        // transfer to owner directly
        if (ownerValue > 0) {
            _baseTransfer(wish.price.tokenVersion, wish.price.token, ownerValue, payable(_msgSender()), payable(_getProfileStorage()._profileById[lastOwner].owner));
        }

        if (talentValue > 0) {
            _baseCustody(wish.price.tokenVersion, wish.price.token, talentValue, payable(_msgSender()));
        }
        if (committeeValue > 0) {
            _baseTransfer(wish.price.tokenVersion, wish.price.token, committeeValue, payable(_msgSender()), payable(_getGovernanceStorage()._finance));
        }
    }

    function _askAllocate(
        uint256 lastOwner,
        ZeekDataTypes.WishTokenValue storage balance
    ) internal {
        // start to allocate
        if (balance.value > 0) {
            _baseTransfer(balance.tokenVersion, balance.token, balance.value, 
                payable(_msgSender()), payable(_getProfileStorage()._profileById[lastOwner].owner));
        }
    }

    function _bestOffer(ZeekDataTypes.WishStruct storage wish) internal view returns (ZeekDataTypes.Offer memory offer) {
        if (wish.offers.length > 0) {
            return wish.offers[0];
        } else {
            return ZeekDataTypes.Offer(0,0,0,0,0);
        }
    }

    function _vault(uint256 profile, 
        uint wishId,
        address token, 
        uint256 tokenVersion, 
        uint256 value, 
        ZeekDataTypes.WishScene scene,
        ZeekDataTypes.WishParticipant role
    ) internal {
        if (value == 0) {
            return;
        }
        ZeekDataTypes.Vault storage vault = _getProfileStorage()._vaults[profile][token];
        if (vault.timestamp == 0) {
            vault.tokenVersion = tokenVersion;
            vault.timestamp = uint64(block.timestamp);
            _getProfileStorage()._vaultTokens[profile].push(token);
        }
        
        vault.claimable = vault.claimable + value;

        emit ZeekEvents.Vaulted(profile, wishId, token, tokenVersion, value, scene, role, vault.timestamp);
    }

    function _bidPrice(address token, uint256 value) internal view returns (uint256) {
        return _calPrice(token, _increaseByPercent(value, _getWishStorage()._bidRatio.step));
    }

    function _increaseByPercent(uint256 amount, uint256 percentage) internal pure returns (uint256) {        
        return amount + _percent(amount, percentage);
    }

    function _percent(uint256 amount, uint256 percentage) internal pure returns (uint256) {
        return amount * percentage / 100;
    }

    function _calPrice(address token, uint256 value) internal view returns (uint256) {
        uint256 decimals = _getWishStorage()._cutDecimals[token];
        return Math.ceilDiv(value, 10**(decimals)) * 10**(decimals); 
    }

    function _calOfferBonus(uint256 price, ZeekDataTypes.OfferRatio memory ratio) internal pure returns (ZeekDataTypes.OfferRatio memory bonus) {
        uint256 talentBonus = (price * ratio.talent) / 100;
        if (talentBonus > price) {
            revert ZeekErrors.InvalidWishRatio();
        }
        uint256 linkerBonus = (price * ratio.linker) / 100;
        if (linkerBonus + talentBonus > price) {
            revert ZeekErrors.InvalidWishRatio();
        }
        uint256 platformBonus = price - linkerBonus - talentBonus;

        return ZeekDataTypes.OfferRatio(talentBonus, linkerBonus, platformBonus);
    }

}