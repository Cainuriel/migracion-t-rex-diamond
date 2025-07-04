// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { TokenStorageAccessor } from "./TokenStorageAccessor.sol";
import { RolesStorageAccessor } from "./RolesStorageAccessor.sol";
import { ComplianceStorageAccessor } from "./ComplianceStorageAccessor.sol";

/// @title MultiDomainStorageAccessor - Unified access to multiple storage domains
/// @dev Provides coordinated access to Token, Roles, and Compliance storage domains
/// @dev Useful for facets that need to interact with multiple storage domains
abstract contract MultiDomainStorageAccessor is 
    TokenStorageAccessor, 
    RolesStorageAccessor, 
    ComplianceStorageAccessor 
{
    
    // ================== CROSS-DOMAIN VALIDATION ==================
    
    /// @notice Validate all storage domains are properly initialized
    /// @dev Comprehensive validation across all storage domains
    function _validateAllStorageDomains() internal view {
        _validateTokenStorage();
        _validateRolesStorage();
        _validateComplianceStorage();
    }
    
    /// @notice Check if all core storage domains are initialized
    /// @return True if Token, Roles, and Compliance storage are all initialized
    function _areAllDomainsInitialized() internal view returns (bool) {
        return _isTokenStorageInitialized() && 
               _isRolesStorageInitialized() && 
               _isComplianceStorageInitialized();
    }
    
    // ================== CROSS-DOMAIN OPERATIONS ==================
    
    /// @notice Validate a transfer operation across all relevant domains
    /// @param from The sender address
    /// @param to The recipient address
    /// @param amount The transfer amount
    /// @return True if transfer is valid across all domains
    function _validateTransfer(address from, address to, uint256 amount) internal view returns (bool) {
        // Validate addresses
        if (_isZeroAddress(from) || _isZeroAddress(to)) {
            return false;
        }
        
        // Check if accounts are frozen (Compliance domain)
        if (_isInvestorFrozen(from) || _isInvestorFrozen(to)) {
            return false;
        }
        
        // Check sender balance (Token domain)
        if (_getBalance(from) < amount) {
            return false;
        }
        
        // Check if resulting balance would be compliant (Compliance domain)
        uint256 newBalance = _getBalance(to) + amount;
        if (!_isBalanceCompliant(newBalance)) {
            return false;
        }
        
        // Check investor count limits if this creates a new investor
        if (_getBalance(to) == 0 && !_isInvestorCountCompliant()) {
            return false;
        }
        
        return true;
    }
    
    /// @notice Check if an account can perform privileged operations
    /// @param account The account to check
    /// @return True if account has sufficient privileges
    function _hasPrivilegedAccess(address account) internal view returns (bool) {
        return _isOwnerOrAgent(account);
    }
    
    // ================== EMERGENCY FUNCTIONS ==================
    
    /// @notice Emergency validation of all storage integrity
    /// @dev Should be called during critical operations or upgrades
    function _emergencyStorageCheck() internal view {
        // Validate all domains
        _validateAllStorageDomains();
        
        // Additional cross-domain checks
        require(_areAllDomainsInitialized(), "MultiDomainStorageAccessor: Not all domains initialized");
    }
    
    // ================== STORAGE MIGRATION SUPPORT ==================
    
    /// @notice Get migration readiness status
    /// @return ready True if all domains are ready for migration
    /// @return domainStatus Array indicating readiness of each domain
    function _getMigrationReadiness() internal view returns (bool ready, bool[3] memory domainStatus) {
        domainStatus[0] = _isTokenStorageInitialized();
        domainStatus[1] = _isRolesStorageInitialized();
        domainStatus[2] = _isComplianceStorageInitialized();
        
        ready = domainStatus[0] && domainStatus[1] && domainStatus[2];
    }
    
    // ================== INTROSPECTION ==================
    
    /// @notice Get comprehensive storage status
    /// @return token True if Token storage is initialized
    /// @return roles True if Roles storage is initialized
    /// @return compliance True if Compliance storage is initialized
    function getStorageStatus() external view returns (
        bool token,
        bool roles,
        bool compliance
    ) {
        token = _isTokenStorageInitialized();
        roles = _isRolesStorageInitialized();
        compliance = _isComplianceStorageInitialized();
    }
}
