// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITrustedIssuersStorage - Interface for TrustedIssuers domain storage structure
/// @dev Defines the storage layout for TrustedIssuers domain using Diamond Storage pattern
interface ITrustedIssuersStorage {
    /// @title TrustedIssuersStorage - Unstructured storage for TrustedIssuers domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct TrustedIssuersStorage {
        // === TRUSTED ISSUERS ===
        mapping(uint256 => address[]) trustedIssuers; // claimTopic => issuer addresses
        mapping(address => mapping(uint256 => bool)) issuerStatus; // issuer => claimTopic => trusted
        mapping(uint256 => uint256) issuerCount; // claimTopic => count of trusted issuers
    }
}
