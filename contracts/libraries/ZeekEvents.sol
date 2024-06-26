// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ZeekDataTypes} from "./ZeekDataTypes.sol";

library ZeekEvents {

    event ZeekInitialized(uint64 timestamp);

    event BaseURISet(string baseURI, uint64 timestamp);

    /*///////////////////////////////////////////////////////////////
                        Profile Events
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when a profile is created.
     *
     * @param profileId The newly created profile's token ID.
     * @param to The address receiving the profile with the given profile ID.
     * @param timestamp The current block timestamp.
     */
    event ProfileCreated(
        uint256 indexed profileId,
        uint256 indexed salt,
        address indexed to,
        string linkCode,
        uint64 timestamp
    );

    /*///////////////////////////////////////////////////////////////
                        Wish Events
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Emitted when a dispatcher is set for a specific profile.
     *
     * @param wishId The token ID of the wish for which the dispatcher is set.
     * @param owner wish owner
     * @param salt The salt passed by caller
     */
    event WishIssued(
        uint256 indexed wishId,
        uint256 indexed issuer,
        uint256 indexed owner,
        ZeekDataTypes.WishType wishType,
        bool restricted,
        ZeekDataTypes.WishTokenValue price,
        ZeekDataTypes.OfferRatio offerValues,
        ZeekDataTypes.OfferRatio linkOfferValues,
        uint64 start, // bouty excatly start time
        uint64 deadline, // The Unix timestamp before which all submissions must be made, and after which refunds may be processed
        uint256 salt
    );

    /**
     * WishApplyAccepted
     *
     * @param wishId wish id
     * @param talent talent profile
     * @param linker linker profile
     * @param applyTime apply time
     */
    event WishApplyAccepted(
        uint256 indexed wishId,
        uint256 indexed talent,
        uint256 linker,
        uint256 owner,
        uint64 applyTime,
        uint256 applyNonce,
        uint64 timestamp
    );

    /**
     * Wish Offered Event
     *
     * @param wishId wish id
     * @param talent talent profile
     * @param linker linker profile
     * @param applyTime apply time from talent
     * @param timestamp timestamp
     */
    event WishOffered(
        uint256 indexed wishId,
        uint256 indexed talent,
        uint256 linker,
        uint256 owner,
        ZeekDataTypes.OfferRatio values,
        uint64 applyTime,
        uint256 applyNonce,
        uint64 timestamp
    );

    /**
     * Wish Modified Event
     *
     * @param wishId wish id
     * @param timestamp timestamp
     */
    event WishModified(
        uint256 indexed wishId,
        uint256 balance,
        uint64 deadline,
        uint64 timestamp
    );

    /**
     * Wish Linked Event
     * @param wishId wish id
     * @param linker linker profile
     * @param timestamp time stamp
     */
    event WishLinked(
        uint256 indexed wishId,
        uint256 linker,
        uint64 timestamp
    );

    /**
     * Wish Closed Event
     * @param wishId wish id
     * @param timestamp time stamp
     */
    event WishClosed(uint256 indexed wishId, uint64 timestamp);

    /**
     * Wish Unlocked Event
     */
    event WishUnlocked(uint256 indexed wishId, uint256 talent, uint64 timestamp);

    /**
     * Wish Transferred Event
     */
    event WishTransferred(
        uint256 indexed wishId,
        uint256 indexed owner,
        ZeekDataTypes.WishTransferType transferType,
        uint256 price,
        uint256 bidPrice,
        uint64 timestamp
    );

    /**
     * Wish Asked Event
     */
    event WishCut(
        uint256 indexed wishId,
        ZeekDataTypes.TokenValue quote,
        uint64 timestamp
    );

    event Vaulted (
        uint256 indexed talent,
        uint256 indexed wishId,
        address indexed token,
        uint tokenVersion,
        uint256 value,
        ZeekDataTypes.WishScene scene,
        ZeekDataTypes.WishParticipant role,
        uint64 timestamp
    );

    event Claimed (
        uint256 indexed talent,
        address indexed token,
        uint tokenVersion,
        uint256 value,
        uint64 timestamp
    );

    /*///////////////////////////////////////////////////////////////
                        Governance Events
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when the zeek address is changed. We emit the caller even though it should be the previous
     * governance address, as we cannot guarantee this will always be the case due to upgradeability.
     *
     * @param caller The caller who set the governance address.
     * @param priorFinance The previous governance address.
     * @param newFinance The new governance address set.
     * @param timestamp The current block timestamp.
     */
    event ZeekFinanceSet(
        address indexed caller,
        address indexed priorFinance,
        address indexed newFinance,
        uint64 timestamp
    );

    event ZeekWishOfferRatioSet (
        ZeekDataTypes.OfferType indexed offerType,
        ZeekDataTypes.OfferRatio questionOfferRatio,
        ZeekDataTypes.OfferRatio referralOfferRatio
    );

    event ZeekWishUnlockTokenSet (
        uint issuer,
        uint owner,
        uint talent,
        uint platform,
        bool early
    );

    event ZeekWishUnlockRatioSet (
        uint issuer,
        uint owner,
        uint talent,
        uint platform,
        bool early
    );

    event ZeekWishUnlockTokenSet(
        address token,
        uint256 tokenVersion,
        uint256 value,
        bool valid,
        bool early
    );

    event ZeekWishBidRatioSet(
        uint step,
        uint owner,
        uint talent,
        uint platform
    );

    event ZeekWishMiniumIssueTokenSet(
        address token,
        uint256 tokenVersion,
        uint256 value,
        bool valid
    );

    /**
     * Emmited when config changed
     * 
     * @param token token address
     * @param decimals cut decimals
     * @param timestamp time
     */
    event ZeekCutDecimalSet(
        address indexed token,
        uint256 decimals,
        uint64 timestamp
    );

    /**
     * @dev Emitted when a app is added to or removed from the whitelist.
     *
     * @param app The address of the app.
     * @param whitelisted Whether or not the reaction is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event AppWhitelisted(address indexed app, bool indexed whitelisted, uint256 timestamp);
    
}
