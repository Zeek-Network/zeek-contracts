// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ZeekTestSetUp.sol";
import "../MetaTxNegatives.sol";
import "../../contracts/libraries/ZeekErrors.sol";
import "../../contracts/libraries/ZeekDataTypes.sol";


contract QuestionTestNewShu is ZeekTestSetUp, MetaTxNegatives {


    modifier setFee() {
        //console2.log("createProfile...");
        vm.startPrank(deployer);
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 100, true);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ERC20_VERSION, 100, true);
        vm.stopPrank();

        mockERC20Token.mint(rock, 10e18);
        mockERC20Token.mint(rose, 10e18);
        mockERC20Token.mint(jack, 10e18);
        mockERC20Token.mint(alice, 10e18);

        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 10e18);
        vm.prank(rose);
        mockERC20Token.approve(address(zeekHub), 10e18);
        vm.prank(jack);
        mockERC20Token.approve(address(zeekHub), 10e18);
        vm.prank(alice);
        mockERC20Token.approve(address(zeekHub), 10e18);
        _;
    }

    function testBidWish_ETH_normal() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 290, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 10, "finance balance error");

        vm.warp(1234);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishTransferred(
            1,
            jackProfileId,
            ZeekDataTypes.WishTransferType.Bid,
            110,
            121,
            1234

        );

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 180, "jack balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 4, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");
    }

    function testBidWish_ETH_normal2() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 290, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 10, "finance balance error");

        vm.warp(1234);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishTransferred(
            1,
            aliceProfileId,
            ZeekDataTypes.WishTransferType.Bid,
            110,
            121,
            1234

        );

        vm.prank(alice);
        vm.deal(alice, 1 ether);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), aliceProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(alice.balance, 1 ether - 110, "alice balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 4, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");
    }

    function testCannotBidWish_ETH_wishRestrictedIsFalse() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, false);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_bidByWishOwner() public createProfile setFee {
        vm.deal(rock, 10000000000);
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );


        vm.warp(1234);

        vm.deal(rock, 50 ether);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_bidTwoTimesByOnePerson() public createProfile setFee {

        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );


        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        vm.deal(rock, 50 ether);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.bidWish{value: 121}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testBidWish_ETH_bidTwoTimesByDiffPerson() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );


        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        vm.warp(2345);

        vm.deal(rock, 50 ether);

        vm.prank(rock);
        // vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.bidWish{value: 121}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_wishStateIsActive() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_msgSenderNotHasProfile() public createProfile setFee {
        vm.deal(user, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(user);
        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_msgValueGtRequire() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        zeekHub.bidWish{value: 111}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_msgValueLtRequire() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        zeekHub.bidWish{value: 109}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }

    function testCannotBidWish_ETH_msgValueIs0() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        zeekHub.bidWish{value: 0}(ZeekDataTypes.WishBidData({wishId: wishId}));
    }


    function testBidWish_ERC20_normal() public createProfile setFee {
        // vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check mock erc20 balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10, "finance balance error");

        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], mockERC20TokenAddress, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90 - 110, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100 + 104, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0 + 4, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10 + 2, "finance balance error");
    }

    function testBidWish_ERC20_normal2() public createProfile setFee {
        // vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check mock erc20 balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10, "finance balance error");

        vm.warp(1234);

        vm.prank(alice);
        zeekHub.bidWish(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), aliceProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], mockERC20TokenAddress, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90, "jack balance error");
        assertEq(mockERC20Token.balanceOf(alice), 10e18 + - 110, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100 + 104, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0 + 4, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10 + 2, "finance balance error");
    }


    function testCutWish_ETH_normal() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishCut(
            1,
            ZeekDataTypes.TokenValue({
                token: ETH_ADDRESS,
                tokenVersion: ETH_VERSION,
                value: 190
            }),
            1234

        );

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");
    }

    function testCannotCutWish_ETH_wishNotExist() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: 2, quote: 190}));
    }

    function testCannotCutWish_ETH_wishRestrictedIsFalse() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, false);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));
    }

    function testCannotCutWish_ETH_masSenderIsNotWishOwner() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));
    }

    function testCannotCutWish_ETH_wishStateIsNotFinish() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        /*ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );*/

        vm.warp(1234);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));
    }

    function testCannotCutWish_ETH_ltMinimum() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 99}));
    }

    function testCannotCutWish_ETH_dataQuotaEqWishPriceValue() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 200}));
    }

    function testCannotCutWish_ETH_wishValueEqMinimum_dataQuotaEqWishPriceValue() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, false);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        vm.warp(1234);

        vm.prank(rock);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 100}));
    }

    function testCutWish_ETH_cutTwoTimes() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 199}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 2345, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 199, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");
    }


    function testCutWish_ERC20_normal() public createProfile setFee {
        // vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check mock erc20 balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 180, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 200, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 20, "finance balance error");

        vm.warp(1234);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishCut(
            1,
            ZeekDataTypes.TokenValue({
                token: mockERC20TokenAddress,
                tokenVersion: ERC20_VERSION,
                value: 190
            }),
            1234

        );

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 4, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 1234, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], mockERC20TokenAddress, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 180, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 200, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 20, "finance balance error");
    }


    function testAskWish_ETH_normal() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishTransferred(
            1,
            jackProfileId,
            ZeekDataTypes.WishTransferType.Ask,
            190,
            209,
            2345

        );

        vm.prank(jack);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 190, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 209, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 2345, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 2345, "profile vault timestamp error ");

