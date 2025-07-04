// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ITrustedIssuersEvents } from "../../interfaces/events/ITrustedIssuersEvents.sol";
import { ITrustedIssuersErrors } from "../../interfaces/errors/ITrustedIssuersErrors.sol";

/// @title TrustedIssuersInternalFacet - Internal business logic for TrustedIssuers domain
/// @dev Contains all the business logic for trusted issuers management
/// @dev This facet is not directly exposed in the diamond interface
contract TrustedIssuersInternalFacet is ITrustedIssuersEvents, ITrustedIssuersErrors {

    // ================== STORAGE STRUCTURES ==================

    /// @title TrustedIssuersStorage - Unstructured storage for TrustedIssuers domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct TrustedIssuersStorage {
        // === TRUSTED ISSUERS ===
        mapping(uint256 => address[]) trustedIssuers; // claimTopic => issuer addresses
        mapping(address => mapping(uint256 => bool)) issuerStatus; // issuer => claimTopic => trusted
        mapping(uint256 => uint256) issuerCount; // claimTopic => count of trusted issuers
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

    /// @dev Storage slot for TrustedIssuers domain
    bytes32 private constant TRUSTED_ISSUERS_STORAGE_POSITION = keccak256("t-rex.diamond.trusted-issuers.storage");
    
    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get TrustedIssuers storage reference
    /// @return tis TrustedIssuers storage struct
    function _getTrustedIssuersStorage() private pure returns (TrustedIssuersStorage storage tis) {
        bytes32 position = TRUSTED_ISSUERS_STORAGE_POSITION;
        assembly {
            tis.slot := position
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

    // ================== INTERNAL TRUSTED ISSUERS OPERATIONS ==================

    /// @notice Internal function to add trusted issuer for multiple topics
    /// @param issuer Issuer address to add
    /// @param topics Array of topic identifiers
    function _addTrustedIssuer(address issuer, uint256[] calldata topics) internal {
        if (issuer == address(0)) revert ZeroAddress();
        if (topics.length == 0) revert EmptyClaimTopics();
        
        TrustedIssuersStorage storage tis = _getTrustedIssuersStorage();
        
        for (uint256 i = 0; i < topics.length; i++) {
            uint256 topic = topics[i];
            
            // Check if issuer already exists for this topic
            bool exists = false;
            address[] storage issuers = tis.trustedIssuers[topic];
            
            for (uint256 j = 0; j < issuers.length; j++) {
                if (issuers[j] == issuer) {
                    exists = true;
                    break;
                }
            }
            
            if (!exists) {
                tis.trustedIssuers[topic].push(issuer);
                tis.issuerStatus[issuer][topic] = true;
                tis.issuerCount[topic]++;
            }
        }
        
        emit TrustedIssuerAdded(issuer, topics);
    }

    /// @notice Internal function to remove trusted issuer
    /// @param issuer Issuer address to remove
    function _removeTrustedIssuer(address issuer) internal {
        if (issuer == address(0)) revert ZeroAddress();
        
        TrustedIssuersStorage storage tis = _getTrustedIssuersStorage();
        
        // Find all topics where this issuer is trusted and remove them
        uint256[] memory topicsToRemove = _getIssuerTopics(issuer);
        
        for (uint256 i = 0; i < topicsToRemove.length; i++) {
            uint256 topic = topicsToRemove[i];
            address[] storage issuers = tis.trustedIssuers[topic];
            
            // Find and remove issuer from array
            for (uint256 j = 0; j < issuers.length; j++) {
                if (issuers[j] == issuer) {
                    issuers[j] = issuers[issuers.length - 1];
                    issuers.pop();
                    tis.issuerStatus[issuer][topic] = false;
                    tis.issuerCount[topic]--;
                    break;
                }
            }
        }
        
        emit TrustedIssuerRemoved(issuer);
    }

    /// @notice Internal function to remove trusted issuer for specific topic
    /// @param issuer Issuer address
    /// @param topic Topic identifier
    function _removeTrustedIssuerForTopic(address issuer, uint256 topic) internal {
        if (issuer == address(0)) revert ZeroAddress();
        
        TrustedIssuersStorage storage tis = _getTrustedIssuersStorage();
        if (!tis.issuerStatus[issuer][topic]) revert TrustedIssuerNotFound(issuer);
        
        address[] storage issuers = tis.trustedIssuers[topic];
        
        // Find and remove issuer from array
        for (uint256 j = 0; j < issuers.length; j++) {
            if (issuers[j] == issuer) {
                issuers[j] = issuers[issuers.length - 1];
                issuers.pop();
                tis.issuerStatus[issuer][topic] = false;
                tis.issuerCount[topic]--;
                break;
            }
        }
        
        emit TrustedIssuerRemoved(issuer);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get trusted issuers for a specific topic
    /// @param topic Topic identifier
    /// @return Array of trusted issuer addresses
    function _getTrustedIssuersForTopic(uint256 topic) internal view returns (address[] memory) {
        return _getTrustedIssuersStorage().trustedIssuers[topic];
    }

    /// @notice Check if issuer is trusted for specific topic
    /// @param issuer Issuer address
    /// @param topic Topic identifier
    /// @return True if issuer is trusted for the topic
    function _isTrustedIssuer(address issuer, uint256 topic) internal view returns (bool) {
        return _getTrustedIssuersStorage().issuerStatus[issuer][topic];
    }

    /// @notice Get count of trusted issuers for a topic
    /// @param topic Topic identifier
    /// @return Number of trusted issuers for the topic
    function _getTrustedIssuerCount(uint256 topic) internal view returns (uint256) {
        return _getTrustedIssuersStorage().issuerCount[topic];
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @notice Get all topics where an issuer is trusted
    /// @param issuer Issuer address
    /// @return Array of topic identifiers
    function _getIssuerTopics(address issuer) private view returns (uint256[] memory) {
        TrustedIssuersStorage storage tis = _getTrustedIssuersStorage();
        
        // This is a simplified implementation
        // In a real implementation, you might want to track this more efficiently
        uint256[] memory tempTopics = new uint256[](100); // Assuming max 100 topics
        uint256 count = 0;
        
        // Check topics 1-100 (common range for claim topics)
        for (uint256 topic = 1; topic <= 100; topic++) {
            if (tis.issuerStatus[issuer][topic]) {
                tempTopics[count] = topic;
                count++;
            }
        }
        
        // Create array with exact size
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = tempTopics[i];
        }
        
        return result;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        if (caller != _getRolesStorage().owner) revert Unauthorized(caller);
    }

    /// @notice Internal check for agent or owner authorization
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        RolesStorage storage rs = _getRolesStorage();
        if (caller != rs.owner && !rs.agents[caller]) revert Unauthorized(caller);
    }
}
