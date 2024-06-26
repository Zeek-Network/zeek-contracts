// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockERC20 is ERC20 ('Currency', 'ZEEK') {

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}