//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480 - 190, "jack balance error");
        assertEq(rock.balance, 0 + 190, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");
    }

    function testAskWish_ETH_wishNotExist() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId + 1}));

    }

    function testCannotAskWish_ETH_notCutWish() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

//        vm.warp(1234);
//        vm.prank(rock);
//        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        vm.warp(2345);
        vm.prank(jack);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));
    }

    function testCannotAskWish_ETH_restrictedIsFalse() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, false);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

//        vm.warp(1234);
//        vm.prank(rock);
//        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        vm.warp(2345);
        vm.prank(jack);
        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));
    }

    function testCannotAskWish_ETH_wishStateIsActive() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

//        //==>rock offer wish:1 to jack
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            talent: jack,
//            linker: address(0),
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//
//        vm.prank(rock);
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                jackPrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );

        // check balance
//        assertEq(jack.balance, 480, "jack balance error");
//        assertEq(rock.balance, 0, "rock balance error");
//        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
//        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

//        vm.warp(1234);
//        vm.prank(rock);
//        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        vm.warp(2345);
        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));
    }

    function testCannotAskWish_ETH_msgValueNotEqValueRequired() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        zeekHub.askWish{value: 191}(ZeekDataTypes.WishAskData({wishId: wishId}));

    }

    function tesCannottAskWish_ETH_askerNotHasProfile() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.deal(user, 300);
        vm.prank(user);
        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));

    }

    function testCannotAskWish_ETH_askerIsWishOwner() public createProfile setFee {
        vm.deal(jack, 300);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(1234);

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getWishStructTokenValue(wishId).tokenVersion, ETH_VERSION, "wish token value version error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).token, ETH_ADDRESS, "wish token value token error ");
        assertEq(zeekHub.getWishStructTokenValue(wishId).value, 190, "wish token value value error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 480, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 20, "finance balance error");

        vm.warp(2345);

        vm.deal(rock, 300 ether);
        vm.prank(rock);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        zeekHub.askWish{value: 190}(ZeekDataTypes.WishAskData({wishId: wishId}));

    }


    function testAskWish_ERC20_normal() public createProfile setFee {
        // vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 200, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check mock erc20 balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 180, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 200, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 20, "finance balance error");

        vm.warp(1234);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishCut(
            1,
            ZeekDataTypes.TokenValue({
                token: mockERC20TokenAddress,
                tokenVersion: ERC20_VERSION,
                value: 190
            }),
            1234

        );

        vm.prank(rock);
        zeekHub.cutWish(ZeekDataTypes.WishCutData({wishId: wishId, quote: 190}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 200, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 220, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 4, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 1234, "profile vault timestamp error ");
//
//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], mockERC20TokenAddress, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 180, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 200, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 20, "finance balance error");

        vm.warp(2345);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.WishTransferred(
            1,
            jackProfileId,
            ZeekDataTypes.WishTransferType.Ask,
            190,
            209,
            2345

        );

        vm.prank(jack);
        zeekHub.askWish(ZeekDataTypes.WishAskData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 190, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 209, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 2345, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
//        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 2345, "profile vault timestamp error ");

//        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 180 - 190, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 200 + 190, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 20, "finance balance error");

    }


    function testClaim_ETH_normal() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 290, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 10, "finance balance error");

        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 180, "jack balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 4, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");

        vm.warp(2345);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.Claimed(
            jackProfileId,
            ETH_ADDRESS,
            ETH_VERSION,
            4,
            2345
        );

        vm.prank(jack);
        zeekHub.claim(ETH_ADDRESS);

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 0, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 2345, "profile vault timestamp error ");

        // check balance
        assertEq(jack.balance, 180 + 4, "jack balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");
    }

    function testCannotClaim_ETH_msgSenderNotHasProfile() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 290, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 10, "finance balance error");

        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 180, "jack balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 4, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");

        vm.warp(2345);

        vm.prank(user);
        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        zeekHub.claim(ETH_ADDRESS);

    }

    function testCannotClaim_ETH_claimTwoTimes() public createProfile setFee {
        vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check balance
        assertEq(jack.balance, 290, "jack balance error");
        assertEq(rock.balance, 0, "rock balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 10, "finance balance error");

        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish{value: 110}(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).tokenVersion, ETH_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, ETH_ADDRESS).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], ETH_ADDRESS, "profile vault tokens error ");

        // check balance
        assertEq(jack.balance, 180, "jack balance error");
        assertEq(rock.balance, 104, "rock balance error");
        assertEq(address(zeekHub).balance, 4, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 12, "finance balance error");

        vm.warp(2345);
        vm.prank(jack);
        zeekHub.claim(ETH_ADDRESS);

        vm.warp(3456);
        vm.prank(jack);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        zeekHub.claim(ETH_ADDRESS);

    }


    function testClaim_ERC20_normal() public createProfile setFee {
        // vm.deal(jack, 200);

        //OfferRatio(90, 0, 10);
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 100, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        // check mock erc20 balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10, "finance balance error");

        vm.warp(1234);

        vm.prank(jack);
        zeekHub.bidWish(ZeekDataTypes.WishBidData({wishId: wishId}));

        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 110, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 121, "wish price bidValue error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");
        assertEq(zeekHub.getWishStructLastModifyTime(wishId), 1234, "wish price modifyTime error ");
        assertEq(zeekHub.getWishStructOwner(wishId), jackProfileId, "wish price owner error ");
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish price issuer error ");

        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 4, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 1234, "profile vault timestamp error ");

        assertEq(zeekHub.getProfileVaultTokens(jackProfileId)[0], mockERC20TokenAddress, "profile vault tokens error ");

        // check balance
        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90 - 110, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100 + 104, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0 + 4, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10 + 2, "finance balance error");

        vm.warp(2345);

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.Claimed(
            jackProfileId,
            mockERC20TokenAddress,
            ERC20_VERSION,
            4,
            2345
        );

        vm.prank(jack);
        zeekHub.claim(mockERC20TokenAddress);

        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "profile vault tokenVersion error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).claimable, 0, "profile vault claimable error ");
        assertEq(zeekHub.getProfileVaults(jackProfileId, mockERC20TokenAddress).timestamp, 2345, "profile vault timestamp error ");

        assertEq(mockERC20Token.balanceOf(jack), 10e18 + 90 - 110 + 4, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rock), 10e18 - 100 + 104, "rock balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)), 0, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()), 0 + 10 + 2, "finance balance error");
    }

    function testSetBidRation_normal() public createProfile setFee {

        vm.expectEmit(true, true, false, true);
        emit ZeekEvents.ZeekWishBidRatioSet(
            10,
            4,
            4,
            2
        );

        // emit ZeekEvents.ZeekWishBidRatioSet(step, owner, talent, platform);
        vm.prank(deployer);
        zeekHub.setBidRatio(10, 4, 4, 2);
    }


    function testCannotSetBidRation_msgSenderNotHasRole() public createProfile setFee {
        vm.prank(user);
        vm.expectRevert();
        zeekHub.setBidRatio(10, 4, 4, 2);
    }

    function testCannotSetBidRation_givenNotEqRequired() public createProfile setFee {
        vm.prank(deployer);
        vm.expectRevert(ZeekErrors.InvalidParameters.selector);
        zeekHub.setBidRatio(10, 4, 4, 3);
    }


    function _issueWishWithNative(address issuer, ZeekDataTypes.WishType wishType, uint256 bonusValue, bool restricted) internal {
        vm.deal(issuer, bonusValue);

        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: restricted,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.prank(rock);
        wishId = zeekHub.issueWish{value: bonusValue}(data);
    }

    function _issueWishWithERC20(address issuer, ZeekDataTypes.WishType wishType, uint256 bonusValue, bool restricted) internal {
        vm.deal(issuer, bonusValue);

        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: restricted,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.prank(rock);
        wishId = zeekHub.issueWish(data);
    }
//
}
