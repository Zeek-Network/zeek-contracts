// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

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