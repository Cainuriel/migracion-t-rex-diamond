// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title RolesStorage - Unstructured storage for Roles domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct RolesStorage {
    // === ACCESS CONTROL ===
    address owner;
    mapping(address => bool) agents;
    bool initialized;
}

/// @title LibRolesStorage - Library for Roles domain storage access
library LibRolesStorage {    /// @dev Storage slot for Roles domain    /// @dev Storage slot for Roles domain
    bytes32 internal constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    function rolesStorage() internal pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }
}
