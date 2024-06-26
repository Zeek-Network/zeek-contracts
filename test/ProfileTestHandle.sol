// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../contracts/interfaces/IZeekHub.sol";
import "../contracts/core/Wish.sol";
import "../contracts/core/Governance.sol";
import "../contracts/core/Profile.sol";
import "../contracts/upgradeability/IRouter.sol";


contract ProfileTestHandle is Profile{

    constructor(address governance) Profile(governance){
    }

    function getProfileCounter(
    ) external view returns (uint256) {
        return _getProfileStorage()._profileCounter;
    }

//    function getProfileById(uint256 profileId)
//    external view returns (ZeekDataTypes.ProfileStruct memory) {
//        return _getProfileStorage()._profileById[profileId];
//    }

    function getProfileOwnerById(uint256 profileId)
    external view returns (address) {
        return _getProfileStorage()._profileById[profileId].owner;
    }

    function getProfileLinkCodeById(uint256 profileId)
    external view returns (string memory) {
        return _getProfileStorage()._profileById[profileId].linkCode;
    }

    function getProfileTimestampById(uint256 profileId)
    external view returns (uint256) {
        return _getProfileStorage()._profileById[profileId].timestamp;
    }


    function getProfileTokenByIndex(uint256 index)
    external view returns (uint256) {
        return _getProfileStorage()._allTokensIndex[index];
    }

    function getProfileAllTokens()
    external view returns (uint256[] memory) {
        return _getProfileStorage()._allTokens;
    }

    function getProfileIdByAddress(address owner)
    external view returns (uint256) {
        return _getProfileStorage()._profileIdByAddress[owner];
    }

    function getProfileIdByLinkCodeHash(bytes32 hash)
    external view returns (uint256) {
        return _getProfileStorage()._profileIdByLinkCodeHash[hash];
    }

    function setProfileCounter( uint newCounter
    ) external {

        _getProfileStorage()._profileCounter = newCounter;
    }

    function deleteProfileByAddress( address owner
    ) external {
        uint profileId = _getProfileStorage()._profileIdByAddress[owner];
        delete _getProfileStorage()._profileById[profileId];
        delete _getProfileStorage()._profileIdByAddress[owner];
    }

    function getProfileVaults(uint256 profileId, address token)
    external view returns (ZeekDataTypes.Vault memory vault){
        return _getProfileStorage()._vaults[profileId][token];
    }

    function getProfileVaultTokens(uint256 profileId)
    external view returns (address[] memory addresses) {
        return _getProfileStorage()._vaultTokens[profileId];
    }

}
