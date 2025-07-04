// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title IClaimTopicsErrors - Custom errors interface for ClaimTopics domain
/// @notice Contains all custom errors related to claim topics management
/// @dev This interface centralizes all claim topics-related errors for better documentation and gas efficiency
interface IClaimTopicsErrors {
    /// @notice Thrown when trying to add a claim topic that already exists
    /// @param topic The topic that already exists
    error ClaimTopicAlreadyExists(uint256 topic);

    /// @notice Thrown when trying to remove a claim topic that doesn't exist
    /// @param topic The topic that doesn't exist
    error ClaimTopicNotFound(uint256 topic);

    /// @notice Thrown when providing an invalid topic value
    /// @param topic The invalid topic value
    error InvalidClaimTopic(uint256 topic);

    /// @notice Thrown when a non-authorized address tries to manage claim topics
    /// @param caller The unauthorized caller address
    error Unauthorized(address caller);
}
