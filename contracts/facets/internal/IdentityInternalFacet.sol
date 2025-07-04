// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IIdentity } from "../../onchain-id/interface/IIdentity.sol";
import { IClaimIssuer } from "../../onchain-id/interface/IClaimIssuer.sol";
import { IIdentityEvents } from "../../interfaces/events/IIdentityEvents.sol";
import { IIdentityErrors } from "../../interfaces/errors/IIdentityErrors.sol";

/// @title IdentityInternalFacet - Internal business logic for Identity domain
/// @dev Contains all the business logic for investor identity management
/// @dev This facet is not directly exposed in the diamond interface
contract IdentityInternalFacet is IIdentityEvents, IIdentityErrors {

    // ================== STORAGE STRUCTURES ==================

    /// @title IdentityStorage - Unstructured storage for Identity domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct IdentityStorage {
        // === IDENTITY DATA ===
        mapping(address => address) investorIdentities;
        mapping(address => uint16) investorCountries;
        mapping(address => bool) verificationStatus;
    }

    /// @title ClaimTopicsStorage - Unstructured storage for ClaimTopics domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct ClaimTopicsStorage {
        // === CLAIM TOPICS ===
        uint256[] claimTopics;
        mapping(uint256 => bool) requiredClaimTopics;
    }

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

    /// @dev Storage slot for Identity domain
    bytes32 private constant IDENTITY_STORAGE_POSITION = keccak256("t-rex.diamond.identity.storage");
    
    /// @dev Storage slot for ClaimTopics domain
    bytes32 private constant CLAIM_TOPICS_STORAGE_POSITION = keccak256("t-rex.diamond.claim-topics.storage");
    
    /// @dev Storage slot for TrustedIssuers domain
    bytes32 private constant TRUSTED_ISSUERS_STORAGE_POSITION = keccak256("t-rex.diamond.trusted-issuers.storage");
    
    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get Identity storage reference
    /// @return ids Identity storage struct
    function _getIdentityStorage() private pure returns (IdentityStorage storage ids) {
        bytes32 position = IDENTITY_STORAGE_POSITION;
        assembly {
            ids.slot := position
        }
    }

    /// @notice Get ClaimTopics storage reference
    /// @return cts ClaimTopics storage struct
    function _getClaimTopicsStorage() private pure returns (ClaimTopicsStorage storage cts) {
        bytes32 position = CLAIM_TOPICS_STORAGE_POSITION;
        assembly {
            cts.slot := position
        }
    }

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

    // ================== INTERNAL IDENTITY OPERATIONS ==================

    /// @notice Internal function to register an investor identity
    /// @param investor Investor address
    /// @param identity Identity contract address
    /// @param country Country code
    function _registerIdentity(address investor, address identity, uint16 country) internal {
        if (investor == address(0)) revert ZeroAddress();
        if (identity == address(0)) revert ZeroAddress();
        
        IdentityStorage storage ids = _getIdentityStorage();
        if (ids.investorIdentities[investor] != address(0)) revert AlreadyRegistered(investor);
        
        ids.investorIdentities[investor] = identity;
        ids.investorCountries[investor] = country;
        
        emit IdentityRegistered(investor, identity, country);
    }

    /// @notice Internal function to update investor identity
    /// @param investor Investor address
    /// @param newIdentity New identity contract address
    function _updateIdentity(address investor, address newIdentity) internal {
        if (newIdentity == address(0)) revert ZeroAddress();
        
        IdentityStorage storage ids = _getIdentityStorage();
        if (ids.investorIdentities[investor] == address(0)) revert NotRegistered(investor);
        
        ids.investorIdentities[investor] = newIdentity;
        emit IdentityUpdated(investor, newIdentity);
    }

    /// @notice Internal function to update investor country
    /// @param investor Investor address
    /// @param country New country code
    function _updateCountry(address investor, uint16 country) internal {
        IdentityStorage storage ids = _getIdentityStorage();
        if (ids.investorIdentities[investor] == address(0)) revert NotRegistered(investor);
        
        ids.investorCountries[investor] = country;
        emit CountryUpdated(investor, country);
    }

    /// @notice Internal function to remove investor identity
    /// @param investor Investor address
    function _removeIdentity(address investor) internal {
        IdentityStorage storage ids = _getIdentityStorage();
        if (ids.investorIdentities[investor] == address(0)) revert NotRegistered(investor);
        
        delete ids.investorIdentities[investor];
        delete ids.investorCountries[investor];
        delete ids.verificationStatus[investor];
        
        emit IdentityRemoved(investor);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get investor identity contract address
    /// @param investor Investor address
    /// @return Identity contract address
    function _getIdentity(address investor) internal view returns (address) {
        return _getIdentityStorage().investorIdentities[investor];
    }

    /// @notice Get investor country
    /// @param investor Investor address
    /// @return Country code
    function _getCountry(address investor) internal view returns (uint16) {
        return _getIdentityStorage().investorCountries[investor];
    }

    /// @notice Check if investor is registered
    /// @param investor Investor address
    /// @return True if registered
    function _isRegistered(address investor) internal view returns (bool) {
        return _getIdentityStorage().investorIdentities[investor] != address(0);
    }

    /// @notice Verify if investor has valid claims for required topics
    /// @param investor Investor address
    /// @return True if investor has all required claims
    function _isVerified(address investor) internal view returns (bool) {
        IdentityStorage storage ids = _getIdentityStorage();
        ClaimTopicsStorage storage cts = _getClaimTopicsStorage();
        TrustedIssuersStorage storage tis = _getTrustedIssuersStorage();
        
        address identity = ids.investorIdentities[investor];
        if (identity == address(0)) {
            return false;
        }

        // Check all required claim topics
        for (uint256 i = 0; i < cts.claimTopics.length; i++) {
            uint256 topic = cts.claimTopics[i];
            
            if (cts.requiredClaimTopics[topic]) {
                if (!_hasValidClaim(identity, topic, tis)) {
                    return false;
                }
            }
        }

        return true;
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @notice Check if identity has valid claim for specific topic
    /// @param identity Identity contract address
    /// @param topic Claim topic
    /// @param tis TrustedIssuers storage reference
    /// @return True if has valid claim
    function _hasValidClaim(
        address identity, 
        uint256 topic, 
        TrustedIssuersStorage storage tis
    ) private view returns (bool) {
        // Get trusted issuers for this topic
        address[] memory trustedIssuers = tis.trustedIssuers[topic];
        
        if (trustedIssuers.length == 0) {
            return false;
        }

        // Check if identity has claim from any trusted issuer
        try IIdentity(identity).getClaimIdsByTopic(topic) returns (bytes32[] memory claimIds) {
            for (uint256 i = 0; i < claimIds.length; i++) {
                try IIdentity(identity).getClaim(claimIds[i]) returns (
                    uint256, // topic
                    uint256, // scheme  
                    address issuer,
                    bytes memory, // signature
                    bytes memory, // data
                    string memory // uri
                ) {
                    // Check if issuer is trusted for this topic
                    if (tis.issuerStatus[issuer][topic]) {
                        return true;
                    }
                } catch {
                    continue;
                }
            }
        } catch {
            return false;
        }

        return false;
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
