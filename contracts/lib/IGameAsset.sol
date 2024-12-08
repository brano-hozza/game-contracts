// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IGameAsset
 * @dev Core interface for game assets with cross-game compatibility
 */
interface IGameAsset is IERC165, IERC721 {
    /// @dev Emitted when an attribute is modified by a registered game
    event AttributeModified(uint256 indexed tokenId, address indexed game, bytes32 indexed attributeId, bytes value);
    
    /// @dev Emitted when a game registers to interact with assets
    event GameRegistered(address indexed game, bytes32[] supportedAttributes);
    
    /// @notice Register a game to interact with assets
    /// @param supportedAttributes List of attribute IDs the game can modify
    function registerGame(bytes32[] calldata supportedAttributes) external;
    
    /// @notice Set attributes for a token
    /// @param tokenId The ID of the token to modify
    /// @param attributes List of attribute IDs to modify
    /// @param values List of values for each attribute
    function setAttributes(uint256 tokenId, bytes32[] calldata attributes, bytes[] calldata values) external;
    
    /// @notice Get attributes for a token
    /// @param tokenId The ID of the token to query
    /// @param attributes List of attribute IDs to query
    function getAttributes(uint256 tokenId, bytes32[] calldata attributes) external view returns (bytes[] memory);

    /// @notice Check if a token exists
    /// @param tokenId The ID of the token to check
    /// @return bool whether the token exists
    function exists(uint256 tokenId) external view returns (bool);
}
