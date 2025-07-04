// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IIdentityStorage - Interface for Identity domain storage structure
/// @dev Defines the storage layout for Identity domain using Diamond Storage pattern
interface IIdentityStorage {
    /// @title IdentityStorage - Unstructured storage for Identity domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct IdentityStorage {
        // === IDENTITY MAPPING ===
        mapping(address => address) investorIdentities; // investor => identity contract
        mapping(address => uint16) investorCountries; // investor => country code
        mapping(address => bool) verificationStatus; // investor => verified
    }
}
