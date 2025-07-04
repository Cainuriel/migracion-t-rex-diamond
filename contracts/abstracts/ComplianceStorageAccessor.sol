// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { BaseStorageAccessor } from "./BaseStorageAccessor.sol";
import { IComplianceStorage } from "../interfaces/storage/IComplianceStorage.sol";

/// @title ComplianceStorageAccessor - Specialized storage accessor for Compliance domain
/// @dev Provides type-safe access to Compliance storage using Diamond Storage pattern
/// @dev Inherits common storage utilities from BaseStorageAccessor
abstract contract ComplianceStorageAccessor is BaseStorageAccessor, IComplianceStorage {
    
    // ================== STORAGE CONSTANTS ==================
    
    /// @dev Storage domain name for Compliance
    string private constant COMPLIANCE_DOMAIN = "compliance";
    
    /// @dev Computed storage slot for Compliance domain
    bytes32 private constant COMPLIANCE_STORAGE_SLOT = keccak256("t-rex.diamond.compliance.storage");
    
    // ================== STORAGE ACCESS ==================
    
    /// @notice Get Compliance storage reference with validation
    /// @return cs Compliance storage struct reference
    function _getComplianceStorage() internal pure returns (ComplianceStorage storage cs) {
        bytes32 slot = COMPLIANCE_STORAGE_SLOT;
        assembly {
            cs.slot := slot
        }
    }
    
    /// @notice Get Compliance storage reference using computed slot
    /// @return cs Compliance storage struct reference
    function _getComplianceStorageComputed() internal pure returns (ComplianceStorage storage cs) {
        bytes32 slot = _getStorageSlot(COMPLIANCE_DOMAIN);
        assembly {
            cs.slot := slot
        }
    }
    
    // ================== STORAGE UTILITIES ==================
    
    /// @notice Check if Compliance storage is initialized
    /// @return True if storage is initialized
    function _isComplianceStorageInitialized() internal view returns (bool) {
        // Compliance is considered initialized if any rule is set
        ComplianceStorage storage cs = _getComplianceStorage();
        return cs.maxBalance > 0 || cs.minBalance > 0 || cs.maxInvestors > 0;
    }
    
    /// @notice Get maximum balance limit safely
    /// @return The maximum balance limit (0 = no limit)
    function _getMaxBalance() internal view returns (uint256) {
        return _getComplianceStorage().maxBalance;
    }
    
    /// @notice Get minimum balance requirement safely
    /// @return The minimum balance requirement
    function _getMinBalance() internal view returns (uint256) {
        return _getComplianceStorage().minBalance;
    }
    
    /// @notice Get maximum investors limit safely
    /// @return The maximum investors limit (0 = no limit)
    function _getMaxInvestors() internal view returns (uint256) {
        return _getComplianceStorage().maxInvestors;
    }
    
    /// @notice Get current investor count safely
    /// @return The current number of investors
    function _getCurrentInvestorCount() internal view returns (uint256) {
        return _getComplianceStorage().currentInvestorCount;
    }
    
    /// @notice Check if an investor is frozen safely
    /// @param investor The investor address to check
    /// @return True if the investor is frozen
    function _isInvestorFrozen(address investor) internal view returns (bool) {
        if (_isZeroAddress(investor)) return false;
        return _getComplianceStorage().frozenInvestors[investor];
    }
    
    /// @notice Get last transfer time for an investor safely
    /// @param investor The investor address to check
    /// @return The timestamp of the last transfer
    function _getLastTransferTime(address investor) internal view returns (uint256) {
        if (_isZeroAddress(investor)) return 0;
        return _getComplianceStorage().lastTransferTime[investor];
    }
    
    // ================== COMPLIANCE VALIDATION ==================
    
    /// @notice Check if a balance amount complies with rules
    /// @param balance The balance amount to check
    /// @return True if balance complies with rules
    function _isBalanceCompliant(uint256 balance) internal view returns (bool) {
        ComplianceStorage storage cs = _getComplianceStorage();
        
        // Check minimum balance (if set)
        if (cs.minBalance > 0 && balance < cs.minBalance) {
            return false;
        }
        
        // Check maximum balance (if set)
        if (cs.maxBalance > 0 && balance > cs.maxBalance) {
            return false;
        }
        
        return true;
    }
    
    /// @notice Check if investor count complies with rules
    /// @return True if investor count complies with rules
    function _isInvestorCountCompliant() internal view returns (bool) {
        ComplianceStorage storage cs = _getComplianceStorage();
        
        // Check maximum investors (if set)
        if (cs.maxInvestors > 0 && cs.currentInvestorCount >= cs.maxInvestors) {
            return false;
        }
        
        return true;
    }
    
    // ================== STORAGE VALIDATION ==================
    
    /// @notice Validate Compliance storage state
    /// @dev Performs comprehensive validation of Compliance storage integrity
    function _validateComplianceStorage() internal view {
        ComplianceStorage storage cs = _getComplianceStorage();
        
        // Validate that limits are reasonable (if set)
        if (cs.maxBalance > 0 && cs.minBalance > 0) {
            require(cs.maxBalance >= cs.minBalance, "ComplianceStorageAccessor: Max balance must be >= min balance");
        }
        
        // Validate investor count
        require(cs.currentInvestorCount >= 0, "ComplianceStorageAccessor: Invalid investor count");
        
        if (cs.maxInvestors > 0) {
            require(cs.currentInvestorCount <= cs.maxInvestors, "ComplianceStorageAccessor: Investor count exceeds limit");
        }
    }
}
