// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ComplianceStorage - Unstructured storage for Compliance domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct ComplianceStorage {
    // === COMPLIANCE LIMITS ===
    uint256 maxBalance;
    uint256 minBalance;
    uint256 maxInvestors;
    
    // === COMPLIANCE MODULES ===
    address[] complianceModules;
    mapping(address => bool) moduleStatus;
    
    // === INVESTOR COUNT ===
    uint256 currentInvestorCount;
}

/// @title LibComplianceStorage - Library for Compliance domain storage access
library LibComplianceStorage {
    /// @dev Storage slot for Compliance domain
    bytes32 internal constant COMPLIANCE_STORAGE_POSITION = keccak256("t-rex.diamond.compliance.storage");

    function complianceStorage() internal pure returns (ComplianceStorage storage cs) {
        bytes32 position = COMPLIANCE_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }
}
