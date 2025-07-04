// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ClaimTopicsStorage - Unstructured storage for ClaimTopics domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct ClaimTopicsStorage {
    // === CLAIM TOPICS ===
    uint256[] claimTopics;
    mapping(uint256 => bool) requiredClaimTopics;
}

/// @title LibClaimTopicsStorage - Library for ClaimTopics domain storage access
library LibClaimTopicsStorage {
    /// @dev Storage slot for ClaimTopics domain
    bytes32 internal constant CLAIM_TOPICS_STORAGE_POSITION = keccak256("t-rex.diamond.claim-topics.storage");

    function claimTopicsStorage() internal pure returns (ClaimTopicsStorage storage cts) {
        bytes32 position = CLAIM_TOPICS_STORAGE_POSITION;
        assembly {
            cts.slot := position
        }
    }
}
