//
//// SPDX-License-Identifier: MIT
//pragma solidity 0.8.20;
//
//import "../ZeekTestSetUp.sol";
//import "../MetaTxNegatives.sol";
//import "../../contracts/libraries/ZeekErrors.sol";
//import "../../contracts/libraries/ZeekDataTypes.sol";
//
//contract BountyTest is ZeekTestSetUp, MetaTxNegatives {
//
//    modifier offerWishWith(
//        uint _wishId,
//        address linker,
//        address talent
//    ) {
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
//            applyNonce: uint256(0)
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
//
//    function testFuzz_IssueWishToken0FeeToken0_30day(uint bonusFee) public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        vm.deal(rock, UINT256_MAX);
//
//        // exclude 0
//        vm.assume(bonusFee != 0 && bonusFee < UINT256_MAX - issueFee.value);
//
//        //console2.log("issueFee", issueFee.value);
//
//        // uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == UINT256_MAX - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//
//    function testIssueWishToken0FeeToken0_30day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken0FeeToken0_issueTwoWish() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//            ZeekDataTypes.WishType.Bounty
//        )
//            .fee;
//
//
//        bonusFee = 2e17;
//        data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//    function testIssueWishToken0FeeToken0_1day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 1 /*1 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken0FeeToken0_29day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 29 /*29 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken0FeeToken0_31day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 31 /*31 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken20FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken0FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testIssueWishToken20FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//    function testCannotIssueWishToken0FeeToken0_msgValueLtIssueFeeAddWishFee() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        //console2.log("issueFee", issueFee.value);
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value - 5e16}(data);
//
//    }
//
//    function testCannotIssueWishToken0FeeToken0_tokenVersionIs1() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishUnsupportedToken.selector);
////        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//        wishId = zeekHub.issueWish{value: issueFee.value}(data);
//
//    }
//
//    function testCannotIssueWishToken0FeeToken0_msgSenderNoProfile() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(user);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testFailIssueWishToken0FeeToken0_msgValueIs0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: 0}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_bountyFeeIs0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        // uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishAmount.selector);
//        wishId = zeekHub.issueWish{value: issueFee.value}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0FeeToken0_msgValueGtWishFeeAddIssueFee() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value + 1}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_issueFeeIs0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        issueFee.value = 0;
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_withSameSalt() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishSaltProcessed.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_deadlineLeBlockTimestamp() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.warp(1641070800);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_deadlineEqStart() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken0_startGtDeadline() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + issueFee.value}(data);
//    }
//
//    function testCannotIssueWishToken20FeeToken0_msgValueGtIssueFee() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: issueFee.value + 1}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken20_msgValueGtWishFee() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee + 1}(data);
//    }
//
//    function testCannotIssueWishToken0FeeToken20_msgValueLtWishFee() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: bonusFee - 1}(data);
//    }
//
//    function testCannotIssueWishToken20FeeToken20_msgValueGt0() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InsuffinceBalance.selector);
//        wishId = zeekHub.issueWish{value: 1}(data);
//    }
//
//
//    function testModifyWishToken0FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testModifyWishToken20FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//
//        uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint64 newDeadline = uint64(block.timestamp + TWO_MONTH);
//        uint256 wishId = 1;
//
//        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
//            .estimateFeeUseForTest(
//            uint64(block.timestamp),
//            uint64(newDeadline),
//            ZeekDataTypes.WishType.Bounty
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == oldBonusFee + increaseBonus, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//
//        assertEq(zeekHub.getWishStructBalance(1) == oldBonusFee + increaseBonus, true, "wish version error ");
//
//        assertEq(zeekHub.getWishStructStart(1) == uint64(block.timestamp), true, "wish start error ");
//        assertEq(zeekHub.getWishStructDeadline(1) == block.timestamp + TWO_MONTH /*60 day*/, true, "wish deadline error ");
//        assertEq(zeekHub.getWishStructTimestamp(1) == uint64(block.timestamp), true, "wish timestamp error ");
//        assertEq(zeekHub.getWishStructLastModifyTime(1) == uint64(block.timestamp), true, "wish last modify timestamp error ");
//    }
//
//    function testModifyWishToken0FeeToken0_newDeadlineEqualOldDeadline() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testModifyWishToken0FeeToken0_newDeadlineLtOldDeadline() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//        uint256 oldBonusFee = 1e17;
//
//        uint256 increaseBonus = 4e17;
//        uint256 newDeadline = block.timestamp + MONTH - 1;
//        uint256 wishId = 1;
//
////        ZeekDataTypes.TokenValue memory newIssueFee = zeekHub
////        .estimateFee(
////            uint64(block.timestamp),
////            uint64(newDeadline),
////            ZeekDataTypes.WishType.Bounty
////        )
////        .fee;
////
////        uint256 shouldIncreaseFee = newIssueFee.value - issueFee.value;
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
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
//    function testCannotModifyWishToken0FeeToken0_newDeadlineLtOldStart() public wishInitializeFeeTokenETH createProfile estimateFeeWithStartEnd(WEEK, WEEK + MONTH) {
//
//        uint256 bonusFee = 1e17;
//        ZeekDataTypes.WishIssueData memory WishIssueData = ZeekDataTypes
//            .WishIssueData({
//            wishType: ZeekDataTypes.WishType.Bounty,
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
//
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
//        //            ZeekDataTypes.WishType.Bounty
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
////        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance   , true, "rock balance error");
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
//    function testCannotModifyWishToken0FeeToken0_msgSenderNotOwner() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testCannotModifyWishToken0FeeToken0_wishIdError() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testCannotModifyWishToken0FeeToken0_msgValueGtIncreaseWishFeeAddIncreaseIssueFee() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testCannotModifyWishToken0FeeToken0_msgValueLtIncreaseWishFeeAddIncreaseIssueFee() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testCannotModifyWishToken0FeeToken0_msgSenderNoProfile() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//            ZeekDataTypes.WishType.Bounty
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
//    function testRefundWishToken0FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//    function testRefundWishToken0FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken20 {
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
//    function testRefundWishToken20FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken20 {
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
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
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
//    function testRefundWishToken20FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
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
//    function testRefundWishToken0FeeToken0_wishBeLinked() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) {
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
//    function testRefundWishToken0FeeToken0_wishBeAccepted() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) acceptWishApplyWith(jack, rose) {
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
//    function testCannotRefundWishToken0FeeToken0_msgSenderNoProfile() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//    function testCannotRefundWishToken0FeeToken0_msgSenderNotOwner() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//    function testCannotRefundWishToken0FeeToken0_manyTimes() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
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
//    function testCannotRefundWishToken20FeeToken0_manyTimes() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
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
//    function testCannotRefundWishToken20FeeToken0_wishAlreadyOffered() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 acceptWishApplyWith(rock, rose) offerWishWith(1, rock, rose) {
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
//    function testLinkWish_linkByOther() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        uint linker = 2; /*rose*/
//        string memory linkCode = "000002";
//        uint wishId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishLinked(wishId, linker, uint64(block.timestamp));
//
//        vm.prank(rose);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//        assertEq(keccak256(abi.encodePacked(zeekHub.getWishStructLinkCode(1, linker))) == keccak256(abi.encodePacked(linkCode)), true, "wish link code error ");
//    }
//
//    function testLinkWish_linkByDifferentUser() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        uint roseLinker = 2; /*rose*/
//        uint jackLinker = 3; /*rose*/
//        string memory roseLinkCode = "000002";
//        string memory jackLinkCode = "000003";
//        uint wishId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishLinked(wishId, roseLinker, uint64(block.timestamp));
//
//        vm.prank(rose);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishLinked(wishId, jackLinker, uint64(block.timestamp));
//
//        vm.prank(jack);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//        assertEq(keccak256(abi.encodePacked(zeekHub.getWishStructLinkCode(1, roseLinker))) == keccak256(abi.encodePacked(roseLinkCode)), true, "wish roseLink code error ");
//        assertEq(keccak256(abi.encodePacked(zeekHub.getWishStructLinkCode(1, jackLinker))) == keccak256(abi.encodePacked(jackLinkCode)), true, "wish jackLink code error ");
//    }
//
//    function testCannotLinkWish_linkByPoster() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        // uint linker = 1; /*rock*/
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishAlreadyLinked.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//        //assertEq(zeekHub.getWishStructLinkCode(1, linker) == "000001",  true, "wish link code error ");
//    }
//
//    function testCannotLinkWish_linkManyTimesByOne() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        uint wishId = 1;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishAlreadyLinked.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//    }
//
//    function testCannotLinkWish_linkManyTimesByJack() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        uint wishId = 1;
//
//        vm.prank(jack);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//        vm.prank(jack);
//        vm.expectRevert(ZeekErrors.WishAlreadyLinked.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//
//    }
//
//    function testCannotLinkWish_msgSenderNoProfile() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 {
//        vm.prank(user);
//        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
//        zeekHub.linkWish(ZeekDataTypes.WishLinkData({wishId: wishId}));
//    }
//
//
//    function testCannotAcceptWishApply_BountyDefaultLinkByOwner_ApplyDataLinkerIsOwner() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//
//        address linker = rock;
//        //uint talentId = 2;
//        uint linkerProfileId = 1;
//        uint wishId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishApplyAccepted(
//            wishId,
//            roseProfileId,
//            1,
//            rockProfileId,
//            uint64(block.timestamp),
//            0,
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
////        vm.expectRevert(ZeekErrors.NotWishLinker.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//    }
//
//    function testAcceptWishApply_talentIsOwner() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: rose,
//                talent: rock,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//    }
//
//    function testAcceptWishApply_talentHasLinked() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) linkWishWith(jack, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: jack,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//    }
//
//    function testCannotAcceptWishApply_LinkerIsTalent() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) {
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishLinker.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: jack,
//                talent: jack,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//    }
//
//    function testAcceptWishApply_linkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//
//        // address linker = address(0);
//        // uint talentId = 2;
//        uint linkerProfileId = 0;
//        uint wishId = 1;
//        uint ownerId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishApplyAccepted(
//            wishId,
//            roseProfileId,
//            linkerProfileId,
//            ownerId,
//            uint64(block.timestamp),
//            0,
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: address(0),
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//    }
//
//    function testCannotAcceptWishApply_manyTimes() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//
//        address linker = rock;
//        //uint talentId = 2;
//        uint linkerProfileId = 1;
//        uint wishId = 1;
//        uint ownerId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishApplyAccepted(
//            wishId,
//            roseProfileId,
//            linkerProfileId,
//            ownerId,
//            uint64(block.timestamp),
//            0,
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishExistCandidate.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//    }
//
//    function testCannotAcceptWishApply_linkerNotLink() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//
//        address linker = jack;
//        //uint talentId = 2;
//        //uint linkerProfileId = 3;
//        uint wishId = 1;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishLinker.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//
//    }
//
//    function testAcceptWishApply_linkByJack_acceptLinkerIsPoster() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) {
//
//        address linker = rock;
//        uint talentId = 2;
//        uint linkerProfileId = 1;
//        uint wishId = 1;
//        uint ownerId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishApplyAccepted(
//            wishId,
//            roseProfileId,
//            linkerProfileId,
//            ownerId,
//            uint64(block.timestamp),
//            0,
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: linker,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).applyTime == uint64(block.timestamp), true, "wish candidates applyTime error");
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).approveTime == uint64(block.timestamp), true, "wish candidates approveTime error");
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).linker == 1, true, "wish candidates linker error");
////         assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).talent==talentId, true, "wish candidates talent error");
//    }
//
//    function testAcceptWishApply_linkByJack_acceptLinkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) {
//
//        //address linker = rock;
//        uint talentId = 2;
//        uint linkerProfileId = 0;
//        uint wishId = 1;
//        uint ownerId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishApplyAccepted(
//            wishId,
//            roseProfileId,
//            linkerProfileId,
//            ownerId,
//            uint64(block.timestamp),
//            0,
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: wishId,
//                linker: address(0),
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).applyTime == uint64(block.timestamp), true, "wish candidates applyTime error");
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).approveTime == uint64(block.timestamp), true, "wish candidates approveTime error");
//        assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).linker == 0, true, "wish candidates linker error");
//        //         assertEq(zeekHub.getWishStructCandidatesTalent(wishId, talentId).talent==talentId, true, "wish candidates talent error");
//    }
//
//    function testCannotAcceptWishApply_manyTimes_linkByDifferentPeople() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: jack,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishExistCandidate.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: bob,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//
//    }
//
//    function testAcceptWishApply_acceptTwoDifferentApply_linkByDifferentPeople() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: jack,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: bob,
//                talent: alice,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).applyTime==uint64(block.timestamp), true, "wish candidates rose applyTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).approveTime==uint64(block.timestamp), true, "wish candidates rose approveTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).linker==jackProfileId, true, "wish candidates rose linker error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).talent==roseProfileId, true, "wish candidates rose talent error");
//
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).applyTime==uint64(block.timestamp), true, "wish candidates alice applyTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).approveTime==uint64(block.timestamp), true, "wish candidates alice approveTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).linker==bobProfileId, true, "wish candidates alice linker error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).talent==aliceProfileId, true, "wish candidates alice talent error");
//    }
//
//    function testAcceptWishApply_acceptTwoDifferentApply_linkBySamePeople() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(jack, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: jack,
//                talent: rose,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: jack,
//                talent: alice,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).applyTime==uint64(block.timestamp), true, "wish candidates rose applyTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).approveTime==uint64(block.timestamp), true, "wish candidates rose approveTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).linker==jackProfileId, true, "wish candidates rose linker error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, roseProfileId).talent==roseProfileId, true, "wish candidates rose talent error");
//
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).applyTime==uint64(block.timestamp), true, "wish candidates alice applyTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).approveTime==uint64(block.timestamp), true, "wish candidates alice approveTime error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).linker==jackProfileId, true, "wish candidates alice linker error");
//        // assertEq(zeekHub.getWishStructCandidatesTalent(1, aliceProfileId).talent==aliceProfileId, true, "wish candidates alice talent error");
//    }
//
//    function testCannotAcceptWishApply_acceptSameApply_linkByDifferentPeople() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) linkWishWith(jack, 1) {
//
//        vm.prank(rock);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: rose,
//                talent: bob,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.WishExistCandidate.selector);
//        zeekHub.acceptWishApply(
//            ZeekDataTypes.WishAcceptApplyData({
//                wishId: 1,
//                linker: jack,
//                talent: bob,
//                applyTime: uint64(block.timestamp),
//                applyNonce: uint256(0)
//            })
//        );
//
//    }
//
//
//    function testOfferWish_Token0FeeToken0_normal() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 acceptWishApplyWith(rock, rose) {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            rockProfileId,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        uint offerLinker = 1;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferWish_Token20FeeToken0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 acceptWishApplyWith(rock, rose) {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            rockProfileId,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        uint offerLinker = 1;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferWish_Token20FeeToken0_linkByJack() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) acceptWishApplyWith(jack, rose) {
//
//        uint bonusFee = 1e17;
//        address linker = jack;
//        address talent = rose;
//
//        uint ownerId = 1;
//        uint linkerId = 3;
//        uint talentId = 2;
//        uint wishId = 1;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            talentId,
//            linkerId,
//            ownerId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: linker,
//            talent: talent,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (uint toLinker, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 1e16);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 1e16);
//        console.log("rock.balance", rock.balance / 1e16);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//        assertEq(jack.balance == INIT_BALANCE, true, "jack balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0 + toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)) - toLinker, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//        assertEq(mockERC20Token.balanceOf(jack) == INIT_BALANCE + toLinker, true, "jack token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//
//        assertEq(offer.linker == linkerId, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talentId, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferWish_Token0FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken20 acceptWishApplyWith(rock, rose) {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            rockProfileId,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        uint offerLinker = 1;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferWish_Token20FeeToken20() public wishInitializeFeeTokenERC20 createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken20 acceptWishApplyWith(rock, rose) {
//
//        uint bonusFee = 1e17;
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            rockProfileId,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == 0, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == issueFee.value + toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        uint offerLinker = 1;
//        uint talent = 2;
//        assertEq(offer.linker == offerLinker, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testCannotOfferWish_Token0FeeToken0_OfferWishManyTimes() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 acceptWishApplyWith(rock, rose) {
//        uint bonusFee = 1e17;
//        // issueFee = 3e16
//
//        vm.expectEmit(true, true, false, true);
//        emit ZeekEvents.WishOffered(
//            wishId,
//            roseProfileId,
//            rockProfileId,
//            rockProfileId,
//            uint64(block.timestamp),
//            uint256(0),
//            uint64(block.timestamp),
//            uint64(block.timestamp)
//        );
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//    }
//
//    function testCannotOfferWish_Token0FeeToken0_linkerNotLinkWish() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 acceptWishApplyWith(rock, rose) {
//        // uint bonusFee = 1e17;
//
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishLinker.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testOfferWish_Token0FeeToken0_linkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 acceptWishApplyWith(address(0), rose) {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//
//        assertEq(deployer.balance == issueFee.value + toPlatform, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == 0, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE, true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        //uint offerLinker = 1;
//        uint talent = 2;
//        assertEq(offer.linker == 0, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testCannotOfferWish_Token0FeeToken0_wishNoAccepted() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishCandidate.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testOfferWish_Token0FeeToken0_offerToOwner() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) acceptWishApplyWith(rose, rock) {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rose,
//            talent: rock,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testCannotOfferWish_Token0FeeToken0_wishAlreadyRefunded() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 acceptWishApplyWith(rock, rose) refundWishWith(1) dealBalance {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testCannotOfferWish_Token20FeeToken0_offerToDifferentPeople() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) acceptWishApplyWith(jack, rose) acceptWishApplyWith(jack, bob) {
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//            applyNonce: uint256(0)
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
//    function testCannotOfferWish_Token20FeeToken0_offerTalentIsNotApplyTalent() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(bob, rose) {
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishCandidate.selector);
//
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: alice,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testCannotOfferWish_Token20FeeToken0_offerLinkerIsNotApplyLinker() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(bob, rose) {
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishLinker.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: jack,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testOfferWish_Token20FeeToken0_offerLinkerIsApplyLinker() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(bob, rose) {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: bob,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (uint toLinker, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance / 100);
//        console.log("address(zeekHub).balance", address(zeekHub).balance / 100);
//        console.log("rock.balance", rock.balance / 100);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)) - mockERC20Token.balanceOf(bob), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//        assertEq(mockERC20Token.balanceOf(bob) == toLinker, true, "bob token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        assertEq(offer.linker == bobProfileId, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == roseProfileId, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testOfferWish_Token20FeeToken0_applyLinkerIsAddress0_offerLinkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(address(0), rose) {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == talent, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//    // should revert
//    function testCannotOfferWish_Token20FeeToken0_applyLinkerIsAddress0_offerLinkerIsPoster() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(address(0), rose) {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishLinker.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    // should revert
//    function testCannotOfferWish_Token20FeeToken0_posterNotLink_applyLinkerIsPoster_offerLinkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(rock, rose) {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.NotWishLinker.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testOfferWish_Token20FeeToken0_posterNotLink_applyLinkerIsPoster_offerLinkerIsPoster() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken20FeeToken0 linkWishWith(jack, 1) linkWishWith(bob, 1) acceptWishApplyWith(rock, rose) {
//        uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: rose,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//        (, uint toPlatform) = zeekHub.calculateWishFeeSharing(bonusFee, true);
//
//        assertEq(wishId == 1, true, "wishId error");
//
//        console.log("deployer.balance", deployer.balance);
//        console.log("address(zeekHub).balance", address(zeekHub).balance);
//        console.log("rock.balance", rock.balance);
//
//        assertEq(deployer.balance == issueFee.value, true, "deployer balance error");
//        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
//        assertEq(rock.balance == INIT_BALANCE - deployer.balance - address(zeekHub).balance, true, "rock balance error");
//        assertEq(rose.balance == INIT_BALANCE, true, "rose balance error");
//
//        assertEq(mockERC20Token.balanceOf(deployer) == toPlatform, true, "deployer token balance error");
//        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub token balance error");
//        assertEq(mockERC20Token.balanceOf(rock) == INIT_BALANCE - mockERC20Token.balanceOf(deployer) - mockERC20Token.balanceOf(address(zeekHub)), true, "rock token balance error");
//        assertEq(mockERC20Token.balanceOf(rose) == INIT_BALANCE, true, "rose token balance error");
//
//        assertEq(zeekHub.getWishStructOwner(1) == 1, true, "wish owner error ");
//        assertEq(zeekHub.getWishStructWishType(1) == ZeekDataTypes.WishType.Bounty, true, "wish type error ");
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
//        assertEq(offer.linker == rockProfileId, true, "wish offer linker error");
//        assertEq(offer.approveTime == uint64(block.timestamp), true, "wish offer approveTime error");
//        assertEq(offer.applyTime == uint64(block.timestamp), true, "wish offer applyTime error");
//        assertEq(offer.talent == roseProfileId, true, "wish offer talent error");
//        assertEq(offer.timestamp == uint64(block.timestamp), true, "wish offer timestamp error");
//    }
//
//    function testCannotOfferWish_Token20FeeToken0_LinkByRose_ApplyDataLinkerIsAddr0_OfferDataLinkerIsRock() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) acceptWishApplyWith(address(0), bob) {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        vm.expectRevert(ZeekErrors.InvalidWishLinker.selector);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: rock,
//            talent: bob,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testOfferWish_Token20FeeToken0_acceptLinkerIsAddress0_offerLinkerIsAddress0() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) issueWishToken0FeeToken0 linkWishWith(rose, 1) acceptWishApplyWith(address(0), bob) {
//        //uint bonusFee = 1e17;
//
//        vm.prank(rock);
//        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
//            wishId: wishId,
//            linker: address(0),
//            talent: bob,
//            applyTime: uint64(block.timestamp),
//            applyNonce: uint256(0)
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
//    function testEstimateFee0Day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 0 /*30 day*/) {
//        vm.prank(rock);
//        uint256 fee = zeekHub.estimateFee(uint64(block.timestamp), uint64(block.timestamp + 3600 * 24 * 0), ZeekDataTypes.WishType.Bounty).fee.value;
//        assertEq(fee, issueFee.value, "issueFee error");
//
//        //assertEq(zeekHub.getWishStructBalance(1) == ETH_VERSION, true, "wish version error ");
//    }
//
//    function testEstimateFee15Day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 15 /*30 day*/) {
//        vm.prank(rock);
//        uint256 fee = zeekHub.estimateFee(uint64(block.timestamp), uint64(block.timestamp + 3600 * 24 * 15), ZeekDataTypes.WishType.Bounty).fee.value;
//
//        assertEq(fee, issueFee.value, "issueFee error");
//
//        //assertEq(zeekHub.getWishStructBalance(1) == ETH_VERSION, true, "wish version error ");
//    }
//
//    function testEstimateFee30Day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 30 /*30 day*/) {
//        vm.prank(rock);
//        uint256 fee = zeekHub.estimateFee(uint64(block.timestamp), uint64(block.timestamp + 3600 * 24 * 15), ZeekDataTypes.WishType.Bounty).fee.value;
//
//        assertEq(fee, issueFee.value, "issueFee error");
//
//        //assertEq(zeekHub.getWishStructBalance(1) == ETH_VERSION, true, "wish version error ");
//    }
//
//    function testEstimateFee45Day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 45 /*45 day*/) {
//        vm.prank(rock);
//        uint256 fee = zeekHub.estimateFee(uint64(block.timestamp), uint64(block.timestamp + 3600 * 24 * 45), ZeekDataTypes.WishType.Bounty).fee.value;
//        assertEq(fee, issueFee.value, "issueFee error");
//    }
//
//    function testEstimateFee60Day() public wishInitializeFeeTokenETH createProfile estimateFeeWithTime(3600 * 24 * 60 /*45 day*/) {
//        vm.prank(rock);
//        uint256 fee = zeekHub.estimateFee(uint64(block.timestamp), uint64(block.timestamp + 3600 * 24 * 60), ZeekDataTypes.WishType.Bounty).fee.value;
//        assertEq(fee, issueFee.value, "issueFee error");
//    }
//
//
//}
//
