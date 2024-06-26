// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.21;

// contracts/libraries/Constants.sol

/**
 * @title Constants
 * @author OpenSocial Protocol
 * @notice This library defines constants for the OpenSocial Protocol.
 */
library Constants {

    bytes32 public constant GOVERANCE_ROLE = keccak256("GOVERANCE_ROLE");
    bytes32 public constant OPERATION_ROLE = keccak256("OPERATION_ROLE");
    bytes32 public constant ZEEK_ROLE = keccak256("ZEEK_ROLE");

    uint32 internal constant DAYS_30_IN_SECONDS = 2592000;
}

// contracts/libraries/ZeekDataTypes.sol

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

// contracts/libraries/ZeekErrors.sol

library ZeekErrors {

    // Common Errors
    error NotGovernance();
    error NotOwnerOrApproved();
    error NotHasProfile();
    error InvalidAddress();
    error InvalidProver();
    error InvalidParameters();
    error InitParamsInvalid();
    error TokenDoesNotExist();
    error AppNotWhitelisted();
    error IncorrectMsgValue();
    error IncorrectTokenValue();
    error UnsupportedOperation();
    error TransferFailed();
    
    //EIP712 Errors
    error SignatureExpired();
    error SignatureInvalid();

    // Zeek Errors
    error NotZeek();

    // Profile Errors
    error ProfileInvalidParameter();
    error ProfileIdTaken();
    error ProfileAlreadyExists();
    error LinkCodeAlreadyExists();

    // Wish Errors
    error NotWishOwner();
    error NotWishLinker();
    error NotWishCandidate();
    error InsufficientBalance();
    error InvalidWishState();
    error InvalidWishAmount();
    error InvalidWishRatio();
    error WishInsufficientBalance();
    error WishUnsupportedToken();
    error WishSaltProcessed();
    error WishInvalidParameter();
    error InvalidLinkCode();
    error WishNotExist();
    error WishAlreadyLinked();
    error WishExistCandidate();
    error InvalidWishLinker();
    error WishUnsupportedType();
    error WishExpired();
    error WishInsufficientBonus();
    error WishAlreadyUnlocked();

    // Router
    error InvalidRouter();
    error InvalidRouterAdmin();
    error RouterUnknownForSelector();
    error RouterSelectorSigMismatch();
    error RouterFunctionAlreadyExists();

}

// lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC1271.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC5267.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// contracts/interfaces/IProfile.sol

/**
 * @title IProfile
 * @author zeeker
 *
 * @dev This is the interface for the Profile contract, which is based on user address to create profile.
 */
interface IProfile {

    /**
     * return the profileId
     */
    function createProfile(uint256 salt) external returns (uint256);

    /**
     * Prevent contract call duplicate case
     * @param singer singer address
     */
    function nonces(address singer) external view returns (uint256);

    /**
     * Returns the profile struct of the given profile ID.
     * @param profileId The profile ID to query.
     */
    function getProfile(uint256 profileId) external view returns (address owner, string memory linkCode, uint256 timestamp);
        
    /**
     * Returns the profile struct of the given addr.
     * @param owner address
     */
    function getProfileByAddress(address owner) external view returns (uint256 profileId, string memory linkCode, uint256 timestamp);

    /**
     * claim all personal vaults
     * @param token which one would you claim
     */
    function claim(address token) external;

    /**
     * vault
     * 
     * @param token token address
     * @return claimable claimable value
     * @return claimed claimed value
     */
    function vault(address owner, address token) external view returns (uint256 claimable, uint256 claimed, uint64 timestamp);

}

// contracts/interfaces/IWish.sol

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

// contracts/libraries/ZeekEvents.sol

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

// lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// contracts/libraries/ZeekStorage.sol

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

// lib/openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/SignatureChecker.sol)

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Safe Wallet (previously Gnosis Safe).
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}

// contracts/interfaces/IGovernance.sol

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

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// contracts/base/EIP712Base.sol

/**
 * @title EIP712Base
 * @author zeeker
 * @dev This contract is EIP712 implementation.
 * See https://eips.ethereum.org/EIPS/eip-712
 */
