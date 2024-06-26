// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import "../contracts/interfaces/IZeekHub.sol";
import "../contracts/upgradeability/ZeekRouter.sol";
import "../contracts/libraries/Constants.sol";
import "../contracts/core/Governance.sol";

contract ZeekSetupScript is Script {
    function setUp() public {}

    function run() public {

        vm.startBroadcast();

        address zeekRouter = vm.envAddress("ZEEK_ROUTER_ADDRESS");

        console2.log("zeekRouter: ", zeekRouter);

        IGovernance zeekHub = IGovernance(payable(zeekRouter));
        ZeekRouter zr = ZeekRouter(payable(zeekRouter));
        console2.log("zeekRouter admin: ", zr.getAdmin());

        // console2.log(zeekHub.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        if (vm.envBool("SET_ROLE")) {
            zeekHub.grantRole(Constants.GOVERANCE_ROLE, vm.envAddress("GOV_ADDR"));
            zeekHub.grantRole(Constants.OPERATION_ROLE, vm.envAddress("OPERATION_ADDR"));
            zeekHub.grantRole(Constants.ZEEK_ROLE, vm.envAddress("ZEEK_ADDR"));
        }
        
        if (vm.envBool("SET_FEE")) {
            console2.log("coming to set fee");
            _setDefaultFees(zr);
        }

        if (vm.envBool("SET_APP_WHITELIST")) {
            console2.log("coming to set wish ext");
            zeekHub.whitelistApp(vm.envAddress("WISH_EXT_ADDRESS"), true);
        }

        if (vm.envBool("SET_FINANCE")) {
            console2.log("coming to set finance addr");
            zeekHub.setFinance(vm.envAddress("FINANCE_ADDR"));
        }

        vm.stopBroadcast();

    }

    function _setDefaultFees(ZeekRouter zeekRouter) internal {
        // prepare fee setting
        ZeekDataTypes.OfferType[] memory oTypes = new ZeekDataTypes.OfferType[](2);
        oTypes[0] = ZeekDataTypes.OfferType.Direct;
        oTypes[1] = ZeekDataTypes.OfferType.Link;

        // wish types
        ZeekDataTypes.WishType[] memory wishTypes = new ZeekDataTypes.WishType[](2);
        wishTypes[0]=ZeekDataTypes.WishType.Question;
        wishTypes[1]=ZeekDataTypes.WishType.Referral;

        ZeekDataTypes.OfferRatio[] memory linkRatios = new ZeekDataTypes.OfferRatio[](2);
        // linker case
        linkRatios[0] = ZeekDataTypes.OfferRatio(90, 0, 10);
        linkRatios[1] = ZeekDataTypes.OfferRatio(0, 90, 10);
        
        ZeekDataTypes.OfferRatio[] memory ratios = new ZeekDataTypes.OfferRatio[](2);
        // direct case
        ratios[0] = ZeekDataTypes.OfferRatio(90, 0, 10);
        ratios[1] = ZeekDataTypes.OfferRatio(0, 0, 100);

        bytes[] memory setCallDatas = new bytes[](9);
        
        uint256 y = 0;
        setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setOfferRatios.selector, wishTypes, ratios);
        setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setLinkOfferRatios.selector, wishTypes, linkRatios);
        
        if (vm.envBool("ENABLE_USDT")) {
            address usdtAddr = vm.envAddress("USDT_ADDR");
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setMinimumIssueTokens.selector, usdtAddr, 20, 10 * 10**6, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setEarlyUnlockTokens.selector, usdtAddr, 20, 5 * 10**5, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setUnlockTokens.selector, usdtAddr, 20, 10**6, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setCutDecimals.selector, usdtAddr, 4);
        }
        
        if (vm.envBool("ENABLE_USDC")) {
            address usdcAddr = vm.envAddress("USDC_ADDR");
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setMinimumIssueTokens.selector, usdcAddr, 20, 10 * 10**6, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setEarlyUnlockTokens.selector, usdcAddr, 20, 0.5 * 10**6, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setUnlockTokens.selector, usdcAddr, 20, 10**6, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setCutDecimals.selector, usdcAddr, 4);
        }
        
        if (vm.envBool("ENABLE_NATIVE")) {
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setMinimumIssueTokens.selector, address(0), 0, 0.0001 ether, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setEarlyUnlockTokens.selector, address(0), 0, 0.0000005 ether, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setUnlockTokens.selector, address(0), 0, 0.000001 ether, true);
            setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setCutDecimals.selector, address(0), 10);
        }
        
        setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setEarlyUnlockRatio.selector, 10, 40, 50);
        setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setUnlockRatio.selector, 10, 40, 40, 10);
        setCallDatas[y++] = abi.encodeWithSelector(IGovernance.setBidRatio.selector, 10, 5, 1, 4);

        zeekRouter.multicall(setCallDatas);

    }


}
