//
//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.18;
//
//import "../ZeekTestSetUp.sol";
//import "../MetaTxNegatives.sol";
//import "../../contracts/libraries/ZeekErrors.sol";
//import "../../contracts/libraries/ZeekDataTypes.sol";
//
//contract ZeekRouterTest is ZeekTestSetUp, MetaTxNegatives{
//
//    function testCannotAddRouter_addOneManyTimes() public {
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: router exists for function."));
//        zeekRouter.addRouter(
//            IRouter.Router(hex'7220a32f', 'getWishStructStart(uint256)', address(wish))
//        );
//    }
//
//    function testCannotAddRouter_sigNotMatchSelector() public {
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: fn selector and signature mismatch."));
//        zeekRouter.addRouter(
//            IRouter.Router(
//                hex'6c79572a',
//                'acceptWishApply123((uint256,address,address,uint64))',
//                address(wish)
//            )
//        );
//    }
//
//    function testCannotAddRouter_notAdmin() public {
//        vm.prank(user);
//        vm.expectRevert(bytes("Router: Not authorized."));
//        zeekRouter.addRouter(
//            IRouter.Router(hex'400ed809', 'grantRoleForTest(bytes32,address)', address(governance))
//        );
//    }
//
////    function testUpdateRouter() public {
////        vm.expectEmit(true, true, true, true);
////        emit IRouter.RouterUpdated(hex'679245c2', address(governance), address(1));
////
////        vm.prank(deployer);
////        zeekRouter.updateRouter(
////            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol()', address(1))
////        );
////
////        assertEq(address(1) == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "router error");
////    }
//
//    function testCannotUpdateRouter_notAddFun() public {
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: No router available for selector."));
//        zeekRouter.updateRouter(
//            IRouter.Router(hex'400ed809', 'grantRoleForTest(bytes32,address)', address(governance))
//        );
//    }
//
//    function testCannotUpdateRouter_sigNotMatchSelector() public {
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: fn selector and signature mismatch."));
//        zeekRouter.updateRouter(
//            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol123()', address(1))
//        );
//    }
//
//    function testUpdateRouter_manyTimes() public {
//        vm.expectEmit(true, true, true, true);
//        emit IRouter.RouterUpdated(hex'679245c2', address(governance), address(1));
//
//        vm.prank(deployer);
//        zeekRouter.updateRouter(
//            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol()', address(1))
//        );
//
//        assertEq(address(1) == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "router error");
//
//        vm.expectEmit(true, true, true, true);
//        emit IRouter.RouterUpdated(hex'679245c2', address(1), address(2));
//
//        vm.prank(deployer);
//        zeekRouter.updateRouter(
//            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol()', address(2))
//        );
//
//        assertEq(address(2) == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "router error");
//    }
//
//    function testUpdateRouter_notAdmin() public {
//        vm.prank(user);
//        vm.expectRevert(bytes("Router: Not authorized."));
//        zeekRouter.updateRouter(
//            IRouter.Router(hex'679245c2', 'getGovernanceStorageSymbol()', address(1))
//        );
//    }
//
//    function testRemoveRouter() public {
//        assertEq(governanceTestHandleAddress == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "exist error");
//        vm.expectEmit(true, true, true, true);
//        emit IRouter.RouterRemoved(hex'679245c2', governanceTestHandleAddress);
//
//        vm.prank(deployer);
//        zeekRouter.removeRouter(
//            hex'679245c2', 'getGovernanceStorageSymbol()'
//        );
//
//        assertEq(address(0) == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "exist error");
//    }
//
//    function testCannotRemoveRouter_notAdd() public {
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: No router available for selector."));
//        zeekRouter.removeRouter(
//            hex'400ed809', 'grantRoleForTest(bytes32,address)'
//        );
//
//    }
//
//    function testCannotRemoveRouter_sigNotMatchSelector() public {
//
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: fn selector and signature mismatch."));
//        zeekRouter.removeRouter(
//            hex'679245c2', 'getGovernanceStorageSymbol123()'
//        );
//
//    }
//
//    function testCannotRemoveRouter_manyTimes() public {
//        assertEq(governanceTestHandleAddress == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "exist error");
//
//        vm.prank(deployer);
//        zeekRouter.removeRouter(
//            hex'679245c2', 'getGovernanceStorageSymbol()'
//        );
//
//        assertEq(address(0) == zeekRouter.getRouterForFunction(hex'679245c2'),true,  "exist error");
//
//        vm.prank(deployer);
//        vm.expectRevert(bytes("Router: No router available for selector."));
//        zeekRouter.removeRouter(
//            hex'679245c2', 'getGovernanceStorageSymbol()'
//        );
//    }
//
//    function testCannotRemoveRouter_notAdmin() public {
//        vm.prank(user);
//        vm.expectRevert(bytes("Router: Not authorized."));
//        zeekRouter.removeRouter(
//            hex'679245c2', 'getGovernanceStorageSymbol()'
//        );
//    }
//
//    function testChangeAdmin() public {
//
//        vm.expectEmit(true, true, true, true);
//        emit ZeekRouter.AdminChanged(deployer, user);
//
//        vm.prank(deployer);
//        zeekRouter.changeAdmin(user);
//
//
//    }
//
//    function testCannotChangeAdmin_newAdminIsAddress0() public {
//        vm.prank(deployer);
//        vm.expectRevert();
//        zeekRouter.changeAdmin(address(0));
//    }
//
//    function testCannotChangeAdmin_notAdmin() public {
//        vm.prank(user);
//        vm.expectRevert(bytes("Router: Not authorized."));
//        zeekRouter.changeAdmin(user);
//    }
//}