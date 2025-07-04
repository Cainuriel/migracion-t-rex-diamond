// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IComplianceStorage - Interface for Compliance domain storage structure
/// @dev Defines the storage layout for Compliance domain using Diamond Storage pattern
interface IComplianceStorage {
    /// @title ComplianceStorage - Unstructured storage for Compliance domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct ComplianceStorage {
        // === COMPLIANCE RULES ===
        uint256 maxBalance; // 0 = no limit
        uint256 minBalance; // minimum balance required
        uint256 maxInvestors; // 0 = no limit
        uint256 currentInvestorCount;
        
        // === TRANSFER VALIDATION ===
        mapping(address => uint256) lastTransferTime;
        mapping(address => bool) frozenInvestors;
    }
}
