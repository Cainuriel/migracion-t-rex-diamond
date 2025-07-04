// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITokenErrors - Custom errors interface for Token domain
/// @notice Contains all custom errors related to token operations
/// @dev This interface centralizes all token-related errors for better documentation and gas efficiency
interface ITokenErrors {
    /// @notice Thrown when trying to transfer from a frozen account
    /// @param account The frozen account address
    error AccountFrozen(address account);

    /// @notice Thrown when trying to transfer more tokens than available
    /// @param available The available balance
    /// @param requested The requested transfer amount
    error InsufficientBalance(uint256 available, uint256 requested);

    /// @notice Thrown when trying to approve or transfer to zero address
    error ZeroAddress();

    /// @notice Thrown when trying to transfer zero amount
    error ZeroAmount();

    /// @notice Thrown when trying to perform an operation with insufficient allowance
    /// @param available The available allowance
    /// @param requested The requested amount
    error InsufficientAllowance(uint256 available, uint256 requested);
}
