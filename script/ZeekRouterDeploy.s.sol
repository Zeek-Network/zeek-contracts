// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../contracts/upgradeability/ZeekRouter.sol";
import "./BaseScript.sol";

contract ZeekRouterDeployScript is BaseScript {

    mapping(string => address) contractsMap;

    function setUp() public {}

    function run() public returns (ZeekRouter) {
        vm.startBroadcast();

        ZeekRouter router = new ZeekRouter(msg.sender);
        console2.log('router admin: ', msg.sender);

        Governance governance = new Governance();
        contractsMap[GOVERNANCE] = address(governance);
        console2.log('gov contract: ', contractsMap[GOVERNANCE]);
        Profile profile = new Profile(address(router));
        contractsMap[PROFILE] = address(profile);
        console2.log('profile contract: ', contractsMap[PROFILE]);
        Wish wish = new Wish();
        contractsMap[WISH] = address(wish);
        console2.log('wish contract: ', contractsMap[WISH]);


        bytes[] memory routerCallData = new bytes[](41);
        uint256 y;
        for (uint256 i; i < CONTRACTS.length;) {
            IRouter.Router[] memory routers = _buildRouter(CONTRACTS[i], contractsMap[CONTRACTS[i]]);
            for (uint256 j; j < routers.length;) {
                routerCallData[y] = abi.encodeWithSelector(ZeekRouter.addRouter.selector, routers[j]);
                unchecked{
                    ++y;
                    ++j;
                }
            }
            unchecked {
                 ++i;
            }
        }

        routerCallData[y] = abi.encodeWithSelector(IGovernance.initialize.selector, vm.envString("ZEEK_NAME"), vm.envString("ZEEK_SYMBOL"));

        router.multicall(routerCallData);

        vm.stopBroadcast();
        
        return router;
    }
}
