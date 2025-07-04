// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITokenStorage - Interface for Token domain storage structure
/// @dev Defines the storage layout for Token domain using Diamond Storage pattern
interface ITokenStorage {
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
}
