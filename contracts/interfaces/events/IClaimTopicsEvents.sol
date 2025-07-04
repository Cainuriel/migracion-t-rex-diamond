// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IClaimTopicsEvents - Events interface for ClaimTopics domain
/// @notice Contains all events related to claim topics management
/// @dev This interface centralizes all claim topics-related events for better documentation and clarity
interface IClaimTopicsEvents {
    /// @notice Emitted when a claim topic is added
    /// @param topic The topic identifier that was added
    event ClaimTopicAdded(uint256 indexed topic);

    /// @notice Emitted when a claim topic is removed
    /// @param topic The topic identifier that was removed
    event ClaimTopicRemoved(uint256 indexed topic);
}
