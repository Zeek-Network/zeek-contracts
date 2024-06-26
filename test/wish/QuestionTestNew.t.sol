// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "../ZeekTestSetUp.sol";
import "../MetaTxNegatives.sol";
import "../../contracts/libraries/ZeekErrors.sol";
import "../../contracts/libraries/ZeekDataTypes.sol";


contract QuestionTestNew is ZeekTestSetUp, MetaTxNegatives {
//==>test IssueWish
    function testIssueWish_Question_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });


        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishIssued(
            1,
            rockProfileId,
            rockProfileId,
            data.wishType,
            true,
            ZeekDataTypes.WishTokenValue({
                token: ETH_ADDRESS,
                tokenVersion: ETH_VERSION,
                value: bonusValue,
                bidValue: 0.011 ether,
                balance: bonusValue
            }),
            ZeekDataTypes.OfferRatio(0.009 ether, 0, 0.001 ether),
            ZeekDataTypes.OfferRatio(0.009 ether, 0, 0.001 ether),
            data.start,
            data.deadline,
            data.salt
        );

        vm.prank(rock);
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0.01 ether, true, "zeekHub balance error");
        assertEq(rock.balance == 0.04 ether, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
        assertEq(zeekHub.getWishHistorySalt(1), true, "wishHistorySalt error");
        //assert wish
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish issuer error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish owner error ");
        assertEq(zeekHub.getWishStructWishType(wishId) == ZeekDataTypes.WishType.Question, true, "wish type error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 0.01 ether, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 0.011 ether, "wish price bid value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0.01 ether, "wish price balance error ");

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Active, true, "wish state error ");
        assertEq(zeekHub.getWishStructRestricted(wishId), true, "wish restricted error ");

        //assert directOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).talent == 90, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).linker == 0, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).platform == 10, true, "wish direct offer ratio error ");

        //assert linkOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).talent == 90, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).linker == 0, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).platform == 10, true, "wish link offer ratio error ");

        assertEq(zeekHub.getWishStructStart(wishId), block.timestamp, "wish start error ");
        assertEq(zeekHub.getWishStructDeadline(wishId), block.timestamp + 3600 * 24 * 30, "wish deadline error ");
        assertEq(zeekHub.getWishStructTimestamp(wishId), uint64(block.timestamp), "wish timestamp error ");
    }


    function testIssueWish_Question_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        uint256 bonusValue = 1 * 10 ** 6;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });


        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishIssued(
            1,
            rockProfileId,
            rockProfileId,
            data.wishType,
            true,
            ZeekDataTypes.WishTokenValue({
                token: mockERC20TokenAddress,
                tokenVersion: ERC20_VERSION,
                value: bonusValue,
                bidValue: 11 * 10 ** 5,
                balance: bonusValue
            }),
            ZeekDataTypes.OfferRatio(9 * 10 ** 5, 0, 1 * 10 ** 5),
            ZeekDataTypes.OfferRatio(9 * 10 ** 5, 0, 1 * 10 ** 5),
            data.start,
            data.deadline,
            data.salt
        );

        vm.prank(rock);
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == bonusValue, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 4 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
        assertEq(zeekHub.getWishHistorySalt(1), true, "wishHistorySalt error");
        //assert wish
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish issuer error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish owner error ");
        assertEq(zeekHub.getWishStructWishType(wishId) == ZeekDataTypes.WishType.Question, true, "wish type error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, bonusValue, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 11 * 10 ** 5, "wish price bid value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, bonusValue, "wish price balance error ");

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Active, true, "wish state error ");
        assertEq(zeekHub.getWishStructRestricted(wishId), true, "wish restricted error ");

        //assert directOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).talent == 90, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).linker == 0, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).platform == 10, true, "wish direct offer ratio error ");

        //assert linkOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).talent == 90, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).linker == 0, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).platform == 10, true, "wish link offer ratio error ");

        assertEq(zeekHub.getWishStructStart(wishId), block.timestamp, "wish start error ");
        assertEq(zeekHub.getWishStructDeadline(wishId), block.timestamp + 3600 * 24 * 30, "wish deadline error ");
        assertEq(zeekHub.getWishStructTimestamp(wishId), uint64(block.timestamp), "wish timestamp error ");
    }

    function testIssueWish_WishSaltProcessed() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
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
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);
        assertEq(wishId == 1, true, "wishId error");


        vm.expectRevert(ZeekErrors.WishSaltProcessed.selector);
        vm.prank(rock);
        //Repeat with salt:1
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0.01 ether, true, "zeekHub balance error");
        assertEq(rock.balance == 0.04 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMsgValue_InsufficientBalance_WithNative1() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(rock);
        //msg.value > bonusValue
        wishId = zeekHub.issueWish{value: (0.01 ether + 1)}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMsgValue_InsufficientBalance_WithNative2() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(rock);
        //msg.value < bonusValue
        wishId = zeekHub.issueWish{value: (0.01 ether - 1)}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMsgValue_InsufficientBalance_WithERC20() public createProfile {
        vm.deal(rock, 0.05 ether);
        mockERC20Token.mint(rock, 1 * 10 ** 6);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(rock);
        //msg.value != 0
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateWishTime_startGtDeadline() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp + 3600 * 24 * 31),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //start > deadline
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateWishTime_startEqDeadline() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp + 3600 * 24 * 30),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //start == deadline
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_minIssueTokensEqZero_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);
        //Set Minimum Issue Tokens value == 0
        vm.prank(deployer);
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 0, true);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueLtMinIssue_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = (0.01 ether - 1);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //default Set Minimum Issue Tokens value == 0.01 ether
        //bonusValue < minIssueTokens
        wishId = zeekHub.issueWish{value: (0.01 ether - 1)}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueGtMinIssue_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.02 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
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
        //default Set Minimum Issue Tokens value == 0.01 ether
        //bonusValue > minIssueTokens,issue success
        wishId = zeekHub.issueWish{value: 0.02 ether}(data);

        assertEq(address(zeekHub).balance == 0.02 ether, true, "zeekHub balance error");
        assertEq(rock.balance == 0.03 ether, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueEqMinIssue_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
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
        //bonusValue == minIssueTokens,issue success
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0.01 ether, true, "zeekHub balance error");
        assertEq(rock.balance == 0.04 ether, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_minIssueTokensEqZero_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        //Set Minimum Issue Tokens value == 0
        vm.prank(deployer);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ERC20_VERSION, 0, true);

        uint256 bonusValue = (1 * 10 ** 6);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 5 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueLtMinIssue_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        uint256 bonusValue = (1 * 10 ** 6 - 1);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //default Set Minimum Issue Tokens value == 1 * 10 ** 6
        //bonusValue < minIssueTokens
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 5 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueGtMinIssue_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        uint256 bonusValue = (2 * 10 ** 6);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
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
        //default Set Minimum Issue Tokens value == 1 * 10 ** 6
        //bonusValue > minIssueTokens, issue success
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 2 * 10 ** 6, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 3 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
    }

    function testIssueWish_validateMinimumTokens_bonusValueEqMinIssue_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        uint256 bonusValue = (1 * 10 ** 6);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
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
        //default Set Minimum Issue Tokens value == 1 * 10 ** 6
        //bonusValue == minIssueTokens, issue success
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 1 * 10 ** 6, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 4 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
    }

    function testIssueWish_validateHasProfile_issuerNotHasProfile() public createProfile {
        console2.log(user.balance);
        vm.deal(user, 0.05 ether);
        console2.log(user.balance);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        //user not has profile
        vm.prank(user);
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(user.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_unsupportedToken() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        uint unsupportedToken = 50;

        uint256 bonusValue = (1 * 10 ** 6);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: unsupportedToken,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.WishUnsupportedToken.selector);
        vm.prank(rock);
        //unsupported token
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 5 * 10 ** 6, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_issuerNotEnoughBalance_bonusIsNative() public createProfile {
        vm.deal(rock, 0.005 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert();
        vm.prank(rock);
        wishId = zeekHub.issueWish{value: 0.01 ether}(data);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.005 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

    function testIssueWish_issuerNotEnoughBalance_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 1 * 10 ** 5);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 1 * 10 ** 5);

        uint256 bonusValue = (1 * 10 ** 6);
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert();
        vm.prank(rock);
        wishId = zeekHub.issueWish(data);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 1 * 10 ** 5, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

//==>test IssueWishPlug

    function testIssueWishPlug_Question_bonusIsNative() public createProfile {
        vm.deal(rock, 0.05 ether);
        vm.deal(user, 0.05 ether);
        vm.prank(deployer);
        zeekHub.whitelistApp(user, true);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });


        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishIssued(
            1,
            rockProfileId,
            rockProfileId,
            data.wishType,
            true,
            ZeekDataTypes.WishTokenValue({
                token: ETH_ADDRESS,
                tokenVersion: ETH_VERSION,
                value: bonusValue,
                bidValue: 0.011 ether,
                balance: bonusValue
            }),
            ZeekDataTypes.OfferRatio(0.009 ether, 0, 0.001 ether),
            ZeekDataTypes.OfferRatio(0.009 ether, 0, 0.001 ether),
            data.start,
            data.deadline,
            data.salt
        );

        vm.prank(user);
        wishId = zeekHub.issueWishPlug{value: 0.01 ether}(data, rock);

        assertEq(address(zeekHub).balance == 0.01 ether, true, "zeekHub balance error");
        assertEq(user.balance == 0.04 ether, true, "user balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 1, true, "wishId error");
        assertEq(zeekHub.getWishHistorySalt(1), true, "wishHistorySalt error");
        //assert wish
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish issuer error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish owner error ");
        assertEq(zeekHub.getWishStructWishType(wishId) == ZeekDataTypes.WishType.Question, true, "wish type error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, ETH_ADDRESS, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ETH_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 0.01 ether, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 0.011 ether, "wish price bid value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0.01 ether, "wish price balance error ");

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Active, true, "wish state error ");
        assertEq(zeekHub.getWishStructRestricted(wishId), true, "wish restricted error ");

        //assert directOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).talent == 90, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).linker == 0, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).platform == 10, true, "wish direct offer ratio error ");

        //assert linkOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).talent == 90, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).linker == 0, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).platform == 10, true, "wish link offer ratio error ");

        assertEq(zeekHub.getWishStructStart(wishId), block.timestamp, "wish start error ");
        assertEq(zeekHub.getWishStructDeadline(wishId), block.timestamp + 3600 * 24 * 30, "wish deadline error ");
        assertEq(zeekHub.getWishStructTimestamp(wishId), uint64(block.timestamp), "wish timestamp error ");
    }

    function testIssueWishPlug_Question_bonusIsERC20() public createProfile {
        mockERC20Token.mint(rock, 5 * 10 ** 6);
        vm.prank(rock);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        mockERC20Token.mint(user, 5 * 10 ** 6);
        vm.prank(user);
        mockERC20Token.approve(address(zeekHub), 5 * 10 ** 6);

        vm.prank(deployer);
        zeekHub.whitelistApp(user, true);

        uint256 bonusValue = 1 * 10 ** 6;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });


        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishIssued(
            1,
            rockProfileId,
            rockProfileId,
            data.wishType,
            true,
            ZeekDataTypes.WishTokenValue({
                token: mockERC20TokenAddress,
                tokenVersion: ERC20_VERSION,
                value: bonusValue,
                bidValue: 11 * 10 ** 5,
                balance: bonusValue
            }),
            ZeekDataTypes.OfferRatio(9 * 10 ** 5, 0, 1 * 10 ** 5),
            ZeekDataTypes.OfferRatio(9 * 10 ** 5, 0, 1 * 10 ** 5),
            data.start,
            data.deadline,
            data.salt
        );

        vm.prank(user);
        wishId = zeekHub.issueWishPlug(data, rock);

        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == bonusValue, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(rock) == 4 * 10 ** 6, true, "rock balance error");
        assertEq(mockERC20Token.balanceOf(user) == 5 * 10 ** 6, true, "user balance error");

        assertEq(wishId == 1, true, "wishId error");
        assertEq(zeekHub.getWishHistorySalt(1), true, "wishHistorySalt error");
        //assert wish
        assertEq(zeekHub.getWishStructIssuer(wishId), rockProfileId, "wish issuer error ");
        assertEq(zeekHub.getWishStructOwner(wishId), rockProfileId, "wish owner error ");
        assertEq(zeekHub.getWishStructWishType(wishId) == ZeekDataTypes.WishType.Question, true, "wish type error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).token, mockERC20TokenAddress, "wish price token error ");
        assertEq(zeekHub.getWishStructPrice(wishId).tokenVersion, ERC20_VERSION, "wish price token version error ");
        assertEq(zeekHub.getWishStructPrice(wishId).value, 1 * 10 ** 6, "wish price value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).bidValue, 11 * 10 ** 5, "wish price bid value error ");
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 1 * 10 ** 6, "wish price balance error ");

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Active, true, "wish state error ");
        assertEq(zeekHub.getWishStructRestricted(wishId), true, "wish restricted error ");

        //assert directOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).talent == 90, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).linker == 0, true, "wish direct offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Direct).platform == 10, true, "wish direct offer ratio error ");

        //assert linkOfferRatio
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).talent == 90, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).linker == 0, true, "wish link offer ratio error ");
        assertEq(zeekHub.getWishStructOfferRatio(wishId, ZeekDataTypes.OfferType.Link).platform == 10, true, "wish link offer ratio error ");

        assertEq(zeekHub.getWishStructStart(wishId), block.timestamp, "wish start error ");
        assertEq(zeekHub.getWishStructDeadline(wishId), block.timestamp + 3600 * 24 * 30, "wish deadline error ");
        assertEq(zeekHub.getWishStructTimestamp(wishId), uint64(block.timestamp), "wish timestamp error ");
    }

    function testIssueWishPlug_AppNotWhitelisted() public createProfile {
        vm.prank(deployer);
        zeekHub.whitelistApp(user, false);

        vm.deal(rock, 0.05 ether);

        uint256 bonusValue = 0.01 ether;
        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: ZeekDataTypes.WishType.Question,
            restricted: true,
            bonus: ZeekDataTypes.TokenValue({
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: 1
        });

        vm.expectRevert(ZeekErrors.AppNotWhitelisted.selector);
        vm.prank(user);
        //user not in whitelistApp
        wishId = zeekHub.issueWishPlug{value: 0.01 ether}(data, rock);

        assertEq(address(zeekHub).balance == 0, true, "zeekHub balance error");
        assertEq(rock.balance == 0.05 ether, true, "rock balance error");

        assertEq(wishId == 0, true, "wishId error");
    }

