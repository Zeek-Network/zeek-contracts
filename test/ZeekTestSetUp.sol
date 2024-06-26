// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import 'forge-std/Test.sol';
import './ZeekTestConstant.sol';
import './MetaTxNegatives.sol';
import './mocks/MockERC20.sol';
import '../contracts/upgradeability/IRouter.sol';
import '../contracts/upgradeability/ZeekRouter.sol';
import './WishTestHandle.sol';
import './GovernanceTestHandle.sol';
import './ProfileTestHandle.sol';
import './interfaces/IZeekTest.sol';
import '../contracts/libraries/ZeekDataTypes.sol';

contract ZeekTestSetUp is Test, ZeekTestConstant {
    address sbt = 0xe7bcb2C7Cf0B4FDdB62FB3dd7c55fb04c74aEA42;

    address deployer;
    uint256 deployerPrivateKey;

    IZeekTest public zeekHub;
    address zeekHubAddress;

    MetaTxNegatives public mtn;
    address mtnAddress;

    ZeekDataTypes.TokenValue public issueFee;

    ZeekRouter zeekRouter;
    address zeekRouterAddress;

    WishTestHandle wish;
    GovernanceTestHandle governance;
    ProfileTestHandle profile;

    address wishTestHandleAddress;
    address governanceTestHandleAddress;
    address profileTestHandleAddress;

    uint256 public wishId;

    uint256 public constant WEEK = 3600 * 24 * 7;
    uint256 public constant TWO_MONTH = 3600 * 24 * 30 * 2;
    uint256 public constant MONTH = 3600 * 24 * 30;

    uint256 rockProfileId;
    uint256 roseProfileId;
    uint256 jackProfileId;
    uint256 bobProfileId;
    uint256 aliceProfileId;

    address zeek;
    uint256 zeekPrivateKey;
    address gov;

    address rock;
    address rose;
    address jack;
    address bob;
    address alice;
    uint256 rockPrivateKey;
    uint256 rosePrivateKey;
    uint256 jackPrivateKey;
    uint256 bobPrivateKey;
    uint256 alicePrivateKey;

    address user;
    uint256 userPrivateKey;

    uint256 quoraFee = 3e16;
    uint256 refferalFee = 3e16;
    uint256 bountyFee = 3e16;

    uint256[] defaultIssueFees;
    ZeekDataTypes.WishType[] defaultWishTypes;
    // TODO Copying of type struct ZeekDataTypes.CommissionRate memory[] memory to storage not yet supported.
    ZeekDataTypes.OfferRatio[] defaultLinkRates;
    ZeekDataTypes.OfferRatio[] defaultRates;

    MockERC20 mockERC20Token;
    address mockERC20TokenAddress;

    function setUp() public {
        (deployer, deployerPrivateKey) = makeAddrAndKey('deployer');

        vm.startPrank(deployer);
        wish = new WishTestHandle();
        governance = new GovernanceTestHandle();
        profile = new ProfileTestHandle(address(governance));

        wishTestHandleAddress = address(wish);
        governanceTestHandleAddress = address(governance);
        profileTestHandleAddress = address(profile);

        zeekRouter = new ZeekRouter(deployer);
        zeekRouterAddress = address(zeekRouter);

        initRouter();

        zeekHub = IZeekTest(zeekRouterAddress);

        IGovernance(payable(zeekRouterAddress)).initialize(
            contractName,
            contractSymbol
        );

        vm.deal(profileTestHandleAddress, INIT_BALANCE);
        vm.deal(governanceTestHandleAddress, INIT_BALANCE);

        console2.log(zeekRouterAddress);
        IGovernance(payable(zeekRouterAddress)).grantRole(Constants.GOVERANCE_ROLE, deployer);
        IGovernance(payable(zeekRouterAddress)).grantRole(Constants.ZEEK_ROLE, deployer);

        governance.grantRoleForTest(Constants.ZEEK_ROLE, deployer);
        governance.grantRoleForTest(Constants.GOVERANCE_ROLE, deployer);
        //        mtn = new MetaTxNegatives();
        //        mtnAddress = address(mtn);

        // ERC20 mint
        mockERC20Token = new MockERC20();
        mockERC20TokenAddress = address(mockERC20Token);

//        initFees();
//        vm.stopPrank();

        // create user
        (rock, rockPrivateKey) = makeAddrAndKey('rock');
        (rose, rosePrivateKey) = makeAddrAndKey('rose');
        (jack, jackPrivateKey) = makeAddrAndKey('jack');
        (bob, bobPrivateKey) = makeAddrAndKey('bob');
        (alice, alicePrivateKey) = makeAddrAndKey('alice');
        (user, userPrivateKey) = makeAddrAndKey('user');

        vm.deal(rock, INIT_BALANCE);
        vm.deal(rose, INIT_BALANCE);
        vm.deal(jack, INIT_BALANCE);
        vm.deal(bob, INIT_BALANCE);
        vm.deal(alice, INIT_BALANCE);
        vm.deal(user, INIT_BALANCE);



//        mockERC20Token.mint(rock, 10e18);
//        mockERC20Token.mint(rose, 10e18);
//        mockERC20Token.mint(jack, 10e18);

//        vm.prank(rock);
//        mockERC20Token.approve(address(zeekHub), 10e18);
//        vm.prank(rose);
//        mockERC20Token.approve(address(zeekHub), 10e18);
//        vm.prank(jack);
//        mockERC20Token.approve(address(zeekHub), 10e18);

        vm.startPrank(deployer);
        initFees();
        vm.stopPrank();

        console.log('deployer: ', deployer);
        console.log('setUp msg.sender', msg.sender);
        console.log('setUp address(this)', address(this));
        console.log();
        console.log('wishTestHandleAddress: ', wishTestHandleAddress);
        console.log('governanceTestHandleAddress: ', governanceTestHandleAddress);
        console.log('profileTestHandleAddress: ', profileTestHandleAddress);
        console.log('zeekRouterAddress: ', zeekRouterAddress);
        console.log();
        console.log('rock: ', rock);
        console.log('rose: ', rose);
        console.log('jack: ', jack);
        console.log('bob: ', bob);
        console.log('alice: ', alice);
        console.log('mockERC20TokenAddress: ', mockERC20TokenAddress);
        console.log();
    }

    modifier createProfile() {
        //console2.log("createProfile...");
        vm.prank(rock);
        rockProfileId = zeekHub.createProfile(0);
        console2.log('rockProfileId', rockProfileId);
        assert(rockProfileId > 0);

        vm.prank(rose);
        roseProfileId = zeekHub.createProfile(0);
        console2.log('roseProfileId', roseProfileId);
        assert(roseProfileId > 0);

        vm.prank(jack);
        jackProfileId = zeekHub.createProfile(0);
        console2.log('jackProfileId', jackProfileId);
        assert(jackProfileId > 0);

        vm.prank(bob);
        bobProfileId = zeekHub.createProfile(0);
        console2.log('bobProfileId', bobProfileId);
        assert(bobProfileId > 0);

        vm.prank(alice);
        aliceProfileId = zeekHub.createProfile(0);
        console2.log('aliceProfileId', aliceProfileId);
        assert(aliceProfileId > 0);

        _;
    }

    modifier forRock() {
        vm.startPrank(rock);
        _;
        vm.stopPrank();
    }

    modifier forRose() {
        vm.startPrank(rose);
        _;
        vm.stopPrank();
    }

    modifier forDepolyer() {
        vm.startPrank(deployer);
        _;
        vm.stopPrank();
    }

    modifier dealBalance() {
        vm.deal(deployer, INIT_BALANCE);
        vm.deal(address(zeekHub), INIT_BALANCE);

        mockERC20Token.mint(deployer, INIT_BALANCE);
        mockERC20Token.mint(address(zeekHub), INIT_BALANCE);
        _;
    }

    function initRouter() private {
        //addRouter
        zeekRouter.addRouter(
            IRouter.Router(hex'077f224a', 'initialize(string,string,address)', address(governance))
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'a0cce639',
                functionSignature: 'setCutDecimals(address,uint256)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'9b8d3064', 'setFinance(address)', address(governance))
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'55f804b3', 'setBaseURI(string)', address(governance))
        );

        zeekRouter.addRouter(IRouter.Router(hex'714c5398', 'getBaseURI()', address(governance)));

        zeekRouter.addRouter(
            IRouter.Router(
            //hex'fb1d9354',
                hex'bff5b2e3',
                'setOfferRatios(uint8[],(uint256,uint256,uint256)[])',
                address(governance)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router(
            //hex'8b140e60',
                hex'76e8651b',
                'setLinkOfferRatios(uint8[],(uint256,uint256,uint256)[])',
                address(governance)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'ad36b68a',
                functionSignature: 'setMinimumIssueTokens(address,uint256,uint256,bool)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'aaa24b20',
                functionSignature: 'setEarlyUnlockRatio(uint256,uint256,uint256)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'448952c4',
                functionSignature: 'setUnlockRatio(uint256,uint256,uint256,uint256)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'85272709',
                functionSignature: 'setBidRatio(uint256,uint256,uint256,uint256)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'6b793add',
                functionSignature: 'setEarlyUnlockTokens(address,uint256,uint256,bool)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'8d64e1dd',
                functionSignature: 'setUnlockTokens(address,uint256,uint256,bool)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'5b61491f',
                functionSignature: 'whitelistApp(address,bool)',
                routerAddress: address(governance)
            })
        );

        zeekRouter.addRouter(IRouter.Router(hex'84b0196e', 'eip712Domain()', address(governance)));

        zeekRouter.addRouter(
            IRouter.Router(hex'2f2ff15d', 'grantRole(bytes32,address)', address(governance))
        );


        zeekRouter.addRouter(
            IRouter.Router(hex'33bc3ccf', 'createProfile(uint256)', address(profile))
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'f08f4f64', 'getProfile(uint256)', address(profile))
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'4cd6959c', 'getProfileByAddress(address)', address(profile))
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'1b54cc88',
                functionSignature: 'vault(address,address)',
                routerAddress: address(profile)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'1e83409a',
                functionSignature: 'claim(address)',
                routerAddress: address(profile)
            })
        );

        zeekRouter.addRouter(IRouter.Router(hex'7ecebe00', 'nonces(address)', address(profile)));


        zeekRouter.addRouter(
            IRouter.Router(hex'44cc7d0b', 'getReviewURI(uint256,uint256)', address(profile))
        );
