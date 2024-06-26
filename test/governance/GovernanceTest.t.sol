// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../ZeekTestSetUp.sol";
import "../MetaTxNegatives.sol";
import "../../contracts/libraries/ZeekErrors.sol";
import "../../contracts/libraries/ZeekDataTypes.sol";

contract GovernanceTest is ZeekTestSetUp, MetaTxNegatives {

    ZeekDataTypes.WishType[] types;
    ZeekDataTypes.OfferRatio[] ratios;

//     function testInitialize() public {

//         string memory contractName = "ZEEK_NAME";
//         string memory  contractSymbol = "ZEEK_SYMBOL";

//         assertEq(zeekHub.getGovernanceStorageName(), contractName, "governance name error");
//         assertEq(zeekHub.getGovernanceStorageSymbol(), contractSymbol, "governance symbol error");
//         assertEq(zeekHub.getGovernanceStorageReviewSBTImpl(), reviewSBTImpl, "governance reviewSBT error");
//         assertEq(zeekHub.getGovernanceStorageBaseURL(), "", "governance baseURI error");
//         assertEq(zeekHub.getGovernanceStorageFinance(), deployer, "governance finance error");

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).talent ,90 , "default Question talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).linker ,0 , "default Question linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).platform , 10 , "default Question platform CommissionRate error");

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).talent ,0 , "default Referral talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).linker ,0 , "default Referral linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).platform , 100 , "default Referral platform CommissionRate error");

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).talent ,0 , "default Bounty talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).linker ,0 , "default Bounty linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).platform , 100 , "default Bounty platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).talent ,90 , "link Question talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).linker ,0 , "link Question linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).platform , 10 , "link Question platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).talent ,0 , "link Referral talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).linker ,90 , "link Referral linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).platform , 10 , "link Referral platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).talent ,0 , "link Bounty talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).linker ,90 , "link Bounty linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).platform , 10 , "link Bounty platform CommissionRate error");

//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Question) == quoraFee, true, "issue fee Question error");
//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Referral) == refferalFee, true, "issue fee Referral error");
//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Bounty) == bountyFee, true, "issue fee Bounty error");

//         assertEq(zeekHub.getWishIssueFeeToken() == ETH_ADDRESS, true, "issue fee token error");
//         assertEq(zeekHub.getWishIssueFeeTokenVersion() == ETH_VERSION, true, "issue fee token version error");
//     }

//     function testCannotInitialize_manyTimes() public {
//         vm.prank(deployer);
//         vm.expectRevert(Initializable.InvalidInitialization.selector);
//         zeekHub.initialize("contractName", "contractSymbol",  reviewSBTImpl);
//     }

//     function testSetFinance() public {
//         address newFinance = makeAddr("newFinance");

//         vm.expectEmit(true, true, false, true);
//         emit ZeekEvents.ZeekFinanceSet(deployer, deployer, newFinance, uint64(block.timestamp));

//         vm.prank(deployer);
//         zeekHub.setFinance(newFinance);

//         assertEq(zeekHub.getGovernanceStorageFinance(), newFinance, "governance finance error");
//     }

//     function testFailSetFinance_msgSenderNotGov() public {
//         address newFinance = makeAddr("newFinance");
//         vm.prank(user);
//         zeekHub.setFinance(newFinance);
//     }

//     function testCannotSetFinance_newFinanceIsAddress0() public {
//         address newFinance = address(0);

//         vm.prank(deployer);
//         vm.expectRevert(ZeekErrors.InvalidAddress.selector);
//         zeekHub.setFinance(newFinance);
//     }

//     function testSetBaseURI() public {
//         string memory newURL = "www.xxx.com";

//         vm.expectEmit(true, true, false, true);
//         emit ZeekEvents.BaseURISet(newURL, uint64(block.timestamp));

//         vm.prank(deployer);
//         zeekHub.setBaseURI(newURL);

//         assertEq(zeekHub.getGovernanceStorageBaseURL(), newURL, "governance baseURI error");
//         assertEq(zeekHub.getBaseURI(), newURL, "governance baseURI error");
//     }

//     function testFailSetBaseURI_msgSenderNotGov() public {
//         string memory newURL = "www.xxx.com";
//         vm.prank(user);
//         zeekHub.setBaseURI(newURL);
//     }

//     function testsetOfferRatiosIssueFees() public {
//         // prepare fee setting
//         vm.startPrank(deployer);
//         zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
//         zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
//         zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ETH_VERSION);
//         vm.stopPrank();

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).talent ,90 , "default Question talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).linker ,0 , "default Question linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Question).platform , 10 , "default Question platform CommissionRate error");

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).talent ,0 , "default Referral talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).linker ,0 , "default Referral linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Referral).platform , 100 , "default Referral platform CommissionRate error");

