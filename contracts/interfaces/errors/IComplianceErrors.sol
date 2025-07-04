// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IComplianceErrors - Custom errors interface for Compliance domain
/// @notice Contains all custom errors related to compliance operations
/// @dev This interface centralizes all compliance-related errors for better documentation and gas efficiency
interface IComplianceErrors {
    /// @notice Thrown when a transfer would exceed the maximum balance limit
    /// @param account The account that would exceed the limit
    /// @param newBalance The balance that would be exceeded
    /// @param maxBalance The maximum allowed balance
    error MaxBalanceExceeded(address account, uint256 newBalance, uint256 maxBalance);

    /// @notice Thrown when a transfer would result in a balance below the minimum
    /// @param account The account that would be below the minimum
    /// @param newBalance The balance that would be below minimum
    /// @param minBalance The minimum required balance
    error MinBalanceViolated(address account, uint256 newBalance, uint256 minBalance);

    /// @notice Thrown when adding an investor would exceed the maximum number allowed
    /// @param currentInvestors The current number of investors
    /// @param maxInvestors The maximum allowed investors
    error MaxInvestorsExceeded(uint256 currentInvestors, uint256 maxInvestors);

    /// @notice Thrown when setting an invalid compliance parameter
    /// @param parameter The parameter name
    /// @param value The invalid value
    error InvalidComplianceParameter(string parameter, uint256 value);
}