//==>
        console2.log(address(wish));
        zeekRouter.addRouter(
            IRouter.Router(
                hex'ca745f7f',
                'issueWish((uint8,bool,(address,uint256,uint256),uint64,uint64,uint256))',
                address(wish)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router(
                hex'e07e360a',
                'issueWishPlug((uint8,bool,(address,uint256,uint256),uint64,uint64,uint256),address)',
                address(wish)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'e152bcfb',
                functionSignature: 'bidWish((uint256))',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'85bd7ebd',
                functionSignature: 'cutWish((uint256,uint256))',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'06c5399f',
                functionSignature: 'askWish((uint256))',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router(
                hex'48e2b8be',
                'offerWish((uint256,address,address,uint64,uint256),(bytes,uint64))',
                address(wish)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2bb985ba',
                functionSignature: 'unlockWish((uint256,address,uint256,uint256,uint64))',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(IRouter.Router(hex'b55fec59', 'refundWish((uint256))', address(wish)));

        zeekRouter.addRouter(
            IRouter.Router(hex'f83c213a', 'modifyWish((uint256,uint256,uint64))', address(wish))
        );

        zeekRouter.addRouter(IRouter.Router(hex'202cbac2', 'getWish(uint256)', address(wish)));

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'baea7a77',
                functionSignature: 'offerRatios(uint256)',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'cb67f948',
                functionSignature: 'unlockTokens(address)',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'363c354f',
                functionSignature: 'unlockRatios()',
                routerAddress: address(wish)
            })
        );

        zeekRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2248357d',
                functionSignature: 'bidRatio()',
                routerAddress: address(wish)
            })
        );

        // ===========================================================================================

        zeekRouter.addRouter(
            IRouter.Router(
                hex'b24ea6a9',
                'calculateWishFeeSharing(uint256,bool)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'f713cacb',
                'calculateQuestionFeeSharing(uint256,bool)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'18a5e907',
                'calculateWishFeeWhenDirectToPlatformAndLinker(uint256)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'c9fc9293', 'deleteProfileByAddress(address)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'64df39bb',
                'estimateFeeUseForTest(uint64,uint64,uint8)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'613ac1e7', 'getGovernanceStorageBaseURL()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'74175ca8', 'getGovernanceStorageFinance()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'c3a8f0f7', 'getGovernanceStorageName()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'3abdcd78', 'getWishStorageEarlyUnlockToken(address)', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'1ccb5c68', 'getWishStorageUnlockToken(address)', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'd445b25b', 'getWishStorageEarlyUnlockRatio()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'fbffae59', 'getWishStorageUnlockRatio()', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'cd4b9195', 'getMinimumIssueTokens(address)', address(governance))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'b49e66ee', 'getProfileAllTokens()', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'7b702baf',
                'getProfileConnection(uint256,uint256)',
                address(profile)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'0252c9a2', 'getProfileCounter()', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'4a3b47dc', 'getProfileEvaluateTimeById(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'4af1dc7a', 'getProfileIdByAddress(address)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'b12ec22b', 'getProfileIdByLinkCodeHash(bytes32)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'52ccc0e5', 'getProfileLinkCodeById(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'a5a7606a', 'getProfileOwnerById(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'c911ab2c',
                'getProfileReviewByIdAndReviewId(uint256,uint256)',
                address(profile)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'5857e106',
                'getProfileVaults(uint256,address)',
                address(profile)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router(
                hex'd43932dc',
                'getProfileVaultTokens(uint256)',
                address(profile)
            )
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'31fc83b4', 'getProfileReviewSBTById(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'ae93ddd9', 'getProfileTimestampById(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'b7b04c1a', 'getProfileTokenByIndex(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'7f42fc64', 'getWishCommissionRate(uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'6e7b02f8', 'getWishLinkCommissionRate(uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'817a4a5b', 'getWishHistorySalt(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'e4a9383f', 'getWishStructIssuer(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'133a9099', 'getWishIssueFee(uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'698285f6', 'getWishIssueFeeToken()', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'd7ca7554', 'getWishIssueFeeTokenVersion()', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'0b2bd606', 'getWishStructBalance(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'6b433553',
                'getWishStructCandidatesTalent(uint256,uint256)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'54617608',
                'getWishStructCommissionRate(uint256,uint8)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'493c6ef8', 'getWishStructDeadline(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'8c440390', 'getWishStructFeePerMonth(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'82059efd', 'getWishStructFeeToken(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'e0332f90',
                'getWishStructFeeTokenVersion(uint256)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'c948662b', 'getWishStructLastModifyTime(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'72178c31',
                'getWishStructLinkCode(uint256,uint256)',
                address(wish)
            )
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'714e47ab', 'getWishStructOffer(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'9279fe0a', 'getWishStructOwner(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'7220a32f', 'getWishStructStart(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'1d4bc087', 'getWishStructState(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'5945f7a4', 'getWishStructTimestamp(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'294fc313', 'getWishStructToken(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'5fcdb277', 'getWishStructTokenVersion(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'00257852', 'getWishStructWishType(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'5fe5f67a', 'getWishOfferRatio(uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'b1257c02', 'getWishLinkOfferRatio(uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'f9af19cc', 'getWishUnlock(uint256,uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'e8907ba4', 'getWishStructPrice(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'0a54ef1a', 'getWishStructRestricted(uint256)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'44486100', 'getWishStructOfferRatio(uint256,uint8)', address(wish))
        );
        zeekRouter.addRouter(
            IRouter.Router(hex'3c9ad422', 'getWishStructFinishTime(uint256)', address(wish))
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'bf995ed2', 'getWishStructTokenValue(uint256)', address(wish))
        );

        zeekRouter.addRouter(
            IRouter.Router(hex'ebe7ac54', 'setProfileCounter(uint256)', address(profile))
        );
        zeekRouter.addRouter(
            IRouter.Router(
                hex'a1dc38ff',
                'setWishStructCandidatesApproveTime(uint256,uint256,uint64)',
                address(wish)
            )
        );
        //addRouter
    }

    // modifier estimateFeeOneWeek() {
    //     //console2.log("estimateFeeOneWeek...");
    //     issueFee = zeekHub
    //         .estimateFee(
    //             uint64(block.timestamp),
    //             uint64(block.timestamp + WEEK),
    //             ZeekDataTypes.WishType.Bounty
    //         )
    //         .fee;
    //     _;
    // }

    // modifier estimateFeeTwoMonth() {
    //     issueFee = zeekHub
    //         .estimateFee(
    //             uint64(block.timestamp),
    //             uint64(block.timestamp + TWO_MONTH),
    //             ZeekDataTypes.WishType.Bounty
    //         )
    //         .fee;
    //     _;
    // }

//     modifier estimateFeeWithTime(uint time) {
//         issueFee = zeekHub
//             .estimateFeeUseForTest(
//                 uint64(block.timestamp),
//                 uint64(block.timestamp + time),
//                 ZeekDataTypes.WishType.Bounty
//             )
//             .fee;
//         _;
//
//         console.log('issueFee', issueFee.value);
//     }

    // modifier estimateFeeWithStartEnd(uint start, uint end) {
    //     issueFee = zeekHub
    //         .estimateFeeUseForTest(uint64(start), uint64(end), ZeekDataTypes.WishType.Bounty)
    //         .fee;
    //     _;

    //     console.log('issueFee', issueFee.value);
    // }

    function initFees() internal {
        defaultIssueFees.push(quoraFee);
        defaultIssueFees.push(refferalFee);
        defaultIssueFees.push(bountyFee);

        defaultWishTypes.push(ZeekDataTypes.WishType.Question);
        defaultWishTypes.push(ZeekDataTypes.WishType.Referral);
        // defaultWishTypes.push(ZeekDataTypes.WishType.Bounty);

        defaultLinkRates.push(ZeekDataTypes.OfferRatio(90, 0, 10)); // talent linker platform
        //        defaultLinkRates.push(ZeekDataTypes.CommissionRate(0, 90, 10)); // talent linker platform
        defaultLinkRates.push(ZeekDataTypes.OfferRatio(0, 90, 10));
        // defaultLinkRates.push(ZeekDataTypes.CommissionRate(0, 90, 10));

        defaultRates.push(ZeekDataTypes.OfferRatio(90, 0, 10)); // talent linker platform
        //        defaultRates.push(ZeekDataTypes.CommissionRate(0, 0, 100)); // talent linker platform
        defaultRates.push(ZeekDataTypes.OfferRatio(0, 0, 100));
        // defaultRates.push(ZeekDataTypes.CommissionRate(0, 0, 100));

        zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ETH_VERSION);

        //Set Minimum Issue Tokens
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 0.01 ether, true);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ERC20_VERSION, 1 * 10 ** 6, true);

        /*
        zeekHub.setMinimumIssueTokens(ETH_ADDRESS, ETH_VERSION, 100, true);
        zeekHub.setMinimumIssueTokens(mockERC20TokenAddress, ERC20_VERSION, 100, true);
        */

        //unlock setting
        zeekHub.setEarlyUnlockTokens(ETH_ADDRESS, ETH_VERSION, 0.001 ether, true);
        zeekHub.setEarlyUnlockRatio(10, 40, 50);

        zeekHub.setUnlockTokens(mockERC20TokenAddress, ERC20_VERSION, 1 * 10 ** 5, true);
        zeekHub.setUnlockRatio(10, 40, 40, 10);

        zeekHub.setBidRatio(10, 4, 4, 2);
    }

    // ############################ bounty modifier ############################

    modifier wishInitializeFeeTokenETH() {
        //console2.log("wishInitializeFeeTokenETH...");

        // prepare fee setting
        vm.startPrank(deployer);
        console.log('address(zeekHub)', address(zeekHub));
        // zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, address(0), 0);
        // zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ETH_VERSION);
        vm.stopPrank();

        //zeekHub.initializeWish(commissionTypes, rates, wishTypes, amounts, ETH_ADDRESS, ETH_VERSION);
        _;
    }

    modifier wishInitializeFeeTokenERC20() {
        //console2.log("wishInitializeFeeTokenETH...");

        // prepare fee setting
        vm.startPrank(deployer);
        zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(
        //     defaultWishTypes,
        //     defaultIssueFees,
        //     mockERC20TokenAddress,
        //     ERC20_VERSION
        // );
        vm.stopPrank();

        //zeekHub.initializeWish(commissionTypes, rates, wishTypes, amounts, ETH_ADDRESS, ETH_VERSION);
        _;
    }

    modifier wishInitializeTokenERC20Version0() {
        //console2.log("wishInitializeFeeTokenETH...");

        // prepare fee setting
        vm.startPrank(deployer);
        console.log('address(zeekHub)', address(zeekHub));
        zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(
        //     defaultWishTypes,
        //     defaultIssueFees,
        //     mockERC20TokenAddress,
        //     ETH_VERSION
        // );
        vm.stopPrank();

        //zeekHub.initializeWish(commissionTypes, rates, wishTypes, amounts, ETH_ADDRESS, ETH_VERSION);
        _;
    }

    modifier wishInitializeTokenERC20Version20() {
        //console2.log("wishInitializeFeeTokenETH...");

        // prepare fee setting
        vm.startPrank(deployer);
        console.log('address(zeekHub)', address(zeekHub));
        zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(
        //     defaultWishTypes,
        //     defaultIssueFees,
        //     mockERC20TokenAddress,
        //     ERC20_VERSION
        // );
        vm.stopPrank();

        //zeekHub.initializeWish(commissionTypes, rates, wishTypes, amounts, ETH_ADDRESS, ETH_VERSION);
        _;
    }

    modifier wishInitializeTokenETHVersion0() {
        //console2.log("wishInitializeFeeTokenETH...");

        // prepare fee setting
        vm.startPrank(deployer);
        console.log('address(zeekHub)', address(zeekHub));
        zeekHub.setOfferRatios(defaultWishTypes, defaultRates);
        zeekHub.setLinkOfferRatios(defaultWishTypes, defaultLinkRates);
        // zeekHub.setIssueFees(defaultWishTypes, defaultIssueFees, ETH_ADDRESS, ETH_VERSION);
        vm.stopPrank();

        //zeekHub.initializeWish(commissionTypes, rates, wishTypes, amounts, ETH_ADDRESS, ETH_VERSION);
        _;
    }

}