//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).talent ,0 , "default Bounty talent CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).linker ,0 , "default Bounty linker CommissionRate error");
//         assertEq(zeekHub.getWishCommissionRate(ZeekDataTypes.WishType.Bounty).platform , 100 , "default Bounty platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).talent ,90 , "link Question talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).linker ,0 , "link Question linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Question).platform , 10 , "link Question platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).talent ,0 , "link Referral talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).linker ,90 , "link Referral linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Referral).platform , 10 , "link Referral platform CommissionRate error");

//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).talent ,0 , "link Bounty talent CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).linker ,90 , "link Bounty linker CommissionRate error");
//         assertEq(zeekHub.getWishLinkCommissionRate(ZeekDataTypes.WishType.Bounty).platform , 10 , "link Bounty platform CommissionRate error");

//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Question) == quoraFee, true, "issue fee Question error");
//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Referral) == refferalFee, true, "issue fee Referral error");
//         assertEq(zeekHub.getWishIssueFee(ZeekDataTypes.WishType.Bounty) == bountyFee, true, "issue fee Bounty error");

//         assertEq(zeekHub.getWishIssueFeeToken() == ETH_ADDRESS, true, "issue fee token error");
//         assertEq(zeekHub.getWishIssueFeeTokenVersion() == ETH_VERSION, true, "issue fee token version error");
//     }

//     function testFailsetOfferRatios_msgSenderNotGov() public {
//         // prepare fee setting

//         vm.startPrank(user);
//         zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
//         zeekHub.setOfferRatios(defaultWishTypes, defaultLinkRates);
//         vm.stopPrank();

//     }

//     function testFailSetIssueFees_msgSenderNotGov() public {
//         // prepare fee setting
//         vm.startPrank(user);
//         zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ETH_VERSION);
//         vm.stopPrank();

//     }

//     function testCannotSetIssueFees_token0x00Version20() public {
//         // prepare fee setting
//         vm.prank(deployer);
//         vm.expectRevert(ZeekErrors.InvalidAddress.selector);
//         zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ERC20_VERSION);
//     }

// //    function testCannotSetIssueFees_token0x00Version1() public {
// //        // prepare fee setting
// //        ZeekDataTypes.CommissionType[] memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
// //        commissionTypes[0] = ZeekDataTypes.WishType.Question;
// //        commissionTypes[1] = ZeekDataTypes.WishType.Question;
// //
// //        ZeekDataTypes.CommissionRate[] memory rates = new ZeekDataTypes.CommissionRate[](2);
// //        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
// //        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
// //
// //        ZeekDataTypes.WishType[] memory wishTypes = new ZeekDataTypes.WishType[](2);
// //        wishTypes[0] = ZeekDataTypes.WishType.Bounty;
// //        wishTypes[1] = ZeekDataTypes.WishType.Task;
// //
// //        uint256[] memory amounts = new uint256[](2);
// //        amounts[0] = hiringIssueFee;
// //        amounts[1] = taskIssueFee;
// //
// //        vm.prank(deployer);
// //        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
// //        zeekHub.setIssueFees(wishTypes, amounts, ETH_ADDRESS, 1);
// //    }

//     function testCannotSetIssueFees_tokenErc20Version0() public {
//         // prepare fee setting
//         vm.prank(deployer);
//         vm.expectRevert(ZeekErrors.InvalidAddress.selector);
//         zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, mockERC20TokenAddress, ETH_VERSION);
//     }

