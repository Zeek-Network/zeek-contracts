// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

library ZeekDataTypes {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 internal constant OFFER_WISH_WITH_SIG_TYPEHASH = 
        keccak256("OfferWishWithSig(uint256 wishId,address talent,address linker,uint64 applyTime,uint256 applyNonce,uint64 deadline)"
        );

    /*///////////////////////////////////////////////////////////////
                    Wish Type
    //////////////////////////////////////////////////////////////*/
    enum WishType {
        Question,
        Referral
    }

    enum WishState {
        Active,
        Closed,
        Finished
    }

    enum WishTransferType {
        Bid,
        Ask
    }

    enum WishScene {
        Unlock,
        Bid
    }

    enum WishParticipant {
        Issuer,
        Owner,
        Talent
    }

    enum OfferType {
        Direct,
        Link
    }

    /**
     * @dev A struct containing profile data.
     *
     * @param owner The profile's owner.
     * @param linkCode unique link code for profile
     * @param timestamp The timestamp at which this profile was minted.
     */
    struct ProfileStruct {
        address owner;
        string linkCode;
        uint256 timestamp;
    }

    /**
     * Wish Struct
     */
    struct WishStruct {
        uint256 issuer; // An indiviual who is the intial issuer of the wish
        uint256 owner; // An individuals who have complete control over the wish
        WishType wishType; // enum: Question, Referral
        bool restricted; // true: all answers not visible
        WishTokenValue price;
        TokenValue quote;
        WishState state; // active, closed, finished
        mapping(OfferType => OfferRatio) offerRatios; // key to related to Offer::type, value for DistributionRule
        uint64 start; // wish excatly start time
        uint64 deadline; // The Unix timestamp before which all submissions must be made, and after which refunds may be processed
        uint64 timestamp; // wish start time i.e. the chain transaction occur timestamp
        uint64 modifyTime;
        uint64 finishTime; // wish finished time, for both close and finish states
        Offer[] offers; // apply Nonce -> Offer
        mapping(uint256 => Unlock) unlocks; // unlocker profile -> Unlock
    }

    /**
     * Offer content
     */
    struct Offer {
        uint256 talent;
        uint256 linker;
        uint256 applyNonce;
        uint64 applyTime;
        uint64 timestamp;
    }

    struct Unlock {
        address token;
        uint tokenVersion;
        uint256 value;
        uint64 timestamp;
    }

    struct Vault {
        uint tokenVersion;
        uint256 claimable;
        uint256 claimed;
        uint64 timestamp;
    }

    /**
     * The wish offer rule configuration
     */
    struct OfferRatio {
        uint256 talent; // talent income
        uint256 linker; // linker income
        uint256 platform; //zeek income
    }

    struct UnlockRatio {
        uint issuer;
        uint owner;
        uint talent;
        uint platform;
    }

    struct BidRatio {
        uint step;
        uint owner;
        uint talent;
        uint platform;
    }

    /*///////////////////////////////////////////////////////////////
                        Common Type
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev A struct containing the necessary information to reconstruct an EIP-712 typed data signature.
     *
     * @param signature Signature
     * @param deadline The signature's deadline
     */
    struct EIP712Signature {
        bytes signature;
        uint64 deadline;
    }

    /*///////////////////////////////////////////////////////////////
                        Call Params
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev A struct containing the parameters required for the `createProfile()` function.
     *
     * @param linkCode The linkCode to set for the profile, must be unique and non-empty.
     */
    struct ProfileData {
        address prover;
        address to;
        string linkCode;
    }

    /**
     * Issue Wish Data
     */
    struct WishIssueData {
        WishType wishType;
        bool restricted;
        // staking 
        TokenValue bonus;
        uint64 start;
        uint64 deadline;
        uint256 salt;
    }

    /**
     * Unlock Wish Data
     */
    struct WishUnlockData {
        uint256 wishId;
        address token;
        uint tokenVersion;
        uint256 value;
        uint64 timestamp;
    }

    struct EstimateFee {
        ZeekDataTypes.OfferRatio offerRatio; // commission rate for direct offer
        ZeekDataTypes.OfferRatio linkOfferRatio; // commission rate for link offer
    }

    struct TokenValue {
        address token;
        uint tokenVersion;
        uint256 value;
    }

    struct WishTokenValue {
        address token;
        uint tokenVersion;
        uint256 value;
        uint256 bidValue;
        uint256 balance;
    }

    struct TokenValueSet {
        address token;
        uint tokenVersion;
        uint256 value;
        bool invalid;
    }

    struct CommissionConfigData {
        OfferType[] types;
        OfferRatio[] ratios;
    }

    /**
     * Modify Wish Data
     */
    struct WishModifyData {
        uint256 wishId;
        uint256 increaseBonus;
        uint64 deadline;
    }

    /**
     * Accept Wish Apply Data
     */
    struct WishAcceptApplyData {
        uint256 wishId;
        address linker;
        address talent;
        uint64 applyTime;
        uint256 applyNonce;
    }

    /**
     * Apply Wish Data for offer purpose
     */
    struct WishApplyData {
        uint256 wishId;
        address talent;
        address linker;
        uint64 applyTime;
        uint256 applyNonce;
    }

    /**
     * Link Wish Data
     */
    struct WishLinkData {
        uint256 wishId;
    }

    /**
     * Revoke Wish Data
     */
    struct WishRefundData {
        uint256 wishId;
    }

    /**
     * Accept Wish Apply Data
     */
    struct WishBidData {
        uint256 wishId;
    }

    /**
     * Accept Wish Apply Data
     */
    struct WishAskData {
        uint256 wishId;
    }

    /**
     * Accept Wish Apply Data
     */
    struct WishCutData {
        uint256 wishId;
        uint256 quote;
    }

}
