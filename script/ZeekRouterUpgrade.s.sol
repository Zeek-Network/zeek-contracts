// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../contracts/upgradeability/ZeekRouter.sol";
import "./BaseScript.sol";

contract ZeekRouterUpdateScript is BaseScript {

    mapping(string => address) contractsMap;
    mapping(string => uint) addFunctions;

    function setUp() public {}

    function run() public returns (ZeekRouter) {
        vm.startBroadcast();

        Governance governance = new Governance();
        contractsMap[GOVERNANCE] = address(governance);
        Profile profile = new Profile(address(vm.envAddress("ZEEK_ROUTER_ADDRESS")));
        contractsMap[PROFILE] = address(profile);
        Wish wish = new Wish();
        contractsMap[WISH] = address(wish);

        bytes[] memory routerCallData = new bytes[](100);
        uint256 y;
        _buildRouterChanges();
        for (uint256 i; i < CONTRACTS.length; i++) {
            IRouter.Router[] memory routers = _buildRouter(CONTRACTS[i], contractsMap[CONTRACTS[i]]);
            for (uint256 j; j < routers.length; j++) {
                bytes32 rt = keccak256(_getRouterChange(routers[j].functionSignature));
                if (rt == keccak256(ROUTER_ADD)) {
                    routerCallData[y] = abi.encodeWithSelector(ZeekRouter.addRouter.selector, routers[j]);
                } else if (rt == keccak256(ROUTER_REMOVE)) {
                    routerCallData[y] = abi.encodeWithSelector(ZeekRouter.removeRouter.selector, routers[j]);
                } else {
                    routerCallData[y] = abi.encodeWithSelector(ZeekRouter.updateRouter.selector, routers[j]);
                }
                unchecked {
                    y = y+1;
                }
            }
        }

        // routerCallData[y] = abi.encodeWithSelector(IGovernance.initialize.selector, vm.envString("ZEEK_NAME"), vm.envString("ZEEK_SYMBOL"), address(new ReviewSBT(msg.sender)));

        ZeekRouter router = ZeekRouter(payable(vm.envAddress("ZEEK_ROUTER_ADDRESS")));
        router.multicall(routerCallData);

        vm.stopBroadcast();
        
        return router;
    }
}
