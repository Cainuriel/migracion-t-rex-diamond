// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title BaseStorageAccessor - Abstract base contract for Diamond Storage access
/// @dev Provides common patterns and utilities for Diamond Storage implementation
/// @dev This contract defines the foundation for type-safe storage access across all facets
abstract contract BaseStorageAccessor {
    
    // ================== STORAGE CONSTANTS ==================
    
    /// @dev Namespace prefix for T-REX Diamond storage slots
    string private constant NAMESPACE_PREFIX = "t-rex.diamond";
    
    /// @dev Storage version for future migrations
    uint256 internal constant STORAGE_VERSION = 1;
    
    // ================== ABSTRACT STORAGE FUNCTIONS ==================
    
    /// @notice Get storage slot hash for a domain
    /// @param domain The storage domain name (e.g., "token", "roles")
    /// @return slot The computed storage slot hash
    function _getStorageSlot(string memory domain) internal pure returns (bytes32 slot) {
        slot = keccak256(abi.encodePacked(NAMESPACE_PREFIX, ".", domain, ".storage"));
    }
    
    /// @notice Get versioned storage slot hash for a domain
    /// @param domain The storage domain name
    /// @param version The storage version
    /// @return slot The computed versioned storage slot hash
    function _getVersionedStorageSlot(string memory domain, uint256 version) internal pure returns (bytes32 slot) {
        slot = keccak256(abi.encodePacked(NAMESPACE_PREFIX, ".", domain, ".storage.v", version));
    }
    
    // ================== STORAGE VALIDATION ==================
    
    /// @notice Validate that storage is properly initialized
    /// @param storagePointer The storage pointer to validate
    /// @param domain The domain name for error messages
    modifier validateStorage(bytes32 storagePointer, string memory domain) {
        require(storagePointer != bytes32(0), string(abi.encodePacked("BaseStorageAccessor: Invalid ", domain, " storage")));
        _;
    }
    
    // ================== UTILITIES ==================
    
    /// @notice Check if an address is the zero address
    /// @param addr The address to check
    /// @return True if the address is zero
    function _isZeroAddress(address addr) internal pure returns (bool) {
        return addr == address(0);
    }
    
    /// @notice Require that an address is not zero
    /// @param addr The address to check
    /// @param errorMessage Custom error message
    function _requireNotZero(address addr, string memory errorMessage) internal pure {
        require(!_isZeroAddress(addr), errorMessage);
    }
    
    // ================== STORAGE INTROSPECTION ==================
    
    /// @notice Get the current storage version
    /// @return The current storage version
    function getStorageVersion() external pure returns (uint256) {
        return STORAGE_VERSION;
    }
    
    /// @notice Get the namespace prefix used for storage slots
    /// @return The namespace prefix
    function getStorageNamespace() external pure returns (string memory) {
        return NAMESPACE_PREFIX;
    }
}
