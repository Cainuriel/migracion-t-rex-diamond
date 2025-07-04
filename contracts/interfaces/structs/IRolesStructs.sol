// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IRolesStructs - Transport structs interface for Roles domain
/// @notice Contains all transport structs related to roles and access control
/// @dev This interface centralizes roles-related structs for better organization and reusability
interface IRolesStructs {
    /// @notice Struct for role assignment parameters
    /// @param account Account address
    /// @param role Role identifier
    /// @param granted Whether the role is granted or revoked
    struct RoleAssignment {
        address account;
        bytes32 role;
        bool granted;
    }

    /// @notice Struct for batch role assignments
    /// @param accounts Array of account addresses
    /// @param roles Array of role identifiers
    /// @param granted Array of granted status
    struct BatchRoleAssignment {
        address[] accounts;
        bytes32[] roles;
        bool[] granted;
    }

    /// @notice Struct for agent configuration
    /// @param agent Agent address
    /// @param isActive Whether the agent is active
    /// @param permissions Agent permissions bitmask
    struct AgentConfig {
        address agent;
        bool isActive;
        uint256 permissions;
    }

    /// @notice Struct for ownership transfer parameters
    /// @param currentOwner Current owner address
    /// @param newOwner New owner address
    /// @param transferTime Timestamp of the transfer
    struct OwnershipTransfer {
        address currentOwner;
        address newOwner;
        uint256 transferTime;
    }
}
