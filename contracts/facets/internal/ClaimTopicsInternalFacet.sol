// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibClaimTopicsStorage, ClaimTopicsStorage } from "../../storage/ClaimTopicsStorage.sol";
import { LibRolesStorage } from "../../storage/RolesStorage.sol";

/// @title ClaimTopicsInternalFacet - Internal business logic for ClaimTopics domain
/// @dev Contains all the business logic for claim topics management
/// @dev This facet is not directly exposed in the diamond interface
contract ClaimTopicsInternalFacet {
    event ClaimTopicAdded(uint256 indexed topic);
    event ClaimTopicRemoved(uint256 indexed topic);

    // ================== INTERNAL CLAIM TOPICS OPERATIONS ==================

    /// @notice Internal function to add a claim topic
    /// @param topic Topic identifier to add
    function _addClaimTopic(uint256 topic) internal {
        ClaimTopicsStorage storage cts = LibClaimTopicsStorage.claimTopicsStorage();
        
        // Check if topic already exists
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            require(cts.claimTopics[i] != topic, "ClaimTopicsInternal: Already added");
        }
        
        cts.claimTopics.push(topic);
        emit ClaimTopicAdded(topic);
    }

    /// @notice Internal function to remove a claim topic
    /// @param topic Topic identifier to remove
    function _removeClaimTopic(uint256 topic) internal {
        ClaimTopicsStorage storage cts = LibClaimTopicsStorage.claimTopicsStorage();
        
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            if (cts.claimTopics[i] == topic) {
                // Move last element to current position and remove last
                cts.claimTopics[i] = cts.claimTopics[cts.claimTopics.length - 1];
                cts.claimTopics.pop();
                emit ClaimTopicRemoved(topic);
                return;
            }
        }
        
        // If we reach here, topic was not found - this is not an error, just a no-op
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get all claim topics
    /// @return Array of claim topic identifiers
    function _getClaimTopics() internal view returns (uint256[] memory) {
        return LibClaimTopicsStorage.claimTopicsStorage().claimTopics;
    }

    /// @notice Check if a claim topic exists
    /// @param topic Topic identifier to check
    /// @return True if topic exists
    function _hasClaimTopic(uint256 topic) internal view returns (bool) {
        uint256[] memory topics = LibClaimTopicsStorage.claimTopicsStorage().claimTopics;
        
        for (uint256 i = 0; i < topics.length; i++) {
            if (topics[i] == topic) {
                return true;
            }
        }
        
        return false;
    }

    /// @notice Get number of claim topics
    /// @return Number of claim topics
    function _getClaimTopicsCount() internal view returns (uint256) {
        return LibClaimTopicsStorage.claimTopicsStorage().claimTopics.length;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == LibRolesStorage.rolesStorage().owner, "ClaimTopicsInternal: Not owner");
    }
}
