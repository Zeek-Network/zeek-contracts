//// SPDX-License-Identifier: MIT
//pragma solidity 0.8.20;
//
//import "../ZeekTestSetUp.sol";
//import "../MetaTxNegatives.sol";
//import "../../contracts/libraries/ZeekErrors.sol";
//import "../../contracts/libraries/ZeekEvents.sol";
//import "../../contracts/libraries/ZeekDataTypes.sol";
//import "../../contracts/base/EIP712Base.sol";
//
//
//contract Eip712Test is ZeekTestSetUp, MetaTxNegatives{
//
//    function testValidateRecoveredAddress() public {
//
////        vm.startPrank(rock);
////        ZeekDataTypes.WishApplyData memory wishApplyData = ZeekDataTypes.WishApplyData({
////            wishId: 1,
////            talent: rose,
////            linker: jack,
////            applyTime: uint64(block.timestamp)
////        });
////
////        ZeekDataTypes.EIP712Signature memory sig = _getSigStruct(
////            rosePrivateKey,
////            _getOfferTypedDataHash(wishApplyData, NO_DEADLINE_64),
////            NO_DEADLINE_64
////        );
////
////        zeekHub.offerWish(
////            wishApplyData,
////            sig
////        );
////        vm.stopPrank();
//
//    }
//
//
//}
