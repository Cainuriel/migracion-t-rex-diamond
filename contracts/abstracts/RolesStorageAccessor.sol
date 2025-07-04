// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { BaseStorageAccessor } from "./BaseStorageAccessor.sol";
import { IRolesStorage } from "../interfaces/storage/IRolesStorage.sol";

/// @title RolesStorageAccessor - Specialized storage accessor for Roles domain
/// @dev Provides type-safe access to Roles storage using Diamond Storage pattern
/// @dev Inherits common storage utilities from BaseStorageAccessor
abstract contract RolesStorageAccessor is BaseStorageAccessor, IRolesStorage {
    
    // ================== STORAGE CONSTANTS ==================
    
    /// @dev Storage domain name for Roles
    string private constant ROLES_DOMAIN = "roles";
    
    /// @dev Computed storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_SLOT = keccak256("t-rex.diamond.roles.storage");
    
    // ================== STORAGE ACCESS ==================
    
    /// @notice Get Roles storage reference with validation
    /// @return rs Roles storage struct reference
    function _getRolesStorage() internal pure returns (RolesStorage storage rs) {
        bytes32 slot = ROLES_STORAGE_SLOT;
        assembly {
            rs.slot := slot
        }
    }
    
    /// @notice Get Roles storage reference using computed slot
    /// @return rs Roles storage struct reference
    function _getRolesStorageComputed() internal pure returns (RolesStorage storage rs) {
        bytes32 slot = _getStorageSlot(ROLES_DOMAIN);
        assembly {
            rs.slot := slot
        }
    }
    
    // ================== STORAGE UTILITIES ==================
    
    /// @notice Check if Roles storage is initialized
    /// @return True if storage is initialized (has an owner)
    function _isRolesStorageInitialized() internal view returns (bool) {
        return !_isZeroAddress(_getRolesStorage().owner);
    }
    
    /// @notice Get current owner safely
    /// @return The current owner address
    function _getOwner() internal view returns (address) {
        return _getRolesStorage().owner;
    }
    
    /// @notice Check if an address is an agent safely
    /// @param account The account to check
    /// @return True if the account is an agent
    function _isAgent(address account) internal view returns (bool) {
        if (_isZeroAddress(account)) return false;
        return _getRolesStorage().agents[account];
    }
    
    /// @notice Check if an address is owner or agent
    /// @param account The account to check
    /// @return True if the account is owner or agent
    function _isOwnerOrAgent(address account) internal view returns (bool) {
        if (_isZeroAddress(account)) return false;
        RolesStorage storage rs = _getRolesStorage();
        return account == rs.owner || rs.agents[account];
    }
    
    // ================== AUTHORIZATION HELPERS ==================
    
    /// @notice Require that caller is the owner
    /// @param caller The address to check
    function _requireOwner(address caller) internal view {
        require(caller == _getOwner(), "RolesStorageAccessor: Not owner");
    }
    
    /// @notice Require that caller is an agent
    /// @param caller The address to check
    function _requireAgent(address caller) internal view {
        require(_isAgent(caller), "RolesStorageAccessor: Not agent");
    }
    
    /// @notice Require that caller is owner or agent
    /// @param caller The address to check
    function _requireOwnerOrAgent(address caller) internal view {
        require(_isOwnerOrAgent(caller), "RolesStorageAccessor: Not authorized");
    }
    
    // ================== STORAGE VALIDATION ==================
    
    /// @notice Validate Roles storage state
    /// @dev Performs comprehensive validation of Roles storage integrity
    function _validateRolesStorage() internal view {
        RolesStorage storage rs = _getRolesStorage();
        
        // Validate that owner is set
        require(!_isZeroAddress(rs.owner), "RolesStorageAccessor: Owner not set");
        
        // Validate that storage is marked as initialized
        require(rs.initialized, "RolesStorageAccessor: Storage not initialized");
    }
}
