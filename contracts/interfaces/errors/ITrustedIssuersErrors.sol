// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITrustedIssuersErrors - Custom errors interface for TrustedIssuers domain
/// @notice Contains all custom errors related to trusted issuers management
/// @dev This interface centralizes all trusted issuers-related errors for better documentation and gas efficiency
interface ITrustedIssuersErrors {
    /// @notice Thrown when trying to add a trusted issuer that already exists
    /// @param issuer The issuer that already exists
    error TrustedIssuerAlreadyExists(address issuer);

    /// @notice Thrown when trying to access a trusted issuer that doesn't exist
    /// @param issuer The issuer that doesn't exist
    error TrustedIssuerNotFound(address issuer);

    /// @notice Thrown when providing zero address for issuer
    error ZeroAddress();

    /// @notice Thrown when providing empty claim topics array
    error EmptyClaimTopics();

    /// @notice Thrown when a non-authorized address tries to manage trusted issuers
    /// @param caller The unauthorized caller address
    error Unauthorized(address caller);

    /// @notice Thrown when trying to set claim topics for an invalid issuer
    /// @param issuer The invalid issuer address
    error InvalidIssuer(address issuer);
}
