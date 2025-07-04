// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IClaimTopicsStructs - Transport structs interface for ClaimTopics domain
/// @notice Contains all transport structs related to claim topics management
/// @dev This interface centralizes claim topics-related structs for better organization and reusability
interface IClaimTopicsStructs {
    /// @notice Struct for claim topic configuration
    /// @param topic Topic identifier
    /// @param required Whether the topic is required
    /// @param description Human-readable description of the topic
    struct ClaimTopicConfig {
        uint256 topic;
        bool required;
        string description;
    }

    /// @notice Struct for batch claim topic operations
    /// @param topics Array of topic identifiers
    /// @param required Array of required status
    struct BatchClaimTopicConfig {
        uint256[] topics;
        bool[] required;
    }

    /// @notice Struct for claim topic validation parameters
    /// @param topic Topic identifier to validate
    /// @param issuer Address of the claim issuer
    /// @param signature Signature of the claim
    struct ClaimTopicValidation {
        uint256 topic;
        address issuer;
        bytes signature;
    }

    /// @notice Struct for claim topic information
    /// @param topic Topic identifier
    /// @param isActive Whether the topic is active
    /// @param addedDate Timestamp when the topic was added
    struct ClaimTopicInfo {
        uint256 topic;
        bool isActive;
        uint256 addedDate;
    }
}
