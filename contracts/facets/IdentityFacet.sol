// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { IIdentity } from "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import { IClaimIssuer } from "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

contract IdentityFacet is IEIP2535Introspection {
    event IdentityRegistered(address indexed investor, address identity, uint16 country);
    event IdentityUpdated(address indexed investor, address newIdentity);
    event IdentityRemoved(address indexed investor);
    event CountryUpdated(address indexed investor, uint16 country);

    modifier onlyAgentOrOwner() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(msg.sender == s.owner || s.agents[msg.sender], "Not authorized");
        _;
    }    function registerIdentity(address investor, address identity, uint16 country) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.investorIdentities[investor] == address(0), "Already registered");
        
        s.investorIdentities[investor] = identity;
        s.investorCountries[investor] = country;
        s.investorFrozenStatus[investor] = false;
        
        emit IdentityRegistered(investor, identity, country);
    }

    function updateIdentity(address investor, address newIdentity) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.investorIdentities[investor] != address(0), "Not registered");
        s.investorIdentities[investor] = newIdentity;
        emit IdentityUpdated(investor, newIdentity);
    }

    function updateCountry(address investor, uint16 newCountry) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.investorCountries[investor] = newCountry;
        emit CountryUpdated(investor, newCountry);
    }    function deleteIdentity(address investor) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        delete s.investorIdentities[investor];
        delete s.investorCountries[investor];
        delete s.investorFrozenStatus[investor];
        emit IdentityRemoved(investor);
    }

    function isVerified(address user) public view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address identityAddress = s.investorIdentities[user];
        if (identityAddress == address(0)) return false;

        IIdentity identity = IIdentity(identityAddress);

        for (uint i = 0; i < s.claimTopics.length; i++) {
            uint256 topic = s.claimTopics[i];
            address[] memory issuers = s.trustedIssuers[topic];
            bool validClaim = false;

            for (uint j = 0; j < issuers.length; j++) {
                try identity.getClaimIdsByTopic(topic) returns (bytes32[] memory claimIds) {                    
                    for (uint k = 0; k < claimIds.length; k++) {
                        try identity.getClaim(claimIds[k]) returns (
                            uint256 /* claimTopic */,
                            uint256 /* scheme */,
                            address issuer,
                            bytes memory signature,
                            bytes memory data,
                            string memory /* uri */
                        ) {
                            if (issuer == issuers[j]) {
                                try IClaimIssuer(issuer).isClaimValid(identity, topic, signature, data) returns (bool valid) {
                                    if (valid) {
                                        validClaim = true;
                                        break;
                                    }
                                } catch {}
                            }
                        } catch {}
                        if (validClaim) break;
                    }
                } catch {}
                if (validClaim) break;
            }
            if (!validClaim) return false;
        }
        return true;
    }    function getInvestorCountry(address investor) external view returns (uint16) {
        return LibAppStorage.diamondStorage().investorCountries[investor];
    }

    /// @dev Renamed the function to `getIdentity` to avoid a naming conflict with the `identity` variable.
    ///      Developers should use this function to retrieve the identity address associated with a given investor.
    function getIdentity(address investor) external view returns (address) {
        return LibAppStorage.diamondStorage().investorIdentities[investor];
    }

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 7;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.registerIdentity.selector;
        selectors_[--selectorsLength] = this.updateIdentity.selector;
        selectors_[--selectorsLength] = this.updateCountry.selector;
        selectors_[--selectorsLength] = this.deleteIdentity.selector;
        selectors_[--selectorsLength] = this.isVerified.selector;
        selectors_[--selectorsLength] = this.getInvestorCountry.selector;
        selectors_[--selectorsLength] = this.getIdentity.selector;
    }
}