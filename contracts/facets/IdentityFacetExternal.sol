// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IdentityInternalFacet } from "./internal/IdentityInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title IdentityFacetExternal - External interface for Identity operations
/// @dev Exposes only public/external functions, inherits business logic from IdentityInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract IdentityFacetExternal is IdentityInternalFacet, IEIP2535Introspection {

    modifier onlyAgentOrOwner() {
        _onlyAgentOrOwner(msg.sender);
        _;
    }

    // ================== EXTERNAL IDENTITY FUNCTIONS ==================

    /// @notice Register a new investor identity
    /// @param investor Investor address
    /// @param identity Identity contract address
    /// @param country Country code
    function registerIdentity(address investor, address identity, uint16 country) external onlyAgentOrOwner {
        _registerIdentity(investor, identity, country);
    }

    /// @notice Update investor identity contract
    /// @param investor Investor address
    /// @param newIdentity New identity contract address
    function updateIdentity(address investor, address newIdentity) external onlyAgentOrOwner {
        _updateIdentity(investor, newIdentity);
    }

    /// @notice Update investor country
    /// @param investor Investor address
    /// @param newCountry New country code
    function updateCountry(address investor, uint16 newCountry) external onlyAgentOrOwner {
        _updateCountry(investor, newCountry);
    }

    /// @notice Delete investor identity
    /// @param investor Investor address
    function deleteIdentity(address investor) external onlyAgentOrOwner {
        _deleteIdentity(investor);
    }

    /// @notice Check if user has valid identity claims
    /// @param user User address to verify
    /// @return True if user is verified with valid claims
    function isVerified(address user) external view returns (bool) {
        return _isVerified(user);
    }

    /// @notice Get investor country code
    /// @param investor Investor address
    /// @return Country code
    function getInvestorCountry(address investor) external view returns (uint16) {
        return _getInvestorCountry(investor);
    }

    /// @notice Get investor identity contract address
    /// @param investor Investor address
    /// @return Identity contract address
    function getIdentity(address investor) external view returns (address) {
        return _getIdentity(investor);
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
