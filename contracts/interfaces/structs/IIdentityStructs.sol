// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IIdentityStructs - Transport structs interface for Identity domain
/// @notice Contains all transport structs related to identity operations
/// @dev This interface centralizes identity-related structs for better organization and reusability
interface IIdentityStructs {
    /// @notice Struct for investor registration parameters
    /// @param investor Investor address
    /// @param identity Identity contract address
    /// @param country Country code
    struct InvestorRegistration {
        address investor;
        address identity;
        uint16 country;
    }

    /// @notice Struct for batch investor registration
    /// @param investors Array of investor addresses
    /// @param identities Array of identity contract addresses
    /// @param countries Array of country codes
    struct BatchInvestorRegistration {
        address[] investors;
        address[] identities;
        uint16[] countries;
    }

    /// @notice Struct for identity verification status
    /// @param identity Identity contract address
    /// @param isVerified Whether the identity is verified
    /// @param verificationDate Timestamp of verification
    struct IdentityVerificationStatus {
        address identity;
        bool isVerified;
        uint256 verificationDate;
    }

    /// @notice Struct for investor information
    /// @param investor Investor address
    /// @param identity Identity contract address
    /// @param country Country code
    /// @param isRegistered Whether the investor is registered
    struct InvestorInfo {
        address investor;
        address identity;
        uint16 country;
        bool isRegistered;
    }
}
