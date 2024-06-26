// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ZeekTestSetUp.sol";
import "../contracts/libraries/ZeekDataTypes.sol";

contract MetaTxNegatives is ZeekTestSetUp {

    /*///////////////////////////////////////////////////////////////
                type data signature
    //////////////////////////////////////////////////////////////*/
    function _getSigStruct(
        uint256 privateKey,
        bytes32 digest,
        uint64 deadline
    ) internal pure returns (ZeekDataTypes.EIP712Signature memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return ZeekDataTypes.EIP712Signature(abi.encodePacked(r, s, v), deadline);
    }

    function _calculateDigest(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked('\x19\x01', _calculateDomainSeparator(), structHash));
    }

    function _calculateDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                ZeekDataTypes.EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(contractName)),
                EIP712_REVISION_HASH,
                block.chainid,
                address(zeekRouter)
            )
        );
    }

    /*///////////////////////////////////////////////////////////////
                    type data hash
    //////////////////////////////////////////////////////////////*/

    function _getOfferTypedDataHash(
        ZeekDataTypes.WishApplyData memory vars,
        uint256 deadline
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                ZeekDataTypes.OFFER_WISH_WITH_SIG_TYPEHASH,
                vars.wishId,
                vars.talent,
                vars.linker,
                vars.applyTime,
                vars.applyNonce,
                deadline
            )
        );
        return _calculateDigest(structHash);
    }
}
