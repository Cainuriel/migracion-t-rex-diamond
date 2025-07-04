// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITrustedIssuersStructs - Transport structs interface for TrustedIssuers domain
/// @notice Contains all transport structs related to trusted issuers management
/// @dev This interface centralizes trusted issuers-related structs for better organization and reusability
interface ITrustedIssuersStructs {
    /// @notice Struct for trusted issuer configuration
    /// @param issuer Issuer address
    /// @param claimTopics Array of claim topics the issuer is trusted for
    /// @param isActive Whether the issuer is active
    struct TrustedIssuerConfig {
        address issuer;
        uint256[] claimTopics;
        bool isActive;
    }

    /// @notice Struct for batch trusted issuer operations
    /// @param issuers Array of issuer addresses
    /// @param claimTopics Array of claim topics arrays
    /// @param isActive Array of active status
    struct BatchTrustedIssuerConfig {
        address[] issuers;
        uint256[][] claimTopics;
        bool[] isActive;
    }

    /// @notice Struct for issuer verification parameters
    /// @param issuer Issuer address to verify
    /// @param claimTopic Specific claim topic to verify for
    /// @param investorIdentity Investor's identity contract
    struct IssuerVerificationParams {
        address issuer;
        uint256 claimTopic;
        address investorIdentity;
    }

    /// @notice Struct for trusted issuer information
    /// @param issuer Issuer address
    /// @param claimTopics Array of claim topics
    /// @param isRegistered Whether the issuer is registered
    /// @param registrationDate Timestamp of registration
    struct TrustedIssuerInfo {
        address issuer;
        uint256[] claimTopics;
        bool isRegistered;
        uint256 registrationDate;
    }
}
