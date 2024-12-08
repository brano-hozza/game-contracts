// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IGameRegistry
 * @dev Interface for managing game registrations and permissions
 */
interface IGameRegistry {
    /// @notice Check if a game is registered
    function isGameRegistered(address game) external view returns (bool);
    
    /// @notice Get attributes a game can modify
    function getGamePermissions(address game) external view returns (bytes32[] memory);
}
