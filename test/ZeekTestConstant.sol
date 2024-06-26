// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract ZeekTestConstant {

    address public constant ETH_ADDRESS = address(0);

    uint public constant ETH_VERSION = 0;
    uint public constant ERC20_VERSION = 20;

    uint256 public constant INIT_BALANCE = 10e18; // 10 ETH

    bytes32 public constant EIP712_REVISION_HASH = keccak256('1');

    uint256 public constant NO_DEADLINE_256 = type(uint256).max;

    uint64 public constant NO_DEADLINE_64 = type(uint64).max;

    string contractName= 'ZEEK_NAME';
    string contractSymbol= 'ZEEK_SYMBOL';



}
