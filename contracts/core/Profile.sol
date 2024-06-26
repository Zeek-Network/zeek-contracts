// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../interfaces/IProfile.sol";
import "../base/ZeekBase.sol";
import "../libraries/ZeekDataTypes.sol";
import "../libraries/ZeekErrors.sol";
import "../libraries/Constants.sol";
import "../interfaces/IGovernance.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

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
