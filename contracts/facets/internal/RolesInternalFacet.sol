// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IRolesEvents } from "../../interfaces/events/IRolesEvents.sol";

/// @title RolesInternalFacet - Internal business logic for Roles domain
/// @dev Contains all the business logic for role management and access control
/// @dev This facet is not directly exposed in the diamond interface
contract RolesInternalFacet is IRolesEvents {

    // ================== STORAGE STRUCTURES ==================

    /// @title RolesStorage - Unstructured storage for Roles domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }

    // ================== STORAGE ACCESS ==================

    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get Roles storage reference
    /// @return rs Roles storage struct
    function _getRolesStorage() private pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }

    // ================== INTERNAL ROLES OPERATIONS ==================

    /// @notice Internal function to initialize roles
    /// @param initialOwner Initial owner address
    function _setInitialOwner(address initialOwner) internal {
        require(initialOwner != address(0), "RolesInternal: owner is the zero address");
        RolesStorage storage rs = _getRolesStorage();
        
        // Ensure not already initialized
        require(rs.owner == address(0), "RolesInternal: already initialized");
        
        rs.owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    /// @notice Internal function to transfer ownership
    /// @param newOwner New owner address
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "RolesInternal: new owner is the zero address");
        RolesStorage storage rs = _getRolesStorage();
        
        address previousOwner = rs.owner;
        rs.owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /// @notice Internal function to set agent status
    /// @param agent Agent address
    /// @param status True to grant agent role, false to revoke
    function _setAgent(address agent, bool status) internal {
        require(agent != address(0), "RolesInternal: agent is the zero address");
        RolesStorage storage rs = _getRolesStorage();
        
        rs.agents[agent] = status;
        emit AgentSet(agent, status);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get current owner
    /// @return Owner address
    function _owner() internal view returns (address) {
        return _getRolesStorage().owner;
    }

    /// @notice Check if address is an agent
    /// @param addr Address to check
    /// @return True if address is an agent
    function _isAgent(address addr) internal view returns (bool) {
        return _getRolesStorage().agents[addr];
    }

    /// @notice Check if address is owner or agent
    /// @param addr Address to check
    /// @return True if address is owner or agent
    function _isAuthorized(address addr) internal view returns (bool) {
        RolesStorage storage rs = _getRolesStorage();
        return addr == rs.owner || rs.agents[addr];
    }

    // ================== INTERNAL MODIFIERS/CHECKS ==================

    /// @notice Internal check for owner-only functions
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == _owner(), "RolesInternal: Not owner");
    }

    /// @notice Internal check for owner or agent functions
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        require(_isAuthorized(caller), "RolesInternal: Not authorized");
    }
}
