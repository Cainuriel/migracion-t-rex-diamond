// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IClaimTopicsStorage - Interface for ClaimTopics domain storage structure
/// @dev Defines the storage layout for ClaimTopics domain using Diamond Storage pattern
interface IClaimTopicsStorage {
    /// @title ClaimTopicsStorage - Unstructured storage for ClaimTopics domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct ClaimTopicsStorage {
        // === CLAIM TOPICS ===
        uint256[] claimTopics; // array of required claim topics
        mapping(uint256 => bool) requiredClaimTopics; // topic => required
    }
}
