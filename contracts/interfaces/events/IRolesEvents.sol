// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IRolesEvents - Events interface for Roles domain
/// @notice Contains all events related to roles and ownership management
/// @dev This interface centralizes all roles-related events for better documentation and clarity
interface IRolesEvents {
    /// @notice Emitted when ownership is transferred
    /// @param previousOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when an agent status is set
    /// @param agent The address of the agent
    /// @param status True if the agent is being added, false if being removed
    event AgentSet(address indexed agent, bool status);
}
