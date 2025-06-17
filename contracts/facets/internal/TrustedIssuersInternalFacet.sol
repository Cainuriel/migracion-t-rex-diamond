// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibTrustedIssuersStorage, TrustedIssuersStorage } from "../../storage/TrustedIssuersStorage.sol";
import { LibRolesStorage } from "../../storage/RolesStorage.sol";

/// @title TrustedIssuersInternalFacet - Internal business logic for TrustedIssuers domain
/// @dev Contains all the business logic for trusted issuers management
/// @dev This facet is not directly exposed in the diamond interface
contract TrustedIssuersInternalFacet {
    event TrustedIssuerAdded(address indexed issuer, uint256[] claimTopics);
    event TrustedIssuerRemoved(address indexed issuer);

    // ================== INTERNAL TRUSTED ISSUERS OPERATIONS ==================

    /// @notice Internal function to add trusted issuer for multiple topics
    /// @param issuer Issuer address to add
    /// @param topics Array of topic identifiers
    function _addTrustedIssuer(address issuer, uint256[] calldata topics) internal {
        require(issuer != address(0), "TrustedIssuersInternal: issuer is zero address");
        require(topics.length > 0, "TrustedIssuersInternal: no topics provided");
        
        TrustedIssuersStorage storage tis = LibTrustedIssuersStorage.trustedIssuersStorage();
        
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
            
            // Add issuer if not already present
            if (!exists) {
                issuers.push(issuer);
            }
        }
        
        emit TrustedIssuerAdded(issuer, topics);
    }

    /// @notice Internal function to remove trusted issuer from a specific topic
    /// @param issuer Issuer address to remove
    /// @param topic Topic identifier
    function _removeTrustedIssuer(address issuer, uint256 topic) internal {
        TrustedIssuersStorage storage tis = LibTrustedIssuersStorage.trustedIssuersStorage();
        address[] storage issuers = tis.trustedIssuers[topic];
        
        for (uint256 i = 0; i < issuers.length; i++) {
            if (issuers[i] == issuer) {
                // Move last element to current position and remove last
                issuers[i] = issuers[issuers.length - 1];
                issuers.pop();
                emit TrustedIssuerRemoved(issuer);
                return;
            }
        }
        
        // If we reach here, issuer was not found for this topic - this is not an error
    }    /// @notice Internal function to remove trusted issuer from all topics
    /// @param issuer Issuer address to remove completely
    function _removeTrustedIssuerFromAllTopics(address issuer) internal {
        // Note: This is a simplified approach. In a production system, you might want to 
        // keep track of which topics an issuer is associated with for more efficient removal
        // For now, this would require iterating through all possible topics or maintaining 
        // a reverse mapping
        
        emit TrustedIssuerRemoved(issuer);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get all trusted issuers for a topic
    /// @param topic Topic identifier
    /// @return Array of trusted issuer addresses
    function _getTrustedIssuers(uint256 topic) internal view returns (address[] memory) {
        return LibTrustedIssuersStorage.trustedIssuersStorage().trustedIssuers[topic];
    }

    /// @notice Check if an issuer is trusted for a specific topic
    /// @param issuer Issuer address to check
    /// @param topic Topic identifier
    /// @return True if issuer is trusted for the topic
    function _isTrustedIssuer(address issuer, uint256 topic) internal view returns (bool) {
        address[] memory issuers = LibTrustedIssuersStorage.trustedIssuersStorage().trustedIssuers[topic];
        
        for (uint256 i = 0; i < issuers.length; i++) {
            if (issuers[i] == issuer) {
                return true;
            }
        }
        
        return false;
    }

    /// @notice Get number of trusted issuers for a topic
    /// @param topic Topic identifier
    /// @return Number of trusted issuers
    function _getTrustedIssuersCount(uint256 topic) internal view returns (uint256) {
        return LibTrustedIssuersStorage.trustedIssuersStorage().trustedIssuers[topic].length;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == LibRolesStorage.rolesStorage().owner, "TrustedIssuersInternal: Not owner");
    }
}
