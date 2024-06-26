// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../libraries/ZeekDataTypes.sol";

/**
 * @title IProfile
 * @author zeeker
 *
 * @dev This is the interface for the Profile contract, which is based on user address to create profile.
 */
interface IProfile {

    /**
     * return the profileId
     */
    function createProfile(uint256 salt) external returns (uint256);

    /**
     * Prevent contract call duplicate case
     * @param singer singer address
     */
    function nonces(address singer) external view returns (uint256);

    /**
     * Returns the profile struct of the given profile ID.
     * @param profileId The profile ID to query.
     */
    function getProfile(uint256 profileId) external view returns (address owner, string memory linkCode, uint256 timestamp);
        
    /**
     * Returns the profile struct of the given addr.
     * @param owner address
     */
    function getProfileByAddress(address owner) external view returns (uint256 profileId, string memory linkCode, uint256 timestamp);

    /**
     * claim all personal vaults
     * @param token which one would you claim
     */
    function claim(address token) external;

    /**
     * vault
     * 
     * @param token token address
     * @return claimable claimable value
     * @return claimed claimed value
     */
    function vault(address owner, address token) external view returns (uint256 claimable, uint256 claimed, uint64 timestamp);

}
