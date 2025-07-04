// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibIdentityStorage, IdentityStorage } from "../../storage/IdentityStorage.sol";
import { LibClaimTopicsStorage } from "../../storage/ClaimTopicsStorage.sol";
import { LibTrustedIssuersStorage } from "../../storage/TrustedIssuersStorage.sol";
import { LibRolesStorage } from "../../storage/RolesStorage.sol";
import { IIdentity } from "../../onchain-id/interface/IIdentity.sol";
import { IClaimIssuer } from "../../onchain-id/interface/IClaimIssuer.sol";

/// @title IdentityInternalFacet - Internal business logic for Identity domain
/// @dev Contains all the business logic for investor identity management
/// @dev This facet is not directly exposed in the diamond interface
contract IdentityInternalFacet {
    event IdentityRegistered(address indexed investor, address identity, uint16 country);
    event IdentityUpdated(address indexed investor, address newIdentity);
    event IdentityRemoved(address indexed investor);
    event CountryUpdated(address indexed investor, uint16 country);

    // ================== INTERNAL IDENTITY OPERATIONS ==================    /// @notice Internal function to register an investor identity
    /// @param investor Investor address
    /// @param identity Identity contract address
    /// @param country Country code
    function _registerIdentity(address investor, address identity, uint16 country) internal {
        require(investor != address(0), "IdentityInternal: investor is zero address");
        require(identity != address(0), "IdentityInternal: identity is zero address");
        
        IdentityStorage storage ids = LibIdentityStorage.identityStorage();
        require(ids.investorIdentities[investor] == address(0), "IdentityInternal: Already registered");
        
        ids.investorIdentities[investor] = identity;
        ids.investorCountries[investor] = country;
        
        emit IdentityRegistered(investor, identity, country);
    }

    /// @notice Internal function to update investor identity
    /// @param investor Investor address
    /// @param newIdentity New identity contract address
    function _updateIdentity(address investor, address newIdentity) internal {
        require(newIdentity != address(0), "IdentityInternal: identity is zero address");
        
        IdentityStorage storage ids = LibIdentityStorage.identityStorage();
        require(ids.investorIdentities[investor] != address(0), "IdentityInternal: Not registered");
        
        ids.investorIdentities[investor] = newIdentity;
        emit IdentityUpdated(investor, newIdentity);
    }

    /// @notice Internal function to update investor country
    /// @param investor Investor address
    /// @param newCountry New country code
    function _updateCountry(address investor, uint16 newCountry) internal {
        IdentityStorage storage ids = LibIdentityStorage.identityStorage();
        ids.investorCountries[investor] = newCountry;
        emit CountryUpdated(investor, newCountry);
    }    /// @notice Internal function to delete investor identity
    /// @param investor Investor address
    function _deleteIdentity(address investor) internal {
        IdentityStorage storage ids = LibIdentityStorage.identityStorage();
        
        delete ids.investorIdentities[investor];
        delete ids.investorCountries[investor];
        
        emit IdentityRemoved(investor);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================    /// @notice Get investor identity address
    /// @param investor Investor address
    /// @return Identity contract address
    function _getIdentity(address investor) internal view returns (address) {
        return LibIdentityStorage.identityStorage().investorIdentities[investor];
    }

    /// @notice Get investor country
    /// @param investor Investor address
    /// @return Country code
    function _getInvestorCountry(address investor) internal view returns (uint16) {
        return LibIdentityStorage.identityStorage().investorCountries[investor];
    }

    /// @notice Internal function to check if user is verified
    /// @param user User address to verify
    /// @return True if user has valid claims for all required topics
    function _isVerified(address user) internal view returns (bool) {
        IdentityStorage storage ids = LibIdentityStorage.identityStorage();
        address identityAddress = ids.investorIdentities[user];
        
        if (identityAddress == address(0)) return false;

        IIdentity identity = IIdentity(identityAddress);
        uint256[] memory claimTopics = LibClaimTopicsStorage.claimTopicsStorage().claimTopics;

        for (uint i = 0; i < claimTopics.length; i++) {
            if (!_hasValidClaimForTopic(identity, claimTopics[i])) {
                return false;
            }
        }
        return true;
    }

    /// @notice Internal helper to check if identity has valid claim for a topic
    /// @param identity Identity contract
    /// @param topic Claim topic to verify
    /// @return True if valid claim exists
    function _hasValidClaimForTopic(IIdentity identity, uint256 topic) private view returns (bool) {
        address[] memory issuers = LibTrustedIssuersStorage.trustedIssuersStorage().trustedIssuers[topic];
        
        for (uint j = 0; j < issuers.length; j++) {
            if (_checkIssuerClaims(identity, topic, issuers[j])) {
                return true;
            }
        }
        return false;
    }

    /// @notice Internal helper to check claims from specific issuer
    /// @param identity Identity contract
    /// @param topic Claim topic
    /// @param issuer Trusted issuer address
    /// @return True if valid claim found
    function _checkIssuerClaims(IIdentity identity, uint256 topic, address issuer) private view returns (bool) {
        try identity.getClaimIdsByTopic(topic) returns (bytes32[] memory claimIds) {
            for (uint k = 0; k < claimIds.length; k++) {
                if (_validateClaim(identity, claimIds[k], topic, issuer)) {
                    return true;
                }
            }
        } catch {}
        return false;
    }

    /// @notice Internal helper to validate a specific claim
    /// @param identity Identity contract
    /// @param claimId Claim ID to validate
    /// @param topic Expected topic
    /// @param expectedIssuer Expected issuer address
    /// @return True if claim is valid
    function _validateClaim(
        IIdentity identity, 
        bytes32 claimId, 
        uint256 topic, 
        address expectedIssuer
    ) private view returns (bool) {
        try identity.getClaim(claimId) returns (
            uint256 /* claimTopic */,
            uint256 /* scheme */,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory /* uri */
        ) {
            if (issuer == expectedIssuer) {
                try IClaimIssuer(issuer).isClaimValid(identity, topic, signature, data) returns (bool valid) {
                    return valid;
                } catch {}
            }
        } catch {}
        return false;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner or agent authorization
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        require(
            caller == LibRolesStorage.rolesStorage().owner || 
            LibRolesStorage.rolesStorage().agents[caller],
            "IdentityInternal: Not authorized"
        );
    }
}
