// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IIdentityErrors - Custom errors interface for Identity domain
/// @notice Contains all custom errors related to identity operations
/// @dev This interface centralizes all identity-related errors for better documentation and gas efficiency
interface IIdentityErrors {
    /// @notice Thrown when trying to register an already registered investor
    /// @param investor The investor address
    error AlreadyRegistered(address investor);

    /// @notice Thrown when trying to access an unregistered investor
    /// @param investor The investor address
    error NotRegistered(address investor);

    /// @notice Thrown when providing zero address for investor or identity
    error ZeroAddress();

    /// @notice Thrown when the identity contract is invalid
    /// @param identity The invalid identity address
    error InvalidIdentity(address identity);

    /// @notice Thrown when the country code is invalid
    /// @param country The invalid country code
    error InvalidCountry(uint16 country);
}