//==>test OfferWish
    function testOfferWish_QuestionWish_bonusIsNative_withOutLinker() public createProfile {

        vm.deal(jack, 0);

        //Question_Direct_OfferRatios(90, 0, 10)
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            0,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0.009 ether,
                linker: 0,
                platform: 0.001 ether
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == 0, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Question_Direct_OfferRatios(90, 0, 10)
        //assert balance
        assertEq(jack.balance, 0.009 ether, "jack balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.001 ether, "finance balance error");
    }

    function testOfferWish_QuestionWish_bonusIsERC20_withOutLinker() public createProfile {
        //Question_Direct_OfferRatios(90, 0, 10)
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 1 * 10 ** 6, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            0,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 9 * 10 ** 5,
                linker: 0,
                platform: 1 * 10 ** 5
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == 0, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Question_Direct_OfferRatios(90, 0, 10)
        //assert balance
        assertEq(mockERC20Token.balanceOf(jack) == 9 * 10 ** 5, true, "jack balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == 1 * 10 ** 5, true, "finance balance error");
    }

    function testOfferWish_ReferralWish_bonusIsNative_withOutLinker() public createProfile {

        vm.deal(jack, 0);

        //Referral_Direct_OfferRatios(0, 0, 100)
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Referral, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            0,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0,
                linker: 0,
                platform: 0.01 ether
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == 0, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Referral_Direct_OfferRatios(0, 0, 100)
        //assert balance
        assertEq(jack.balance, 0, "jack balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.01 ether, "finance balance error");
    }

    function testOfferWish_ReferralWish_bonusIsERC20_withOutLinker() public createProfile {
        //Referral_Direct_OfferRatios(0, 0, 100)
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Referral, 1 * 10 ** 6, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            0,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0,
                linker: 0,
                platform: 1 * 10 ** 6
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == 0, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Referral_Direct_OfferRatios(0, 0, 100)
        //assert balance
        assertEq(mockERC20Token.balanceOf(jack) == 0, true, "jack balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == 1 * 10 ** 6, true, "finance balance error");
    }

    function testOfferWish_QuestionWish_bonusIsNative_withLinker() public createProfile {
        vm.deal(jack, 0);
        vm.deal(rose, 0);

        //Question_Link_OfferRatios(90, 0, 10)
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: rose,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            roseProfileId,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0.009 ether,
                linker: 0,
                platform: 0.001 ether
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == roseProfileId, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Question_Link_OfferRatios(90, 0, 10)
        //assert balance
        assertEq(jack.balance, 0.009 ether, "jack balance error");
        assertEq(rose.balance, 0, "rose balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.001 ether, "finance balance error");
    }

    function testOfferWish_QuestionWish_bonusIsERC20_withLinker() public createProfile {
        //Question_Link_OfferRatios(90, 0, 10)
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 1 * 10 ** 6, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: rose,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            roseProfileId,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 9 * 10 ** 5,
                linker: 0,
                platform: 1 * 10 ** 5
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == roseProfileId, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Question_Link_OfferRatios(90, 0, 10)
        //assert balance
        assertEq(mockERC20Token.balanceOf(jack), 9 * 10 ** 5, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rose), 0, "rose balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == 1 * 10 ** 5, true, "finance balance error");
    }

    function testOfferWish_ReferralWish_bonusIsNative_withLinker() public createProfile {
        vm.deal(jack, 0);
        vm.deal(rose, 0);

        //Referral_Link_OfferRatios(0, 90, 10)
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Referral, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: rose,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            roseProfileId,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0,
                linker: 0.009 ether,
                platform: 0.001 ether
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == roseProfileId, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Referral_Link_OfferRatios(0, 90, 10)
        //assert balance
        assertEq(jack.balance, 0, "jack balance error");
        assertEq(rose.balance, 0.009 ether, "rose balance error");
        assertEq(address(zeekHub).balance, 0, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.001 ether, "finance balance error");
    }

    function testOfferWish_ReferralWish_bonusIsERC20_withLinker() public createProfile {
        //Referral_Link_OfferRatios(0, 90, 10)
        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Referral, 1 * 10 ** 6, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: rose,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.WishOffered(
            wishId,
            jackProfileId,
            roseProfileId,
            rockProfileId,
            ZeekDataTypes.OfferRatio({
                talent: 0,
                linker: 9 * 10 ** 5,
                platform: 1 * 10 ** 5
            }),
            uint64(block.timestamp),
            uint64(0),
            uint64(block.timestamp)
        );

        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );

        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");
        assertEq(zeekHub.getWishStructFinishTime(wishId), uint64(block.timestamp), "wish finishTime error ");
        //assert offer
        assertEq(zeekHub.getWishStructOffer(wishId).talent == jackProfileId, true, "wish offer talent error ");
        assertEq(zeekHub.getWishStructOffer(wishId).linker == roseProfileId, true, "wish offer linker error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyNonce, 0, "wish offer applyNonce error ");
        assertEq(zeekHub.getWishStructOffer(wishId).applyTime, uint64(block.timestamp), "wish offer applyTime error ");
        assertEq(zeekHub.getWishStructOffer(wishId).timestamp, uint64(block.timestamp), "wish offer timestamp error ");
        //assert wish price
        assertEq(zeekHub.getWishStructPrice(wishId).balance, 0, "wish price balance error ");

        //default Set Referral_Link_OfferRatios(0, 90, 10)
        //assert balance
        assertEq(mockERC20Token.balanceOf(jack) == 0, true, "jack balance error");
        assertEq(mockERC20Token.balanceOf(rose) == 9 * 10 ** 5, true, "rose balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 0, true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == 1 * 10 ** 5, true, "finance balance error");
    }


    function testOfferWish_validateRecoveredAddress_SignatureInvalid() public createProfile {
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.SignatureInvalid.selector);
        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                rosePrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_wishNotExist() public createProfile {
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10)
        //_issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //No wish available
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
        vm.prank(rock);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateWishOwner_msgSender_not_wishOwner() public createProfile {
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.NotWishOwner.selector);
        //rose is not wish:1 owner
        vm.prank(rose);
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateWishState_wishState_Finished() public createProfile {
        vm.deal(jack, 0);

        //directOfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.prank(rock);
        //==>rock offer wish:1 to jack success
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
        assertEq(zeekHub.getWishStructState(wishId) == ZeekDataTypes.WishState.Finished, true, "wish state error ");

        vm.expectRevert(ZeekErrors.InvalidWishState.selector);
        vm.prank(rock);
        //==>rock offer wish:1 to jack fail
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateHasProfile_talentNotHasProfile() public createProfile {
        vm.deal(user, 0);

        //directOfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to user
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: user,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        vm.prank(rock);
        //user not has profile
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                userPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateImproperProfile_ownerCanNotBeTalent() public createProfile {
        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //==>rock offer wish:1 to rock
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: rock,
            linker: address(0),
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //talent is owner
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                rockPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateImproperProfile_linkerNotHasProfile() public createProfile {
        vm.deal(user, 0);
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: user,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        vm.prank(rock);
        //user not has profile
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateImproperProfile_ownerCanNotBeLinker() public createProfile {
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: rock,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //linker is owner
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

    function testOfferWish_validateImproperProfile_talentAndLinkerCanNotBeSame() public createProfile {
        vm.deal(jack, 0);

        //OfferRatio(90, 0, 10);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        //rock offer wish:1 to jack
        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
            wishId: wishId,
            talent: jack,
            linker: jack,
            applyTime: uint64(block.timestamp),
            applyNonce: 0
        });

        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //talent & linker be same
        zeekHub.offerWish(
            wishApplyData,
            _getSigStruct(
                jackPrivateKey,
                _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
                NO_DEADLINE_64
            )
        );
    }

//==>unlock test

    function testUnlockWish_ActiveWish_bonusIsNative_unlockTokenIsNative() public createProfile {
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
    }

    function testUnlockWish_ActiveWish_bonusIsERC20_unlockTokenIsNative() public createProfile {
        vm.deal(rose, 0.001 ether);

        _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 1 * 10 ** 6, true);
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
        //erc20
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == 1 * 10 ** 6, true, "zeekHub balance error");
        //native
        assertEq(rose.balance, 0, "rose balance error");
        assertEq(address(zeekHub).balance, 0.0005 ether, "zeekHub balance error");
        assertEq(zeekHub.getGovernanceStorageFinance().balance, 0.0005 ether, "finance balance error");

        //assert vault
        //rock is wish:1 issuer and owner
        (uint256 rockVault_claimable,uint256 rockVault_claimed,uint64 rockVault_timestamp) = zeekHub.vault(rock, ETH_ADDRESS);
        assertEq(rockVault_claimable, 0.0005 ether, "vault claimable error");
        assertEq(rockVault_claimed, 0, "vault claimable error");
        assertEq(rockVault_timestamp, uint64(block.timestamp), "issuer vault claimable error");
    }

    function testUnlockWish_FinishedWish_bonusIsNative_unlockTokenIsERC20() public createProfile {
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
    }

    function testUnlockWish_FinishedWish_bonusIsERC20_unlockTokenIsERC20() public createProfile {
        mockERC20Token.mint(rose, 1 * 10 ** 5);
        vm.prank(rose);
        mockERC20Token.approve(address(zeekHub), 1 * 10 ** 5);

        uint256 _wishId = _issueWishWithERC20(rock, ZeekDataTypes.WishType.Question, 1 * 10 ** 6, true);
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
        ZeekDataTypes.Unlock memory unlock = zeekHub.getWishUnlock(_wishId, roseProfileId);
        assertEq(unlock.token, mockERC20TokenAddress, "unlock token error");
        assertEq(unlock.tokenVersion, ERC20_VERSION, "unlock tokenVersion error");
        assertEq(unlock.value, unlockValue, "unlock value error");
        assertEq(unlock.timestamp, uint64(block.timestamp), "unlock timestamp error");

        //assert balance
        //native
        //erc20
        assertEq(mockERC20Token.balanceOf(jack) == (9 * 10 ** 5), true, "rose balance error");
        assertEq(mockERC20Token.balanceOf(address(zeekHub)) == (9 * 10 ** 4), true, "zeekHub balance error");
        assertEq(mockERC20Token.balanceOf(zeekHub.getGovernanceStorageFinance()) == (1 * 10 ** 5 + 1 * 10 ** 4), true, "finance balance error");

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
    }


    function testUnlockWish_wishNotExist() public createProfile {
        vm.deal(rose, 0.001 ether);

        //_issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        vm.prank(rose);
        //rose unlock wish:1, wish not exist
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_canNotUnlockPublicWish() public createProfile {
        vm.deal(rose, 0.001 ether);

        //public wish
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, false);

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        vm.expectRevert(ZeekErrors.UnsupportedOperation.selector);
        vm.prank(rose);
        //rose unlock wish:1, wish public
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_validateHasProfile_unlockerNotHasProfile() public createProfile {
        vm.deal(user, 0.001 ether);

        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.001 ether;
        //rock offer wish:1 to jack
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        vm.expectRevert(ZeekErrors.NotHasProfile.selector);
        vm.prank(user);
        //user not has profile
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_canNotRepeatUnlock() public createProfile {
        vm.deal(rose, 0.002 ether);

        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

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
        emit ZeekEvents.WishUnlocked(wishId, roseProfileId, uint64(block.timestamp));
        vm.prank(rose);
        //rose unlock wish:1
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);

        vm.expectRevert(ZeekErrors.WishAlreadyUnlocked.selector);
        vm.prank(rose);
        //rose unlock wish:1, wish already unlocked
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_validateImproperProfile_issuerCannotUnlock() public createProfile {
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //EarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 10, true);
        //EarlyUnlockRatio(10, 40, 50);
        vm.deal(rock, 0.001 ether);
        vm.expectRevert(ZeekErrors.WishInvalidParameter.selector);
        vm.prank(rock);
        //rock is issuer, issuer cannot unlock
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_validateUnlockValue_unlockTokenVersionNotMatch() public createProfile {
        vm.deal(rose, 0.001 ether);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //setting:
        //EarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
        //EarlyUnlockRatio(10, 40, 50);
        vm.expectRevert(ZeekErrors.IncorrectTokenValue.selector);
        vm.prank(rose);
        //data.tokenVersion NotMatch EarlyUnlockTokenVersion
        zeekHub.unlockWish{value: 0.001 ether}(wishUnlockData);
    }

    function testUnlockWish_validateUnlockValue_unlockTokenValueNotMatch() public createProfile {
        vm.deal(rose, 0.005 ether);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.005 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //setting:
        //EarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
        //EarlyUnlockRatio(10, 40, 50);
        vm.expectRevert(ZeekErrors.IncorrectTokenValue.selector);
        vm.prank(rose);
        //data.tokenVersion NotMatch EarlyUnlockTokenVersion
        zeekHub.unlockWish{value: 0.005 ether}(wishUnlockData);
    }

    function testUnlockWish_validateMsgValue_msgValue_notEqualTo_UnlockValue() public createProfile {
        vm.deal(rose, 0.001 ether);
        _issueWishWithNative(rock, ZeekDataTypes.WishType.Question, 0.01 ether, true);

        uint256 unlockValue = 0.001 ether;
        ZeekDataTypes.WishUnlockData memory wishUnlockData = ZeekDataTypes.WishUnlockData({
            wishId: wishId,
            token: ETH_ADDRESS,
            tokenVersion: ETH_VERSION,
            value: unlockValue,
            timestamp: uint64(block.timestamp)
        });

        //setting:
        //EarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.01 ether, true);
        //EarlyUnlockRatio(10, 40, 50);
        vm.expectRevert(ZeekErrors.InsufficientBalance.selector);
        vm.prank(rose);
        //data.tokenVersion NotMatch EarlyUnlockTokenVersion
        zeekHub.unlockWish{value: 0.0005 ether}(wishUnlockData);
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

    function _issueWishWithERC20(address issuer, ZeekDataTypes.WishType wishType, uint256 bonusValue, bool restricted) internal returns (uint256){
        mockERC20Token.mint(issuer, bonusValue);
        vm.prank(issuer);
        mockERC20Token.approve(address(zeekHub), bonusValue);

        ZeekDataTypes.WishIssueData memory data = ZeekDataTypes
            .WishIssueData({
            wishType: wishType,
            restricted: restricted,
            bonus: ZeekDataTypes.TokenValue({
            token: mockERC20TokenAddress,
            tokenVersion: ERC20_VERSION,
            value: bonusValue
        }),
            start: uint64(block.timestamp),
            deadline: uint64(block.timestamp + 3600 * 24 * 30 /*30 day*/),
            salt: block.timestamp
        });

        vm.prank(issuer);
        return wishId = zeekHub.issueWish(data);
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
