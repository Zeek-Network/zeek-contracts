// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

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
