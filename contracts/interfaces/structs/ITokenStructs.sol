// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITokenStructs - Transport structs interface for Token domain
/// @notice Contains all transport structs related to token operations
/// @dev This interface centralizes token-related structs for better organization and reusability
interface ITokenStructs {
    /// @notice Struct for token transfer parameters
    /// @param from Source address
    /// @param to Destination address
    /// @param amount Amount to transfer
    struct TransferParams {
        address from;
        address to;
        uint256 amount;
    }

    /// @notice Struct for token approval parameters
    /// @param owner Token owner address
    /// @param spender Approved spender address
    /// @param amount Approved amount
    struct ApprovalParams {
        address owner;
        address spender;
        uint256 amount;
    }

    /// @notice Struct for batch transfer operations
    /// @param recipients Array of recipient addresses
    /// @param amounts Array of amounts to transfer
    struct BatchTransferParams {
        address[] recipients;
        uint256[] amounts;
    }

    /// @notice Struct for token metadata
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param decimals Token decimals
    struct TokenMetadata {
        string name;
        string symbol;
        uint8 decimals;
    }
}
