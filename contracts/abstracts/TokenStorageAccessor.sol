// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { BaseStorageAccessor } from "./BaseStorageAccessor.sol";
import { ITokenStorage } from "../interfaces/storage/ITokenStorage.sol";

/// @title TokenStorageAccessor - Specialized storage accessor for Token domain
/// @dev Provides type-safe access to Token storage using Diamond Storage pattern
/// @dev Inherits common storage utilities from BaseStorageAccessor
abstract contract TokenStorageAccessor is BaseStorageAccessor, ITokenStorage {
    
    // ================== STORAGE CONSTANTS ==================
    
    /// @dev Storage domain name for Token
    string private constant TOKEN_DOMAIN = "token";
    
    /// @dev Computed storage slot for Token domain
    bytes32 private constant TOKEN_STORAGE_SLOT = keccak256("t-rex.diamond.token.storage");
    
    // ================== STORAGE ACCESS ==================
    
    /// @notice Get Token storage reference with validation
    /// @return ts Token storage struct reference
    function _getTokenStorage() internal pure returns (TokenStorage storage ts) {
        bytes32 slot = TOKEN_STORAGE_SLOT;
        assembly {
            ts.slot := slot
        }
    }
    
    /// @notice Get Token storage reference using computed slot
    /// @return ts Token storage struct reference
    function _getTokenStorageComputed() internal pure returns (TokenStorage storage ts) {
        bytes32 slot = _getStorageSlot(TOKEN_DOMAIN);
        assembly {
            ts.slot := slot
        }
    }
    
    // ================== STORAGE UTILITIES ==================
    
    /// @notice Check if Token storage is initialized
    /// @return True if storage is initialized (has a name)
    function _isTokenStorageInitialized() internal view returns (bool) {
        return bytes(_getTokenStorage().name).length > 0;
    }
    
    /// @notice Get current total supply safely
    /// @return The current total supply
    function _getTotalSupply() internal view returns (uint256) {
        return _getTokenStorage().totalSupply;
    }
    
    /// @notice Get balance of an address safely
    /// @param account The account to check
    /// @return The account balance
    function _getBalance(address account) internal view returns (uint256) {
        require(!_isZeroAddress(account), "TokenStorageAccessor: Cannot get balance of zero address");
        return _getTokenStorage().balances[account];
    }
    
    /// @notice Get allowance safely
    /// @param owner The owner address
    /// @param spender The spender address
    /// @return The allowance amount
    function _getAllowance(address owner, address spender) internal view returns (uint256) {
        require(!_isZeroAddress(owner), "TokenStorageAccessor: Cannot get allowance from zero address");
        require(!_isZeroAddress(spender), "TokenStorageAccessor: Cannot get allowance for zero address");
        return _getTokenStorage().allowances[owner][spender];
    }
    
    // ================== STORAGE VALIDATION ==================
    
    /// @notice Validate Token storage state
    /// @dev Performs comprehensive validation of Token storage integrity
    function _validateTokenStorage() internal view {
        TokenStorage storage ts = _getTokenStorage();
        
        // Validate basic token metadata
        require(bytes(ts.name).length > 0, "TokenStorageAccessor: Token name not set");
        require(bytes(ts.symbol).length > 0, "TokenStorageAccessor: Token symbol not set");
        require(ts.decimals > 0, "TokenStorageAccessor: Token decimals not set");
        
        // Additional validations can be added here
    }
}
