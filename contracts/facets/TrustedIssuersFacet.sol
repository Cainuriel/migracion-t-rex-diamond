// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { TrustedIssuersInternalFacet } from "./internal/TrustedIssuersInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title TrustedIssuersFacet - External interface for TrustedIssuers operations
/// @dev Exposes only public/external functions, inherits business logic from TrustedIssuersInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract TrustedIssuersFacet is TrustedIssuersInternalFacet, IEIP2535Introspection {

    modifier onlyOwner() {
        _onlyOwner(msg.sender);
        _;
    }

    // ================== EXTERNAL TRUSTED ISSUERS FUNCTIONS ==================

    /// @notice Add a trusted issuer for specific claim topics
    /// @param issuer Issuer address to add
    /// @param topics Array of topic identifiers
    function addTrustedIssuer(address issuer, uint256[] calldata topics) external onlyOwner {
        _addTrustedIssuer(issuer, topics);
    }

    /// @notice Remove a trusted issuer from a specific topic
    /// @param issuer Issuer address to remove
    /// @param topic Topic identifier
    function removeTrustedIssuer(address issuer, uint256 topic) external onlyOwner {
        _removeTrustedIssuer(issuer, topic);
    }

    /// @notice Get all trusted issuers for a specific topic
    /// @param topic Topic identifier
    /// @return Array of trusted issuer addresses
    function getTrustedIssuers(uint256 topic) external view returns (address[] memory) {
        return _getTrustedIssuers(topic);
    }

    // ================== IEIP2535INTROSPECTION ==================

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 3;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.addTrustedIssuer.selector;
        selectors_[--selectorsLength] = this.removeTrustedIssuer.selector;
        selectors_[--selectorsLength] = this.getTrustedIssuers.selector;
    }
}