abstract contract EIP712Base {
    using SignatureChecker for address;
    bytes32 internal constant EIP712_REVISION_HASH = keccak256('1');

    /**
     * @dev Wrapper for ecrecover to reduce code size, used in meta-tx specific functions.
     */
    function _validateRecoveredAddress(
        bytes32 digest,
        address signer,
        ZeekDataTypes.EIP712Signature calldata sig
    ) internal view {
        if (sig.deadline < block.timestamp) revert ZeekErrors.SignatureExpired();
        if (!signer.isValidSignatureNow(digest, sig.signature)) {
            revert ZeekErrors.SignatureInvalid();
        }
    }

    /**
     * @dev Calculates EIP712 DOMAIN_SEPARATOR based on the current contract and chain ID.
     */
    function _calculateDomainSeparator() internal view virtual returns (bytes32);

    /**
     * @dev Calculates EIP712 digest based on the current DOMAIN_SEPARATOR.
     *
     * @param hashedMessage The message hash from which the digest should be calculated.
     *
     * @return bytes32 A 32-byte output representing the EIP712 digest.
     */
    function _calculateDigest(bytes32 hashedMessage) internal view returns (bytes32) {
        bytes32 digest;
        unchecked {
            digest = keccak256(
                abi.encodePacked('\x19\x01', _calculateDomainSeparator(), hashedMessage)
            );
        }
        return digest;
    }
}

// lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControl, ERC165Upgradeable {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @custom:storage-location erc7201:openzeppelin.storage.AccessControl
    struct AccessControlStorage {
        mapping(bytes32 role => RoleData) _roles;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessControl")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessControlStorageLocation = 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800;

    function _getAccessControlStorage() private pure returns (AccessControlStorage storage $) {
        assembly {
            $.slot := AccessControlStorageLocation
        }
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        return $._roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        AccessControlStorage storage $ = _getAccessControlStorage();
        bytes32 previousAdminRole = getRoleAdmin(role);
        $._roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (!hasRole(role, account)) {
            $._roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        AccessControlStorage storage $ = _getAccessControlStorage();
        if (hasRole(role, account)) {
            $._roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// contracts/base/ZeekBase.sol

contract ZeekBase is ZeekStorage, EIP712Base, ContextUpgradeable {

    using SafeERC20 for IERC20;

    /**
     *  @dev This function reverts if the address is not has profile.
     */
    function _validateHasProfile(address addr) internal view returns (uint256) {
        uint256 profileId = _getProfileStorage()._profileIdByAddress[addr];
        if (profileId == 0) revert ZeekErrors.NotHasProfile();
        return profileId;
    }

    function _validateTokenValue(address token, uint tokenVersion) internal pure {
        if (tokenVersion == 0 && token != address(0)) {
            revert ZeekErrors.InvalidAddress();
        }
        if (tokenVersion == 20 && token == address(0)) {
            revert ZeekErrors.InvalidAddress();
        }
    }

    function _baseCustody(
        uint tokenVersion,
        address token,
        uint256 value,
        address from
    ) internal {
        if (tokenVersion == 20) {
            if (msg.value != 0) {
                // Ensures users don't accidentally send ETH alongside a token contribution, locking up funds
            }

            IERC20(token).safeTransferFrom(
                from,
                address(this),
                value
            );
        } else if (tokenVersion != 0) {
            revert ZeekErrors.WishUnsupportedToken();
        }
    }

    function _baseTransfer(
        uint tokenVersion,
        address token,
        uint256 amount,
        address from,
        address payable to
    ) internal {
        if (amount == 0) {
            return;
        }
        if (tokenVersion == 0) {
            (bool success, ) = to.call{value: amount}('');
            if (!success) {
                revert ZeekErrors.TransferFailed();
            }
        } else if (tokenVersion == 20) {
            if (token == address(0)) {
                return;
            }
            if (from == address(this)) {
                IERC20(token).safeTransfer(to, amount);
            } else {
                IERC20(token).safeTransferFrom(payable(from), to, amount);
            }
        } else {
            revert ZeekErrors.WishUnsupportedToken();
        }
    }

    /*///////////////////////////////////////////////////////////////
                          modifier
  //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                      Internal functions
  //////////////////////////////////////////////////////////////*/

    function _calculateDomainSeparator()
        internal
        view
        virtual
        override
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    ZeekDataTypes.EIP712_DOMAIN_TYPEHASH,
                    keccak256(bytes(_getGovernanceStorage()._name)),
                    EIP712_REVISION_HASH,
                    block.chainid,
                    address(this)
                )
            );
    }
}

// contracts/base/WishBase.sol

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

// contracts/core/Wish.sol

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

// contracts/core/Governance.sol

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

// contracts/core/Profile.sol

contract Profile is IProfile, ZeekBase {
    IGovernance private immutable GOVERNANCE;

    constructor(address governance) {
        if (governance == address(0)) revert ZeekErrors.InitParamsInvalid();
        GOVERNANCE = IGovernance(governance);
    }

    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProfile
    function createProfile(uint256 salt) external override returns (uint256) {
        return _createProfile(salt);
    }

    /// @inheritdoc IProfile
    function getProfile(uint256 profileId) external view override returns (address owner, string memory linkCode, uint256 timestamp) {
        ZeekDataTypes.ProfileStruct storage p = _getProfile(profileId);
        return (p.owner, p.linkCode, p.timestamp);
    }

    /// @inheritdoc IProfile
    function getProfileByAddress(address owner) external view override returns 
    (uint256 profileId, string memory linkCode, uint256 timestamp) {
        uint256 pid = _getProfileStorage()._profileIdByAddress[owner];
        ZeekDataTypes.ProfileStruct storage p = _getProfile(pid);
        return (pid, p.linkCode, p.timestamp);
    }

    /// @inheritdoc IProfile
    function vault(address owner, address token) external view override returns (uint256 claimable, uint256 claimed, uint64 timestamp) {
        ZeekDataTypes.Vault storage v = _getProfileStorage()._vaults[_validateHasProfile(owner)][token];
        return (v.claimable, v.claimed, v.timestamp);
    }

    function claim(address token) external override {
        uint256 profile = _validateHasProfile(_msgSender());

        ZeekDataTypes.Vault storage v = _getProfileStorage()._vaults[profile][token];
        if (v.claimable == 0) {
            revert ZeekErrors.InsufficientBalance();
        }
        uint256 value = v.claimable;
        v.claimable = 0;
        v.claimed = v.claimed + value;
        
        v.timestamp = uint64(block.timestamp);

        // transfer
        _baseTransfer(v.tokenVersion, token, value, address(this), payable(_msgSender()));

        emit ZeekEvents.Claimed(
            profile,
            token,
            v.tokenVersion,
            value,
            v.timestamp
        );
    }

    /// @inheritdoc IProfile
    function nonces(address singer) external view override returns (uint256) {
        return _getProfileStorage()._sigNonces[singer];
    }

    /**
     * Create Profile internal function
     */
    function _createProfile(uint256 salt) internal returns (uint256) {
        return _mint(msg.sender, salt);
    }

    function _getProfile(
        uint256 profileId
    ) internal view returns (ZeekDataTypes.ProfileStruct storage) {
        return _getProfileStorage()._profileById[profileId];
    }

    /**
     * Mint Profile
     * @param to owner
     */
    function _mint(address to, uint256 salt) internal returns (uint256) {
        ProfileStorage storage profileStorage = _getProfileStorage();
        if (profileStorage._profileIdByAddress[to] > 0)
            revert ZeekErrors.ProfileAlreadyExists();
        uint256 tokenId = ++profileStorage._profileCounter;
        string memory linkCode = padNumber(tokenId);
        _addTokenToAllTokensEnumeration(tokenId);
        profileStorage._profileById[tokenId].owner = to;
        profileStorage._profileById[tokenId].linkCode = linkCode;
        profileStorage._profileById[tokenId].timestamp = uint64(block.timestamp);
        profileStorage._profileIdByAddress[to] = tokenId;

        bytes32 linkCodeHash = keccak256(bytes(linkCode));
        if (profileStorage._profileIdByLinkCodeHash[linkCodeHash] > 0) {
            revert ZeekErrors.LinkCodeAlreadyExists();
        }
        profileStorage._profileIdByLinkCodeHash[linkCodeHash] = tokenId;

        emit ZeekEvents.ProfileCreated(tokenId, salt, to, linkCode, uint64(block.timestamp));

        return tokenId;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        ProfileStorage storage profileStorage = _getProfileStorage();
        profileStorage._allTokensIndex[tokenId] = profileStorage._allTokens.length;
        profileStorage._allTokens.push(tokenId);
    }

    function padNumber(uint256 number) internal pure returns (string memory) {
        string memory numberString = Strings.toString(number);
        uint256 length = bytes(numberString).length;

        if (length >= 6) {
            return numberString;
        } else {
            return strConcat(strConcatMultiple("0", 6 - length), numberString);
        }
    }

    function strConcat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function strConcatMultiple(string memory a, uint256 times) internal pure returns (string memory) {
        string memory result;
        for (uint256 i; i < times; ) {
            result = strConcat(result, a);
            unchecked {
                ++i;
            }
        }
        return result;
    }
}

// contracts/interfaces/IZeekHub.sol

interface IZeekHub is IGovernance, IProfile, IWish {}
