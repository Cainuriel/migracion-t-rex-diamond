// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title TrustedIssuersStorage - Unstructured storage for TrustedIssuers domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct TrustedIssuersStorage {
    // === TRUSTED ISSUERS ===
    mapping(uint256 => address[]) trustedIssuers; // claimTopic => issuer addresses
    mapping(address => mapping(uint256 => bool)) issuerStatus; // issuer => claimTopic => trusted
    mapping(uint256 => uint256) issuerCount; // claimTopic => count of trusted issuers
}

/// @title LibTrustedIssuersStorage - Library for TrustedIssuers domain storage access
library LibTrustedIssuersStorage {
    /// @dev Storage slot for TrustedIssuers domain
    bytes32 internal constant TRUSTED_ISSUERS_STORAGE_POSITION = keccak256("t-rex.diamond.trusted-issuers.storage");

    function trustedIssuersStorage() internal pure returns (TrustedIssuersStorage storage tis) {
        bytes32 position = TRUSTED_ISSUERS_STORAGE_POSITION;
        assembly {
            tis.slot := position
        }
    }
}
