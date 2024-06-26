// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../contracts/interfaces/IZeekHub.sol";
import "../contracts/core/Wish.sol";
import "../contracts/core/Governance.sol";
import "../contracts/core/Profile.sol";
import "../contracts/upgradeability/IRouter.sol";


contract GovernanceTestHandle is Governance{

    function getGovernanceStorageName(
    ) external view returns (string memory){
        return _getGovernanceStorage()._name;
    }

    function getGovernanceStorageSymbol(
    ) external view returns (string memory ){
        return _getGovernanceStorage()._symbol;
    }

    function getGovernanceStorageFinance(
    ) external view returns (address ){
        return _getGovernanceStorage()._finance;
    }

    function grantRoleForTest(bytes32 role,  address _address
    ) external returns (bool){
        return _grantRole(role,_address );
    }

    function getWishStorageEarlyUnlockToken(address token
    ) external view returns (ZeekDataTypes.TokenValueSet memory){
        return _getWishStorage()._earlyUnlockTokens[token];
    }

    function getWishStorageUnlockToken(address token
    ) external view returns (ZeekDataTypes.TokenValueSet memory){
        return _getWishStorage()._unlockTokens[token];
    }

    function getWishStorageEarlyUnlockRatio(
    ) external view returns (ZeekDataTypes.UnlockRatio memory){
        return _getWishStorage()._earlyUnlockRatio;
    }


    function getWishStorageUnlockRatio(
    ) external view returns (ZeekDataTypes.UnlockRatio memory){
        return _getWishStorage()._unlockRatio;
    }

    function getMinimumIssueTokens(address token
    )external view returns (ZeekDataTypes.TokenValueSet memory){
        return _getWishStorage()._minIssueTokens[token];
    }

}