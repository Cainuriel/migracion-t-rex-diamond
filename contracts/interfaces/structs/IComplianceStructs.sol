// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IComplianceStructs - Transport structs interface for Compliance domain
/// @notice Contains all transport structs related to compliance operations
/// @dev This interface centralizes compliance-related structs for better organization and reusability
interface IComplianceStructs {
    /// @notice Struct for compliance rule configuration
    /// @param maxBalance Maximum balance allowed per investor
    /// @param minBalance Minimum balance required per investor
    /// @param maxInvestors Maximum number of investors allowed
    struct ComplianceRules {
        uint256 maxBalance;
        uint256 minBalance;
        uint256 maxInvestors;
    }

    /// @notice Struct for transfer compliance check parameters
    /// @param from Source address
    /// @param to Destination address
    /// @param amount Transfer amount
    struct TransferComplianceParams {
        address from;
        address to;
        uint256 amount;
    }

    /// @notice Struct for compliance check result
    /// @param isCompliant Whether the operation is compliant
    /// @param reason Reason for non-compliance (if any)
    /// @param errorCode Error code for non-compliance
    struct ComplianceCheckResult {
        bool isCompliant;
        string reason;
        uint256 errorCode;
    }

    /// @notice Struct for batch compliance configuration
    /// @param rules Array of compliance rules
    /// @param enabled Array of enabled status for each rule
    struct BatchComplianceConfig {
        ComplianceRules[] rules;
        bool[] enabled;
    }
}
