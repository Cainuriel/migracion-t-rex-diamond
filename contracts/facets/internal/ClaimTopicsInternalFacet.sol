// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IClaimTopicsEvents } from "../../interfaces/events/IClaimTopicsEvents.sol";

/// @title ClaimTopicsInternalFacet - Internal business logic for ClaimTopics domain
/// @dev Contains all the business logic for claim topics management
/// @dev This facet is not directly exposed in the diamond interface
contract ClaimTopicsInternalFacet is IClaimTopicsEvents {

    // ================== STORAGE STRUCTURES ==================

    /// @title ClaimTopicsStorage - Unstructured storage for ClaimTopics domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct ClaimTopicsStorage {
        // === CLAIM TOPICS ===
        uint256[] claimTopics;
        mapping(uint256 => bool) requiredClaimTopics;
    }

    /// @title RolesStorage - Unstructured storage for Roles domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }

    // ================== STORAGE ACCESS ==================

    /// @dev Storage slot for ClaimTopics domain
    bytes32 private constant CLAIM_TOPICS_STORAGE_POSITION = keccak256("t-rex.diamond.claim-topics.storage");
    
    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get ClaimTopics storage reference
    /// @return cts ClaimTopics storage struct
    function _getClaimTopicsStorage() private pure returns (ClaimTopicsStorage storage cts) {
        bytes32 position = CLAIM_TOPICS_STORAGE_POSITION;
        assembly {
            cts.slot := position
        }
    }

    /// @notice Get Roles storage reference
    /// @return rs Roles storage struct
    function _getRolesStorage() private pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }

    // ================== INTERNAL CLAIM TOPICS OPERATIONS ==================

    /// @notice Internal function to add a claim topic
    /// @param topic Topic identifier to add
    function _addClaimTopic(uint256 topic) internal {
        ClaimTopicsStorage storage cts = _getClaimTopicsStorage();
        
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
        ClaimTopicsStorage storage cts = _getClaimTopicsStorage();
        
        // Find and remove topic
        bool found = false;
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            if (cts.claimTopics[i] == topic) {
                cts.claimTopics[i] = cts.claimTopics[cts.claimTopics.length - 1];
                cts.claimTopics.pop();
                delete cts.requiredClaimTopics[topic];
                found = true;
                break;
            }
        }
        
        require(found, "ClaimTopicsInternal: Not found");
        emit ClaimTopicRemoved(topic);
    }

    /// @notice Internal function to set claim topic requirement status
    /// @param topic Topic identifier
    /// @param required Whether the topic is required
    function _setClaimTopicRequired(uint256 topic, bool required) internal {
        ClaimTopicsStorage storage cts = _getClaimTopicsStorage();
        
        // Check if topic exists
        bool exists = false;
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            if (cts.claimTopics[i] == topic) {
                exists = true;
                break;
            }
        }
        
        require(exists, "ClaimTopicsInternal: Topic not added");
        cts.requiredClaimTopics[topic] = required;
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get all claim topics
    /// @return Array of claim topic identifiers
    function _getClaimTopics() internal view returns (uint256[] memory) {
        return _getClaimTopicsStorage().claimTopics;
    }

    /// @notice Check if a claim topic is required
    /// @param topic Topic identifier
    /// @return True if topic is required
    function _isClaimTopicRequired(uint256 topic) internal view returns (bool) {
        return _getClaimTopicsStorage().requiredClaimTopics[topic];
    }

    /// @notice Check if a claim topic exists
    /// @param topic Topic identifier
    /// @return True if topic exists
    function _claimTopicExists(uint256 topic) internal view returns (bool) {
        ClaimTopicsStorage storage cts = _getClaimTopicsStorage();
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            if (cts.claimTopics[i] == topic) {
                return true;
            }
        }
        return false;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == _getRolesStorage().owner, "ClaimTopicsInternal: Not owner");
    }

    /// @notice Internal check for agent or owner authorization
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        RolesStorage storage rs = _getRolesStorage();
        require(caller == rs.owner || rs.agents[caller], "ClaimTopicsInternal: Not authorized");
    }
}
