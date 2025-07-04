// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ITokenEvents - Events interface for Token domain
/// @notice Contains all events related to token operations
/// @dev This interface centralizes all token-related events for better documentation and clarity
interface ITokenEvents {
    /// @notice Emitted when tokens are transferred from one account to another
    /// @param from The address tokens are transferred from
    /// @param to The address tokens are transferred to
    /// @param value The amount of tokens transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when an allowance is set
    /// @param owner The address that owns the tokens
    /// @param spender The address that is approved to spend the tokens
    /// @param value The amount of tokens approved
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Emitted when an account is frozen or unfrozen
    /// @param user The address of the account being frozen/unfrozen
    /// @param frozen True if the account is frozen, false if unfrozen
    event AccountFrozen(address indexed user, bool frozen);
}
