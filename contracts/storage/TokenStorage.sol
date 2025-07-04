// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title TokenStorage - Unstructured storage for Token domain
/// @dev Uses Diamond Storage pattern with unique storage slot
struct TokenStorage {
    // === TOKEN CORE ERC20 ===
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    
    // === TOKEN ERC-3643 EXTENSIONS ===
    mapping(address => bool) frozenAccounts;
    address[] holders; // Track all token holders for compliance
}

/// @title LibTokenStorage - Library for Token domain storage access
library LibTokenStorage {    /// @dev Storage slot for Token domain
    bytes32 internal constant TOKEN_STORAGE_POSITION = keccak256("t-rex.diamond.token.storage");

    function tokenStorage() internal pure returns (TokenStorage storage ts) {
        bytes32 position = TOKEN_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }
}
