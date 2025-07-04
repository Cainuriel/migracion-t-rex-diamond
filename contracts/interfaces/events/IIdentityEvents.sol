// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IIdentityEvents - Events interface for Identity domain
/// @notice Contains all events related to identity management operations
/// @dev This interface centralizes all identity-related events for better documentation and clarity
interface IIdentityEvents {
    /// @notice Emitted when an investor identity is registered
    /// @param investor The address of the investor
    /// @param identity The address of the identity contract
    /// @param country The country code of the investor
    event IdentityRegistered(address indexed investor, address identity, uint16 country);

    /// @notice Emitted when an investor identity is updated
    /// @param investor The address of the investor
    /// @param newIdentity The address of the new identity contract
    event IdentityUpdated(address indexed investor, address newIdentity);

    /// @notice Emitted when an investor identity is removed
    /// @param investor The address of the investor whose identity is removed
    event IdentityRemoved(address indexed investor);

    /// @notice Emitted when an investor's country is updated
    /// @param investor The address of the investor
    /// @param country The new country code
    event CountryUpdated(address indexed investor, uint16 country);
}
