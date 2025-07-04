// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IdentityStorage - Unstructured storage for Identity domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct IdentityStorage {
    // === IDENTITY DATA ===
    mapping(address => address) investorIdentities;
    mapping(address => uint16) investorCountries;
    mapping(address => bool) verificationStatus;
}

/// @title LibIdentityStorage - Library for Identity domain storage access
library LibIdentityStorage {
    /// @dev Storage slot for Identity domain
    bytes32 internal constant IDENTITY_STORAGE_POSITION = keccak256("t-rex.diamond.identity.storage");

    function identityStorage() internal pure returns (IdentityStorage storage ids) {
        bytes32 position = IDENTITY_STORAGE_POSITION;
        assembly {
            ids.slot := position
        }
    }
}
