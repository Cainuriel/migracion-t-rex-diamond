// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IComplianceEvents - Events interface for Compliance domain
/// @notice Contains all events related to compliance operations
/// @dev This interface centralizes all compliance-related events for better documentation and clarity
interface IComplianceEvents {
    /// @notice Emitted when the maximum balance limit is set
    /// @param max The new maximum balance allowed
    event MaxBalanceSet(uint256 max);

    /// @notice Emitted when the minimum balance limit is set
    /// @param min The new minimum balance required
    event MinBalanceSet(uint256 min);

    /// @notice Emitted when the maximum number of investors is set
    /// @param max The new maximum number of investors allowed
    event MaxInvestorsSet(uint256 max);
}
