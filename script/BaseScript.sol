// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "../contracts/upgradeability/IRouter.sol";
import "../contracts/core/Governance.sol";
import "../contracts/core/Profile.sol";
import "../contracts/core/Wish.sol";

abstract contract BaseScript is Script {
    string constant IDENTIFIER_PATH = "script/identifiers/";

    string constant GOVERNANCE = "Governance";
    string constant PROFILE = "Profile";
    string constant WISH = "Wish";
    string constant UPGRADE = "Upgrade";

    bytes constant ROUTER_ADD = bytes("add");
    bytes constant ROUTER_REMOVE = bytes("remove");

    string[] CONTRACTS = [GOVERNANCE, PROFILE, WISH];

    mapping(string => bytes) routerChanges;

    function _getRouterChange(string memory func) internal view returns(bytes memory) {
        return routerChanges[func];
    }

    function _buildRouterChanges() internal {
        string memory json = vm.readFile(
            string(abi.encodePacked(IDENTIFIER_PATH, UPGRADE, ".json"))
        );
        string[] memory selectors = vm.parseJsonKeys(json, "$");
        
        for (uint256 j; j < selectors.length;) {
            routerChanges[selectors[j]] = bytes(vm.parseJsonString(json, string(abi.encodePacked('.["', selectors[j], '"]'))));
            console2.log(
                string( abi.encodePacked(selectors[j], "-", routerChanges[selectors[j]]))
            );
            unchecked {
                 ++j;
            }
        }
    }

    function _buildRouter(
        string memory contractName,
        address contractAddress
    ) internal view returns (IRouter.Router[] memory) {
        string memory json = vm.readFile(
            string(abi.encodePacked(IDENTIFIER_PATH, contractName, ".json"))
        );
        string[] memory selectors = vm.parseJsonKeys(json, "$");

        IRouter.Router[] memory routers = new IRouter.Router[](selectors.length);
        uint x= 0;
        for (uint256 j; j < selectors.length;) {
            // console2.log(
            //     string( abi.encodePacked(contractName, "-", selectors[j]))
            // );
            routers[x] = IRouter.Router(
                    bytes4(
                        vm.parseJsonBytes(
                            json,
                            string(abi.encodePacked('.["', selectors[j], '"]'))
                        )
                    ),
                    selectors[j],
                    contractAddress
                );
            unchecked {
                 ++j;
                 ++x;
            }
        }
        return routers;
    }

}
