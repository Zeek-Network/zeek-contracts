// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../libraries/ZeekErrors.sol";
import "../libraries/ZeekDataTypes.sol";
import "../libraries/ZeekStorage.sol";
import "../libraries/ZeekEvents.sol";
import "../base/EIP712Base.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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
