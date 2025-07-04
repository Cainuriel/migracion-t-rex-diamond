// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IRolesErrors - Custom errors interface for Roles domain
/// @notice Contains all custom errors related to roles and access control
/// @dev This interface centralizes all roles-related errors for better documentation and gas efficiency
interface IRolesErrors {
    /// @notice Thrown when a non-authorized address tries to perform a restricted operation
    /// @param caller The unauthorized caller address
    error Unauthorized(address caller);

    /// @notice Thrown when trying to transfer ownership to zero address
    error ZeroAddress();

    /// @notice Thrown when trying to set the same owner again
    /// @param currentOwner The current owner address
    error SameOwner(address currentOwner);

    /// @notice Thrown when trying to add an agent that is already an agent
    /// @param agent The agent address
    error AgentAlreadySet(address agent);

    /// @notice Thrown when trying to remove an agent that is not an agent
    /// @param agent The agent address
    error AgentNotSet(address agent);
}
