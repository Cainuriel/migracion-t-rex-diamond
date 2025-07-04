// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITrustedIssuersEvents - Events interface for TrustedIssuers domain
/// @notice Contains all events related to trusted issuers management
/// @dev This interface centralizes all trusted issuers-related events for better documentation and clarity
interface ITrustedIssuersEvents {
    /// @notice Emitted when a trusted issuer is added
    /// @param issuer The address of the trusted issuer
    /// @param claimTopics Array of claim topics the issuer is trusted for
    event TrustedIssuerAdded(address indexed issuer, uint256[] claimTopics);

    /// @notice Emitted when a trusted issuer is removed
    /// @param issuer The address of the trusted issuer that was removed
    event TrustedIssuerRemoved(address indexed issuer);
}