// //    function testCannotSetIssueFees_tokenErc20Version1() public {
// //        // prepare fee setting
// //        ZeekDataTypes.CommissionType[] memory commissionTypes = new ZeekDataTypes.CommissionType[](2);
// //        commissionTypes[0] = ZeekDataTypes.WishType.Question;
// //        commissionTypes[1] = ZeekDataTypes.WishType.Question;
// //
// //        ZeekDataTypes.CommissionRate[] memory rates = new ZeekDataTypes.CommissionRate[](2);
// //        rates[0] = ZeekDataTypes.CommissionRate(0, 0, 100);
// //        rates[1] = ZeekDataTypes.CommissionRate(0, 90, 10);
// //
// //        ZeekDataTypes.WishType[] memory wishTypes = new ZeekDataTypes.WishType[](2);
// //        wishTypes[0] = ZeekDataTypes.WishType.Bounty;
// //        wishTypes[1] = ZeekDataTypes.WishType.Task;
// //
// //        uint256[] memory amounts = new uint256[](2);
// //        amounts[0] = hiringIssueFee;
// //        amounts[1] = taskIssueFee;
// //
// //        vm.prank(deployer);
// //        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
// //        zeekHub.setIssueFees(wishTypes, amounts, mockERC20TokenAddress, 1);
// //    }

    function testSetMinimumIssueTokens() public {
        vm.startPrank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishMiniumIssueTokenSet(ETH_ADDRESS, ETH_VERSION, 0.5 ether, true);
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 0.5 ether, true);

        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishMiniumIssueTokenSet(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true);
        vm.stopPrank();

        assertEq(zeekHub.getMinimumIssueTokens(ETH_ADDRESS).token, ETH_ADDRESS, "ETH minimum issue token error");
        assertEq(zeekHub.getMinimumIssueTokens(ETH_ADDRESS).tokenVersion, ETH_VERSION, "ETH minimum issue token version error");
        assertEq(zeekHub.getMinimumIssueTokens(ETH_ADDRESS).value, 0.5 ether, "ETH minimum issue token error");
        assertEq(zeekHub.getMinimumIssueTokens(ETH_ADDRESS).invalid, true, "ETH minimum issue token error");

        assertEq(zeekHub.getMinimumIssueTokens(mockERC20TokenAddress).token, mockERC20TokenAddress, "ERC20 minimum issue token error");
        assertEq(zeekHub.getMinimumIssueTokens(mockERC20TokenAddress).tokenVersion, ERC20_VERSION, "ERC20 minimum issue token version error");
        assertEq(zeekHub.getMinimumIssueTokens(mockERC20TokenAddress).value, 10 * 10 ** 6, "ERC20 minimum issue token error");
        assertEq(zeekHub.getMinimumIssueTokens(mockERC20TokenAddress).invalid, true, "ERC20 minimum issue token error");
    }

    function testSetMinimumIssueTokens_AccessControlUnauthorizedAccount() public {
        vm.expectRevert();
        //vm.prank(deployer);
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 10 * 10 ** 6, true);
    }

    function testSetMinimumIssueTokens_validateTokenValue_tokenNotMatchTokenVersion1() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ERC20_VERSION, 0.5 ether, true);
    }

    function testSetMinimumIssueTokens_validateTokenValue_tokenNotMatchTokenVersion2() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ETH_VERSION, 0.5 ether, true);
    }

    function testSetOfferRatios() public {
        types.push(ZeekDataTypes.WishType.Question);
        types.push(ZeekDataTypes.WishType.Referral);

        ratios.push(ZeekDataTypes.OfferRatio(40, 0, 60)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(100, 0, 0));

        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishOfferRatioSet(ZeekDataTypes.OfferType.Direct, ratios[0], ratios[1]);
        zeekHub.setOfferRatios(types, ratios);

        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).talent, 40, "Question talent CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).linker, 0, "Question linker CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).platform, 60, "Question platform CommissionRate error");

        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).talent, 100, "Referral talent CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).linker, 0, "Referral linker CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).platform, 0, "Referral platform CommissionRate error");
    }

    function testSetOfferRatios_AccessControlUnauthorizedAccount() public {
        types.push(ZeekDataTypes.WishType.Question);
        types.push(ZeekDataTypes.WishType.Referral);

        ratios.push(ZeekDataTypes.OfferRatio(60, 0, 40)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 100));

        vm.expectRevert();
        //update fail
        zeekHub.setOfferRatios(types, ratios);

        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).talent, 90, "Question talent CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).linker, 0, "Question linker CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Question).platform, 10, "Question platform CommissionRate error");

        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).talent, 0, "Referral talent CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).linker, 0, "Referral linker CommissionRate error");
        assertEq(zeekHub.getWishOfferRatio(ZeekDataTypes.WishType.Referral).platform, 100, "Referral platform CommissionRate error");
    }

    function testSetOfferRatios_InvalidParameters_typesLengthNotEqRatiosLength() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(60, 0, 40)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 100));

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setOfferRatios(types, ratios);
    }

    function testSetOfferRatios_InvalidParameters_linkerNotEqZero() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(30, 30, 40)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setOfferRatios(types, ratios);
    }

    function testSetOfferRatios_validateRatio_RatioSumGt100() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(50, 0, 51)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setOfferRatios(types, ratios);
    }

    function testSetOfferRatios_validateRatio_RatioSumLt100() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(50, 0, 49)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setOfferRatios(types, ratios);
    }

    function testSetOfferRatios_validateRatio_RatioSumEqZero() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 0)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setOfferRatios(types, ratios);
    }


    function testSetLinkOfferRatios() public {
        types.push(ZeekDataTypes.WishType.Question);
        types.push(ZeekDataTypes.WishType.Referral);

        ratios.push(ZeekDataTypes.OfferRatio(40, 0, 60)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(30, 30, 40));

        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishOfferRatioSet(ZeekDataTypes.OfferType.Link, ratios[0], ratios[1]);
        zeekHub.setLinkOfferRatios(types, ratios);

        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).talent, 40, "Question talent CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).linker, 0, "Question linker CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).platform, 60, "Question platform CommissionRate error");

        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).talent, 30, "Referral talent CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).linker, 30, "Referral linker CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).platform, 40, "Referral platform CommissionRate error");
    }

    function testSetLinkOfferRatios_AccessControlUnauthorizedAccount() public {
        types.push(ZeekDataTypes.WishType.Question);
        types.push(ZeekDataTypes.WishType.Referral);

        ratios.push(ZeekDataTypes.OfferRatio(60, 0, 40)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 100));

        vm.expectRevert();
        //update fail
        zeekHub.setLinkOfferRatios(types, ratios);

        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).talent, 90, "Question talent CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).linker, 0, "Question linker CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Question).platform, 10, "Question platform CommissionRate error");

        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).talent, 0, "Referral talent CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).linker, 90, "Referral linker CommissionRate error");
        assertEq(zeekHub.getWishLinkOfferRatio(ZeekDataTypes.WishType.Referral).platform, 10, "Referral platform CommissionRate error");
    }

    function testSetLinkOfferRatios_InvalidParameters_typesLengthNotEqRatiosLength() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(60, 0, 40)); // talent linker platform
        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 100));

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setLinkOfferRatios(types, ratios);
    }

    function testSetLinkOfferRatios_validateRatio_RatioSumGt100() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(50, 0, 51)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setLinkOfferRatios(types, ratios);
    }

    function testSetLinkOfferRatios_validateRatio_RatioSumLt100() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(50, 0, 49)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setLinkOfferRatios(types, ratios);
    }

    function testSetLinkOfferRatios_validateRatio_RatioSumEqZero() public {
        types.push(ZeekDataTypes.WishType.Question);

        ratios.push(ZeekDataTypes.OfferRatio(0, 0, 0)); // talent linker platform

        vm.expectRevert();
        vm.prank(deployer);
        //update fail
        zeekHub.setLinkOfferRatios(types, ratios);
    }

    function testSetEarlyUnlockTokens_Native() public {
        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishUnlockTokenSet(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true, true);
        zeekHub.setEarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);

        ZeekDataTypes.TokenValueSet memory token = zeekHub.getWishStorageEarlyUnlockToken(ETH_ADDRESS);
        assertEq(token.tokenVersion, ETH_VERSION, "tokenVersion error");
        assertEq(token.token, ETH_ADDRESS, "token error");
        assertEq(token.invalid, true, "invalid error");
        assertEq(token.value, 0.001 ether, "value error");
    }

    function testSetEarlyUnlockTokens_ERC20() public {
        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishUnlockTokenSet(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true, true);
        zeekHub.setEarlyUnlockTokens(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true);

        ZeekDataTypes.TokenValueSet memory token = zeekHub.getWishStorageEarlyUnlockToken(mockERC20TokenAddress);
        assertEq(token.tokenVersion, ERC20_VERSION, "tokenVersion error");
        assertEq(token.token, mockERC20TokenAddress, "token error");
        assertEq(token.invalid, true, "invalid error");
        assertEq(token.value, 10 * 10 ** 6, "value error");
    }

    function testSetEarlyUnlockTokens_AccessControlUnauthorizedAccount() public {
        vm.expectRevert();
        zeekHub.setEarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
    }

    function testSetEarlyUnlockTokens_tokenNotMatchTokenVersion1() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setEarlyUnlockTokens(mockERC20TokenAddress, ETH_VERSION, 0.001 ether, true);
    }

    function testSetEarlyUnlockTokens_tokenNotMatchTokenVersion2() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setEarlyUnlockTokens(ETH_ADDRESS, ERC20_VERSION, 0.001 ether, true);
    }

    function testSetEarlyUnlockRatio() public {
        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishUnlockRatioSet(30, 30, 0, 40, true);
        zeekHub.setEarlyUnlockRatio(30, 30, 40);

        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().issuer, 30, "issuer error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().owner, 30, "owner error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().platform, 40, "platform error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().talent, 0, "talent error");
    }

    function testSetEarlyUnlockRatio_AccessControlUnauthorizedAccount() public {
        vm.expectRevert();
        zeekHub.setEarlyUnlockRatio(30, 30, 40);

        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().issuer, 10, "issuer error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().owner, 40, "owner error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().platform, 50, "platform error");
        assertEq(zeekHub.getWishStorageEarlyUnlockRatio().talent, 0, "talent error");
    }

    function testSetEarlyUnlockRatio_RatioSumGt100() public {
        vm.expectRevert(ZeekErrors.InvalidParameters.selector);
        vm.prank(deployer);
        zeekHub.setEarlyUnlockRatio(30, 30, 41);
    }

    function testSetEarlyUnlockRatio_RatioSumLt100() public {
        vm.expectRevert(ZeekErrors.InvalidParameters.selector);
        vm.prank(deployer);
        zeekHub.setEarlyUnlockRatio(30, 30, 39);
    }

    function testSetUnlockTokens_native() public {
        vm.prank(deployer);
        zeekHub.setUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);

        ZeekDataTypes.TokenValueSet memory token = zeekHub.getWishStorageUnlockToken(ETH_ADDRESS);
        assertEq(token.tokenVersion, ETH_VERSION, "tokenVersion error");
        assertEq(token.token, ETH_ADDRESS, "token error");
        assertEq(token.invalid, true, "invalid error");
        assertEq(token.value, 0.001 ether, "value error");
    }

    function testSetUnlockTokens_ERC20() public {
        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishUnlockTokenSet(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true, false);
        zeekHub.setUnlockTokens(mockERC20TokenAddress, ERC20_VERSION, 10 * 10 ** 6, true);

        ZeekDataTypes.TokenValueSet memory token = zeekHub.getWishStorageUnlockToken(mockERC20TokenAddress);
        assertEq(token.tokenVersion, ERC20_VERSION, "tokenVersion error");
        assertEq(token.token, mockERC20TokenAddress, "token error");
        assertEq(token.invalid, true, "invalid error");
        assertEq(token.value, 10 * 10 ** 6, "value error");
    }

    function testSetUnlockTokens_AccessControlUnauthorizedAccount() public {
        vm.expectRevert();
        zeekHub.setUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
    }

    function testSetUnlockTokens_tokenNotMatchTokenVersion1() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setUnlockTokens(mockERC20TokenAddress, ETH_VERSION, 0.001 ether, true);
    }

    function testSetUnlockTokens_tokenNotMatchTokenVersion2() public {
        vm.expectRevert(ZeekErrors.InvalidAddress.selector);
        vm.prank(deployer);
        zeekHub.setUnlockTokens(ETH_ADDRESS, ERC20_VERSION, 0.001 ether, true);
    }

    function testSetUnlockRatio() public {
        vm.prank(deployer);
        vm.expectEmit(address(zeekHub));
        emit ZeekEvents.ZeekWishUnlockRatioSet(30, 30, 40, 0, false);
        zeekHub.setUnlockRatio(30, 30, 40, 0);

        assertEq(zeekHub.getWishStorageUnlockRatio().issuer, 30, "issuer error");
        assertEq(zeekHub.getWishStorageUnlockRatio().owner, 30, "owner error");
        assertEq(zeekHub.getWishStorageUnlockRatio().talent, 40, "talent error");
        assertEq(zeekHub.getWishStorageUnlockRatio().platform, 0, "platform error");
    }

    function testSetUnlockRatio_AccessControlUnauthorizedAccount() public {
        vm.expectRevert();
        zeekHub.setUnlockRatio(30, 30, 40, 0);

        assertEq(zeekHub.getWishStorageUnlockRatio().issuer, 10, "issuer error");
        assertEq(zeekHub.getWishStorageUnlockRatio().owner, 40, "owner error");
        assertEq(zeekHub.getWishStorageUnlockRatio().talent, 40, "talent error");
        assertEq(zeekHub.getWishStorageUnlockRatio().platform, 10, "platform error");
    }

    function testSetUnlockRatio_RatioSumGt100() public {
        vm.expectRevert(ZeekErrors.InvalidParameters.selector);
        vm.prank(deployer);
        zeekHub.setUnlockRatio(30, 30, 40, 1);
    }

    function testSetUnlockRatio_RatioSumLt100() public {
        vm.expectRevert(ZeekErrors.InvalidParameters.selector);
        vm.prank(deployer);
        zeekHub.setUnlockRatio(30, 30, 39, 0);
    }


}