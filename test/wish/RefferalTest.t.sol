//
//// SPDX-License-Identifier: MIT
//pragma solidity 0.8.20;
//
//import "../ZeekTestSetUp.sol";
//import "../MetaTxNegatives.sol";
//import "../../contracts/libraries/ZeekErrors.sol";
//import "../../contracts/libraries/ZeekDataTypes.sol";
//
//contract ReferralTest is ZeekTestSetUp, MetaTxNegatives {
//
//    modifier offerReferralWith(uint _wishId, address linker, address talent) {
//        vm.startPrank(rock);
//
//        uint256 privateKey;
//
//        if (rock == talent) {
//            privateKey = rockPrivateKey;
//        } else if (rose == talent) {
//            privateKey = rosePrivateKey;
//        } else if (bob == talent) {
//            privateKey = bobPrivateKey;
//        } else if (jack == talent) {
//            privateKey = jackPrivateKey;
//        } else if (alice == talent) {
//            privateKey = alicePrivateKey;
//        }
//
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: _wishId,
//            linker: linker,
//            talent: talent,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                privateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//
//        );
//        vm.stopPrank();
//        _;
//    }
//
//    function testIssueReferralToken0FeeToken0_30day() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "wishId error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken0FeeToken0_issueTwoWish() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "wishId error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        issueFee = zeekHub
//            .estimateFeeUseForTest(
//            uint64(block.timestamp),
//            uint64(block.timestamp + TWO_MONTH),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//
//        bonusFee = 2e17;
//        data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 60 /*30 day*/),
//            salt: 2
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            2,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 2, true, "wishId error");
//    }
//
//    function testIssueReferralToken0FeeToken0_1day() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 1 /*1 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 1 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "wishId error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance, INIT_BALANCE - bonusFee - issueFee.value, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 1 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken0FeeToken0_29day() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 29 /*29 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 29 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "wishId error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 29 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken0FeeToken0_31day() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 31 /*31 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 31 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "wishId error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == uint64(block.timestamp) + 3600 * 24 * 31 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken20FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: mockERC20TokenAddress,
//            tokenVersion: ERC20_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: mockERC20TokenAddress,
//                tokenVersion: ERC20_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: issueFee.value}(data);
//
//        assertEq(wishId == 1, true, "wishId error");
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == 10e18 - bonusFee, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == bonusFee, true, "zeekHub token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken0FeeToken20() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: ETH_ADDRESS,
//                tokenVersion: ETH_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: mockERC20TokenAddress,
//                tokenVersion: ERC20_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee}(data);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == bonusFee, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - issueFee.value, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ERC20_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == mockERC20TokenAddress, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testIssueReferralToken20FeeToken20() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: mockERC20TokenAddress,
//            tokenVersion: ERC20_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishIssued(
//            1,
//            rockProfileId,
//            data.wishType,
//            ZeekDataTypes.TokenValue({
//                token: mockERC20TokenAddress,
//                tokenVersion: ERC20_VERSION,
//                value: bonusFee
//            }),
//            ZeekDataTypes.TokenValue({
//                token: mockERC20TokenAddress,
//                tokenVersion: ERC20_VERSION,
//                value: issueFee.value
//            }),
//            quoraFee,
//            ZeekDataTypes.CommissionRate(0, 0, 100),
//            ZeekDataTypes.CommissionRate(0, 90, 10),
//            data.start,
//            data.deadline,
//            data.salt
//        );
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: 0}(data);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == bonusFee, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - issueFee.value - bonusFee, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == bonusFee, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Active, true, "wish state error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).linker == rates[0].linker, true, "wish direct linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Direct).platform == rates[0].platform, true, "wish direct platform rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).linker == rates[1].linker, true, "wish link linker rate error ");
//        assertEq(zeekHub.getWishStructCommissionRate(1, ZeekDataTypes.CommissionType.Link).platform == rates[1].platform, true, "wish link platform rate error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ERC20_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == mockERC20TokenAddress, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_msgValueLtIssueFeeAddWishFee() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value - 5e16}(data);
//
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_tokenVersionIs1() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: 1,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishUnsupportedToken.selector);
////        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        wishId = zeekHub.issueWish{value: issueFee.value}(data);
//
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_msgSenderNoProfile() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: 0,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(user);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testFailIssueReferralToken0FeeToken0_msgValueIs0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: 0,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: 0}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_bountyFeeIs0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        // uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: 0,
//            value: 0
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishAmount.selector);
//        wishId = zeekHub.issueWish{value: issueFee.value}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0FeeToken0_msgValueGtWishFeeAddIssueFee() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: 0,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value + 1}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_issueFeeIs0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        issueFee.value = 0;
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_withSameSalt() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishSaltProcessed.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_deadlineLeBlockTimestamp() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.warp(1641070800);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_deadlineEqStart() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp + 1),
//            deadline: uint64(block.timestamp + 1 /*30 day*/),
//            salt: 1
//        });
//
//        issueFee.value = 3e16;
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken0_startGtDeadline() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            deadline: uint64(block.timestamp),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueReferralToken20FeeToken0_msgValueGtIssueFee() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: mockERC20TokenAddress,
//            tokenVersion: ERC20_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: issueFee.value + 1}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken20_msgValueGtWishFee() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + 1}(data);
//    }
//
//    function testCannotIssueReferralToken0FeeToken20_msgValueLtWishFee() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee - 1}(data);
//    }
//
//    function testCannotIssueReferralToken20FeeToken20_msgValueGt0() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: mockERC20TokenAddress,
//            tokenVersion: ERC20_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: 1}(data);
//    }
//
//    function testCannotIssueReferral_initializeToken0FeeToken0_issueToken20FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: mockERC20TokenAddress,
//            tokenVersion: ERC20_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(block.timestamp),
//            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: 1}(data);
//    }
//
//
//    function testModifyReferralToken0FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//
//        //console.log("issueFee.value", issueFee.value);
//
//        uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = uint64(block.timestamp + TWO_MONTH);
//        // uint64 newDeadlineU64 = uint64(newDeadline);
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishModified(
//            1, oldBonusFee + increaseBonus, uint64(newDeadline), uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus}(data);
//
//        assertEq(deployer.balance == newIssueFee.value, true, "deployer balance error");
//        //console.log("address(zeekHub).balance", address(zeekHub).balance);
//        assertEq(address(zeekHub).balance == oldBonusFee + increaseBonus, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - oldBonusFee - increaseBonus - newIssueFee.value, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + TWO_MONTH /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp), true, "wish last modify timestamp error ");
//    }
//
//    function testModifyReferralToken20FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//
//        uint256 oldBonusFee = 1e17;
//        uint256 bonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint64 newDeadline = uint64(block.timestamp + TWO_MONTH);
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFeeUseForTest(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishModified(
//            1, oldBonusFee + increaseBonus, newDeadline, uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.modifyWish{value: shouldIncreaseFee}(data);
//
//        console.log("shouldIncreaseFee", shouldIncreaseFee);
//
//        console.log("deployer.balance", deployer.balance);
//        console.log("address(zeekHub).balance", address(zeekHub).balance);
//        console.log("rock.balance", rock.balance);
//
//
//        assertEq(deployer.balance == newIssueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - shouldIncreaseFee - issueFee.value, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == oldBonusFee + increaseBonus, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - oldBonusFee - increaseBonus, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + TWO_MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp), true, "wish last modify timestamp error ");
//    }
//
//    function testModifyReferralToken0FeeToken0_newDeadlineEqualOldDeadline() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint64 newDeadline = uint64(block.timestamp + MONTH);
//        //uint64 newDeadlineU64 = uint64(newDeadline);
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//
//        vm.prank(rock);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus}(data);
//
//        assertEq(deployer.balance == newIssueFee.value, true, "deployer balance error");
//        console.log("address(zeekHub).balance", address(zeekHub).balance);
//        assertEq(address(zeekHub).balance == oldBonusFee + increaseBonus, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - oldBonusFee - increaseBonus - newIssueFee.value, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + MONTH /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp), true, "wish last modify timestamp error ");
//    }
//
//    function testModifyReferralToken0FeeToken0_newDeadlineLtOldDeadline() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        uint256 oldBonusFee = 1e17;
//        uint256 bonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + MONTH - 1;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rock);
//        zeekHub.modifyWish{value: 0 + increaseBonus}(data);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == oldBonusFee + increaseBonus, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - oldBonusFee - increaseBonus - issueFee.value, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + MONTH - 1 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp), true, "wish last modify timestamp error ");
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_newDeadlineLtOldStart() public refferalInitializeFeeTokenETH createProfile estimateFeeWithStartEnd(WEEK, WEEK + MONTH) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory WishIssueData = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Referral,
//            bonus: ZeekDataTypes.TokenValue({
//            token: ETH_ADDRESS,
//            tokenVersion: ETH_VERSION,
//            value: bonusFee
//        }),
//            fee: issueFee,
//            start: uint64(WEEK),
//            deadline: uint64(WEEK + MONTH /*30 day*/),
//            salt: 1
//        });
//        // prepare fee setting
//        ZeekDataTypes.CommissionType[]
//        memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
//        commissionTypes[0] = ZeekDataTypes.CommissionType.Direct;
//        commissionTypes[1] = ZeekDataTypes.CommissionType.Link;
//
//        ZeekDataTypes.CommissionRate[]
//        memory rates = new ZeekDataTypes.CommissionRate[](2);
//        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
//        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(WishIssueData);
//
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = 9999;
//        uint256 wishId = 1;
//
//        //        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//        //        .estimateFee(
//        //            uint64(block.timestamp),
//        //            uint64(newDeadline),
//        //            ZeekDataTypes.WishType.Referral
//        //        )
//        //        .fee;
//        //
//        //        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        console.log("issueFee", issueFee.value);
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        zeekHub.modifyWish{value: 0 + increaseBonus}(data);
//
////        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
////        assertEq(address(zeekHub).balance == oldBonusFee + increaseBonus, true, "zeekHub balance error");
////        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value   , true, "rock balance error");
////
////        assertEq(mockERC20Token.balanceOf(deployer) == 0 , true, "deployer token balance error");
////        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0 , true, "zeekHub token balance error");
////        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
////
////        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
////
////        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp),  true, "wish start error ");
////        assertEq(zeekHub.getWishStructDeadline(1) == 0 /*30 day*/,  true, "wish deadline error ");
////        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp),  true, "wish timestamp error ");
////        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp),  true, "wish last modify timestamp error ");
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_msgSenderNotOwner() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + TWO_MONTH;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//        console.log("shouldIncreaseFee", shouldIncreaseFee);
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rose);
//        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus}(data);
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_wishIdError() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + TWO_MONTH;
//        uint256 wishId = 2;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//        console.log("shouldIncreaseFee", shouldIncreaseFee);
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus}(data);
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_msgValueGtIncreaseWishFeeAddIncreaseIssueFee() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + TWO_MONTH;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//        //console.log("shouldIncreaseFee", shouldIncreaseFee);
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus + 1}(data);
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_msgValueLtIncreaseWishFeeAddIncreaseIssueFee() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + TWO_MONTH;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus - 1}(data);
//    }
//
//    function testCannotModifyReferralToken0FeeToken0_msgSenderNoProfile() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + TWO_MONTH;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFee(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Referral
//        )
//            .fee;
//
//        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
//
//        ZeekDataTypes.WishModifyData memory data = ZeekDataTypes.WishModifyData({
//            wishId: wishId,
//            increaseBonus: increaseBonus,
//            deadline: uint64(newDeadline)
//        });
//
//        zeekHub.deleteProfileByAddress(rock);
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        zeekHub.modifyWish{value: shouldIncreaseFee + increaseBonus}(data);
//    }
//
//
//    function testRefundReferralToken0FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        ////uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, 100
//        );
//
//        vm.prank(rock);
//        vm.warp(100);
//        zeekHub.refundWish(data);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == 1, true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == 1 + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == 1, true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == 0, true, "wish last modify timestamp error ");
//    }
//
//    function testRefundReferralToken0FeeToken20() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken20 {
//        ////uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.refundWish(data);
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testRefundReferralToken20FeeToken20_offerThenRefund() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken20 {
//        uint bonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.refundWish(data);
//
//        console.log("deployer.balance", deployer.balance / 1e16);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 1e16);
//        console.log("rock.balance", rock.balance / 1e16);
//        console.log("rose.balance", rose.balance / 1e16);
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - issueFee.value, true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testRefundReferralToken20FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.refundWish(data);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//    }
//
//    function testRefundReferralToken0FeeToken0_wishBeLinked() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, 100
//        );
//
//        vm.prank(rock);
//        vm.warp(100);
//        zeekHub.refundWish(data);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == 1, true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == 1 + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == 1, true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == 0, true, "wish last modify timestamp error ");
//    }
//
//    function testRefundReferralToken0FeeToken0_wishBeAccepted() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishClosed(
//            wishId, 100
//        );
//
//        vm.prank(rock);
//        vm.warp(100);
//        zeekHub.refundWish(data);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == 1, true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == 1 + MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == 1, true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == 0, true, "wish last modify timestamp error ");
//    }
//
//    function testCannotRefundReferralToken0FeeToken0_msgSenderNoProfile() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        zeekHub.deleteProfileByAddress(rock);
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        zeekHub.refundWish(data);
//
//    }
//
//    function testCannotRefundReferralToken0FeeToken0_msgSenderNotOwner() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.prank(rose);
//        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
//        zeekHub.refundWish(data);
//
//    }
//
//    function testCannotRefundReferralToken0FeeToken0_manyTimes() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.prank(rock);
//        zeekHub.refundWish(data);
//
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        zeekHub.refundWish(data);
//    }
//
//    function testCannotRefundReferralToken20FeeToken0_manyTimes() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.prank(rock);
//        zeekHub.refundWish(data);
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        zeekHub.refundWish(data);
//    }
//
//    function testCannotRefundReferralToken20FeeToken0_wishAlreadyOffered() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 offerReferralWith(1, rock, rose) {
//        //uint oldBonusFee = 1e17;
//        uint256 wishId = 1;
//
//        ZeekDataTypes.WishRefundData memory data = ZeekDataTypes.WishRefundData({
//            wishId: wishId
//        });
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        zeekHub.refundWish(data);
//    }
//
//
//    function testCannotLinkReferral() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        uint linker = 2;
//        string memory linkCode = "000002";
//        uint wishId = 1;
//
//
//        vm.prank(rose);
//        vm.expectRevert(ZeekErrors.WishUnsupportType.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//    }
//
//    function testCannotLinkReferral_msgSenderNoProfile() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        vm.prank(user);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//    }
//
//
//    function testCannotAcceptReferralApply() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//
//        address linker = address(0);
//        //uint talentId = 2;
//        uint linkerProfileId = 0;
//        uint wishId = 1;
//        uint ownerId = 1;
//
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishUnsupportType.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: 0
//            })
//        );
//
//    }
//
//
//    function testOfferReferral_Token0FeeToken0_normal() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            0,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(0),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//        console.log("rock.balance`", (INIT_BALANCE - bonusFee - issueFee.value) / 100);
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE + bonusFee - toPlatform, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferReferral_Token20FeeToken0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            0,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(0),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - bonusFee, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE + bonusFee - toPlatform, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//
//    function testOfferReferral_Token0FeeToken20() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken20 {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            0,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(0),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE + bonusFee - toPlatform, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - issueFee.value, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ERC20_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == mockERC20TokenAddress, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferReferral_Token20FeeToken20() public refferalInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken20 {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            0,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(0),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value + toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - bonusFee - issueFee.value, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE + bonusFee - toPlatform, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ERC20_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == mockERC20TokenAddress, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testCannotOfferReferral_Token0FeeToken0_OfferWishManyTimes() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        uint bonusFee = 1e17;
//        // issueFee = 3e16
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            0,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(0),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        console.log("toPlatform", toPlatform / 1e16);
//        console.log("issueFee.value", issueFee.value / 1e16);
//
//        console.log("deployer.balance", deployer.balance / 1e16);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 1e16);
//        console.log("rock.balance", rock.balance / 1e16);
//        console.log("rose.balance", rose.balance / 1e16);
//
//        console.log("mockERC20Token.balanceOf(deployer)", mockERC20Token.balanceOf(deployer));
//        console.log("mockERC20Token.balanceOf(address(zeekHub))", mockERC20Token.balanceOf(address(zeekHub)));
//        console.log("mockERC20Token.balanceOf(rock)", mockERC20Token.balanceOf(rock));
//        console.log("mockERC20Token.balanceOf(rose)", mockERC20Token.balanceOf(rose));
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE + bonusFee - toPlatform, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//    }
//
//    function testOfferReferral_Token0FeeToken0_linkerNotLinkWish() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        // uint bonusFee = 1e17;
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token0FeeToken0_linkerIsAddress0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 1e16);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 1e16);
//        console.log("rock.balance", rock.balance / 1e16);
//        console.log("rose.balance", rose.balance / 1e16);
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE + bonusFee - toPlatform, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferReferral_Token0FeeToken0_linkerIsJack() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 1e16);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 1e16);
//        console.log("rock.balance", rock.balance / 1e16);
//        console.log("rose.balance", rose.balance / 1e16);
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - bonusFee - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE + bonusFee - toPlatform, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == ETH_ADDRESS, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ETH_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = jackProfileId;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testCannotOfferReferral_Token0FeeToken0_wishNoAccepted() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token0FeeToken0_offerToOwner() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rose,
//            talent: rock,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rockPrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testCannotOfferReferral_Token0FeeToken0_wishAlreadyRefunded() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 refundWishWith(1) dealBalance {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testCannotOfferReferral_Token20FeeToken0_offerToDifferentPeople() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: bob,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                bobPrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//
//    }
//
//    function testCannotOfferReferral_Token20FeeToken0_offerTalentIsNotApplyTalent() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        vm.prank(rock);
//
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: alice,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                alicePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token20FeeToken0_offerLinkerIsNotApplyLinker() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token20FeeToken0_offerLinkerIsApplyLinker() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: bob,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - bonusFee, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE + bonusFee - toPlatform, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        assertEq(offer.linker == 0, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == roseProfileId, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferReferral_Token20FeeToken0_applyLinkerIsAddress0_offerLinkerIsAddress0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, false);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - issueFee.value, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - bonusFee, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE + bonusFee - toPlatform, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Referral, true, "wish type error ");
//        assertEq(zeekHub.getWishStructToken(1) == mockERC20TokenAddress, true, "wish type error ");
//        assertEq(zeekHub.getWishStructTokenVersion(1) == ERC20_VERSION, true, "wish version error ");
//        assertEq(zeekHub.getWishStructBalance(1) == 0, true, "wish version error ");
//        assertEq(zeekHub.getWishStructState(1) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
//        assertEq(zeekHub.getWishStructFeePerMonth(1) == quoraFee, true, "wish fee per month error ");
//        assertEq(zeekHub.getWishStructFeeTokenVersion(1) == ETH_VERSION, true, "wish fee token version error ");
//        assertEq(zeekHub.getWishStructFeeToken(1) == ETH_ADDRESS, true, "wish fee token error ");
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + 3600 * 24 * 30 /*30 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//
//        ZeekDataTypes.Offer memory offer = zeekHub.getWishStructOffer(1);
//
//        uint offerLinker = 0;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == 0, true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferReferral_Token20FeeToken0_offerLinkerIsPoster() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            talent: rose,
//            linker: rock,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token20FeeToken0_offerLinkerIsAddress0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken20FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                rosePrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//
//    }
//
//
//    function testOfferReferral_Token20FeeToken0_ApplyDataLinkerIsAddr0_OfferDataLinkerIsRock() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: bob,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                bobPrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//
//    function testOfferReferral_Token20FeeToken0_acceptLinkerIsAddress0_offerLinkerIsAddress0() public refferalInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueReferralToken0FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: bob,
//            applyTime: uint64(block.timestamp),
//            applyNonce: 0
//        });
//        zeekHub.offerWish(
//            wishApplyData,
//            _getSigStruct(
//                bobPrivateKey,
//                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
//                NO_DEADLINE_64
//            )
//        );
//    }
//}
//
