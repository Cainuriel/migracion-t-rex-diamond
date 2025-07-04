// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IRolesStorage - Interface for Roles domain storage structure
/// @dev Defines the storage layout for Roles domain using Diamond Storage pattern
interface IRolesStorage {
    /// @title RolesStorage - Unstructured storage for Roles domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }
}
