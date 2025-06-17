// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ClaimTopicsInternalFacet } from "./internal/ClaimTopicsInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title ClaimTopicsFacetExternal - External interface for ClaimTopics operations
/// @dev Exposes only public/external functions, inherits business logic from ClaimTopicsInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract ClaimTopicsFacetExternal is ClaimTopicsInternalFacet, IEIP2535Introspection {

    modifier onlyOwner() {
        _onlyOwner(msg.sender);
        _;
    }

    // ================== EXTERNAL CLAIM TOPICS FUNCTIONS ==================

    /// @notice Add a new claim topic requirement
    /// @param topic Topic identifier to add
    function addClaimTopic(uint256 topic) external onlyOwner {
        _addClaimTopic(topic);
    }

    /// @notice Remove a claim topic requirement
    /// @param topic Topic identifier to remove
    function removeClaimTopic(uint256 topic) external onlyOwner {
        _removeClaimTopic(topic);
    }

    /// @notice Get all required claim topics
    /// @return Array of claim topic identifiers
    function getClaimTopics() external view returns (uint256[] memory) {
        return _getClaimTopics();
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
        selectors_[--selectorsLength] = this.addClaimTopic.selector;
        selectors_[--selectorsLength] = this.removeClaimTopic.selector;
        selectors_[--selectorsLength] = this.getClaimTopics.selector;
    }
}
