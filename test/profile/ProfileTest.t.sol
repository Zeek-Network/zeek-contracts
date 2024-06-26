// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ZeekTestSetUp.sol";
import "../MetaTxNegatives.sol";
import "../../contracts/libraries/ZeekErrors.sol";
import "../../contracts/libraries/ZeekEvents.sol";
import "../../contracts/libraries/ZeekDataTypes.sol";

contract ProfileTest is ZeekTestSetUp, MetaTxNegatives {

    modifier offerWishWith(
        uint _wishId,
        address linker,
        address talent
    ) {
        vm.startPrank(rock);

        uint256 privateKey;

        if (rock == talent) {
            privateKey = rockPrivateKey;
        } else if (rose == talent) {
            privateKey = rosePrivateKey;
        } else if (bob == talent) {
            privateKey = bobPrivateKey;
        } else if (jack == talent) {
            privateKey = jackPrivateKey;
        }

        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: _wishId,
            talent: talent,
            linker: linker,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        ZeekDataTypes.EIP712Signature memory sig = _getSigStruct(
//            rosePrivateKey,
            privateKey,
            _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
            NO_DEADLINE_64
        );

        zeekHub.offerWish(
            wishApplyData,
            sig

        );
        vm.stopPrank();
        _;
    }

    function testCreateProfile_normal() public forRock {
        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.ProfileCreated(
            1,
            0,
            rock,
            '000001',
            uint64(block.timestamp)
        );

        uint256 resultId = zeekHub.createProfile(0);

        bytes32 linkCodeHash = keccak256(bytes("000001"));

        assertEq(resultId, 1);

        assertEq(zeekHub.getProfileOwnerById(1), rock, "profile owner error");
        assertEq(zeekHub.getProfileLinkCodeById(1), "000001", "profile linkCode error");
        assertEq(zeekHub.getProfileTimestampById(1), uint64(block.timestamp), "profile timestamp error");

        assertEq(zeekHub.getProfileCounter(), 1, "profile counter error");
        assertEq(zeekHub.getProfileAllTokens().length, 1, "profile allToken length error");
        assertEq(zeekHub.getProfileTokenByIndex(1), 0, "profile index token error");
        assertEq(zeekHub.getProfileIdByAddress(rock), 1, "profile address profileId error");
        assertEq(zeekHub.getProfileIdByLinkCodeHash(linkCodeHash), 1, "profile codeHash error");

    }

    function testCannotCreateProfile_ManyTimes() public forRock {
        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.ProfileCreated(
            1,
            0,
            rock,
            '000001',
            uint64(block.timestamp)
        );

        uint256 result = zeekHub.createProfile(0);
        uint256 profileCounter = zeekHub.getProfileCounter();
        uint256[] memory allTokens = zeekHub.getProfileAllTokens();
        uint256 token = zeekHub.getProfileTokenByIndex(1);
        uint256 profileId = zeekHub.getProfileIdByAddress(rock);
        // ZeekDataTypes.ProfileStruct memory profile = zeekHub.getProfileById(1);

        bytes32 linkCodeHash = keccak256(bytes("000001"));
        uint256 profileIdByHash = zeekHub.getProfileIdByLinkCodeHash(linkCodeHash);


        assertEq(result, 1);
        assertEq(profileCounter, 1);


        assertEq(zeekHub.getProfileOwnerById(1), rock, "profile owner error");
        assertEq(zeekHub.getProfileLinkCodeById(1), "000001", "profile linkCode error");
        assertEq(zeekHub.getProfileTimestampById(1), uint64(block.timestamp), "profile timestamp error");

        assertEq(allTokens.length, 1);
        assertEq(token, 0);
        assertEq(profileId, 1);
        assertEq(profileIdByHash, 1);

        vm.expectRevert(ZeekErrors.ProfileAlreadyExists.selector);
        zeekHub.createProfile(0);
    }

    function testCreateProfile_LinkCodeGte6() public forRock {
        zeekHub.setProfileCounter(999999);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.ProfileCreated(
            1000000,
            0,
            rock,
            '1000000',
            uint64(block.timestamp)
        );

        uint256 result = zeekHub.createProfile(0);
        uint256 profileCounter = zeekHub.getProfileCounter();
        console2.log("[test]profileCounter", profileCounter);
        uint256[] memory allTokens = zeekHub.getProfileAllTokens();
        uint256 token = zeekHub.getProfileTokenByIndex(1000000);
        uint256 profileId = zeekHub.getProfileIdByAddress(rock);
        // ZeekDataTypes.ProfileStruct memory profile = zeekHub.getProfileById(1000000);

        bytes32 linkCodeHash = keccak256(bytes("1000000"));
        uint256 profileIdByHash = zeekHub.getProfileIdByLinkCodeHash(linkCodeHash);


        assertEq(result, 1000000, "result error");
        assertEq(profileCounter, 1000000, "profileCounter error");

        assertEq(zeekHub.getProfileOwnerById(1000000), rock, "profile owner error");
        assertEq(zeekHub.getProfileLinkCodeById(1000000), "1000000", "profile linkCode error");
        assertEq(zeekHub.getProfileTimestampById(1000000), uint64(block.timestamp), "profile timestamp error");

        assertEq(allTokens.length, 1, "length error");
        assertEq(token, 0, "token error");
        assertEq(profileId, 1000000, "profileId error");
        assertEq(profileIdByHash, 1000000, "profileIdByHash error");

    }

    function testClaim_validateHasProfile_msgSenderNotHasProfile() public createProfile {
        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        vm.prank(user);
        zeekHub.claim(ETH_ADDRESS);
    }

    function testClaim_vaultClaimableEqZero() public createProfile {
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(jack);
        zeekHub.claim(ETH_ADDRESS);
    }

    function testClaim_native() public createProfile {
        vm.deal(rose, 0.001 ether);

        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);
        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Active, true, "wish state error ");

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //EarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
        //EarlyUnlockRatio(10, 40, 50);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishUnlocked(wishId, roseProfileId, uint64(block.timestamp));
        vm.prank(rose);
        //rose unlock wish:1
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);

        //assert wish unlock
        ZeekDataTypes.Unlock memory unlock = zeekHub.getWishUnlock(wishId, roseProfileId);
        assertEq(unlock.token, ETH_ADDRESS, "unlock token error");
        assertEq(unlock.tokenVersion, ETH_VERSION, "unlock tokenVersion error");
        assertEq(unlock.value, unlockValue, "unlock value error");
        assertEq(unlock.timestamp, uint64(block.timestamp), "unlock timestamp error");

        //assert balance
        assertEq(rose.balance, 0, "rose balance error");
        assertEq(address(zeekHub).balance, 0.0105 ether, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.0005 ether, "finance balance error");

        //assert vault
        //rock is wish:1 issuer and owner
        (uint256 rockVault_claimable,uint256 rockVault_claimed,uint64 rockVault_timestamp) = zeekHub.vault(rock, ETH_ADDRESS);
        assertEq(rockVault_claimable, 0.0005 ether, "vault claimable error");
        assertEq(rockVault_claimed, 0, "vault claimable error");
        assertEq(rockVault_timestamp, uint64(block.timestamp), "issuer vault claimable error");

        //claim vault
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.Claimed(rockProfileId, ETH_ADDRESS, ETH_VERSION, 0.0005 ether, uint64(block.timestamp));
        vm.prank(rock);
        zeekHub.claim(ETH_ADDRESS);
        (uint256 rockVault_claimable_afterClaim,uint256 rockVault_claimed_afterClaim,uint64 rockVault_timestamp_afterClaim) = zeekHub.vault(rock, ETH_ADDRESS);
        assertEq(rockVault_claimable_afterClaim, 0, "afterClaim vault claimable error");
        assertEq(rockVault_claimed_afterClaim, 0.0005 ether, "afterClaim vault claimable error");
        assertEq(rockVault_timestamp_afterClaim, uint64(block.timestamp), "afterClaim vault claimable error");

        assertEq(rock.balance, 0.0005 ether, "rose balance error");
        assertEq(address(zeekHub).balance, 0.01 ether, "zeekHub balance error");

        //repeat claim
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(rock);
        zeekHub.claim(ETH_ADDRESS);

    }

    function testClaim_erc20() public createProfile {
        mockERC20Token.mint(rose, 1 * 10 ** 5);
        vm.prank(rose);
        mockERC20Token.approve(address(zeekHub), 1 * 10 ** 5);

        uint256 _wishId = _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);
        _offerWish_talentIsJack(_wishId, address(0));

        assertEq(zeekHub.getWishStructState(_wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");

        uint256 unlockValue = 1 * 10 ** 5;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: _wishId,
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //UnlockTokens(mockERC20TokenAddress, ERC20_VERSION, 1 * 10 ** 5, true);
        //UnlockRatio(10, 40, 40, 10);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishUnlocked(_wishId, roseProfileId, uint64(block.timestamp));
        vm.prank(rose);
        //rose unlock wish:1
        zeekHub.unlockWish(wishUnlockData);

        //assert wish unlock
        ZeekDataTypes.Unlock memory unlock = zeekHub.getWishUnlock(wishId, roseProfileId);
        assertEq(unlock.token, mockERC20TokenAddress, "unlock token error");
        assertEq(unlock.tokenVersion, ERC20_VERSION, "unlock tokenVersion error");
        assertEq(unlock.value, unlockValue, "unlock value error");
        assertEq(unlock.timestamp, uint64(block.timestamp), "unlock timestamp error");

        //assert balance
        //native
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(jack.balance, 0.009 ether, "jack balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.001 ether, "finance balance error");
        //erc20
        assertEq(mockERC20Token.balanceOf(rose) == 0, true, "rose balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 9 * 10 ** 4, true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == 1 * 10 ** 4, true, "finance balance error");

        //assert vault
        //rock is wish:1 issuer and owner
        (uint256 rockVault_claimable,uint256 rockVault_claimed,uint64 rockVault_timestamp) = zeekHub.vault(rock, mockERC20TokenAddress);
        assertEq(rockVault_claimable, 5 * 10 ** 4, "rock vault claimable error");
        assertEq(rockVault_claimed, 0, "rock vault claimable error");
        assertEq(rockVault_timestamp, uint64(block.timestamp), "rock vault claimable error");

        //jack is wish:1 talent
        (uint256 jackVault_claimable,uint256 jackVault_claimed,uint64 jackVault_timestamp) = zeekHub.vault(jack, mockERC20TokenAddress);
        assertEq(jackVault_claimable, 4 * 10 ** 4, "jack vault claimable error");
        assertEq(jackVault_claimed, 0, "jack vault claimable error");
        assertEq(jackVault_timestamp, uint64(block.timestamp), "jack vault claimable error");

        //claim vault
        //rock claim
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.Claimed(rockProfileId, mockERC20TokenAddress, ERC20_VERSION, 5 * 10 ** 4, uint64(block.timestamp));
        vm.prank(rock);
        zeekHub.claim(mockERC20TokenAddress);
        (uint256 rockVault_claimable_afterClaim,uint256 rockVault_claimed_afterClaim,uint64 rockVault_timestamp_afterClaim) = zeekHub.vault(rock, mockERC20TokenAddress);
        assertEq(rockVault_claimable_afterClaim, 0, "afterClaim vault claimable error");
        assertEq(rockVault_claimed_afterClaim, 5 * 10 ** 4, "afterClaim vault claimable error");
        assertEq(rockVault_timestamp_afterClaim, uint64(block.timestamp), "afterClaim vault claimable error");

        //jack claim
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.Claimed(jackProfileId, mockERC20TokenAddress, ERC20_VERSION, 4 * 10 ** 4, uint64(block.timestamp));
        vm.prank(jack);
        zeekHub.claim(mockERC20TokenAddress);
        (uint256 jackVault_claimable_afterClaim,uint256 jackVault_claimed_afterClaim,uint64 jackVault_timestamp_afterClaim) = zeekHub.vault(jack, mockERC20TokenAddress);
        assertEq(jackVault_claimable_afterClaim, 0, "afterClaim vault claimable error");
        assertEq(jackVault_claimed_afterClaim, 4 * 10 ** 4, "afterClaim vault claimable error");
        assertEq(jackVault_timestamp_afterClaim, uint64(block.timestamp), "afterClaim vault claimable error");

        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
    }

    function _issueWishWithNative(address issuer, ZeekDataTypes.WishType wishType, uint256 bonusValue, bool restricted) internal returns (uint256){
        vm.deal(issuer, bonusValue);

        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: wishType,
            restricted: restricted,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: block.timestamp
        });

        vm.prank(issuer);
        return wishId = zeekHub.issueWish{value: bonusValue}(data);
    }

    function _offerWish_talentIsJack(uint256 _wishId, address _linker) internal {

        vm.deal(jack, 0);

        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: _wishId,
            talent: jack,//default talent
            linker: _linker,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        address wishOwner = zeekHub.getProfileOwnerById(zeekHub.getWishStructOwner(_wishId));
        vm.prank(wishOwner);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

}