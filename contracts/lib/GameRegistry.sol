// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IGameRegistry.sol";

/**
 * @title GameRegistry
 * @dev Implementation of IGameRegistry for managing game registrations and permissions
 */
contract GameRegistry is IGameRegistry, Ownable {
    // Struct to store game registration data
    struct GameData {
        bool isRegistered;
        bytes32[] allowedAttributes;
        uint256 registrationTime;
        address registeredBy;
    }

    // Mapping of game addresses to their registration data
    mapping(address => GameData) private games;
    
    // Array to keep track of all registered games
    address[] public registeredGames;

    constructor() Ownable(msg.sender){}

    // Events
    event GameRegistered(address indexed game, address indexed registeredBy, bytes32[] attributes);
    event GameUnregistered(address indexed game, address indexed unregisteredBy);
    event AttributesUpdated(address indexed game, bytes32[] attributes);

    /**
     * @notice Register a new game
     * @param game Address of the game contract
     * @param attributes List of attributes the game can modify
     */
    function registerGame(address game, bytes32[] calldata attributes) external onlyOwner {
        require(game != address(0), "Invalid game address");
        require(!games[game].isRegistered, "Game already registered");
        require(attributes.length > 0, "No attributes specified");

        games[game] = GameData({
            isRegistered: true,
            allowedAttributes: attributes,
            registrationTime: block.timestamp,
            registeredBy: msg.sender
        });

        registeredGames.push(game);
        
        emit GameRegistered(game, msg.sender, attributes);
    }

    /**
     * @notice Unregister a game
     * @param game Address of the game contract to unregister
     */
    function unregisterGame(address game) external onlyOwner {
        require(games[game].isRegistered, "Game not registered");

        delete games[game];

        // Remove from registeredGames array
        for (uint i = 0; i < registeredGames.length; i++) {
            if (registeredGames[i] == game) {
                registeredGames[i] = registeredGames[registeredGames.length - 1];
                registeredGames.pop();
                break;
            }
        }

        emit GameUnregistered(game, msg.sender);
    }

    /**
     * @notice Update allowed attributes for a registered game
     * @param game Address of the game contract
     * @param attributes New list of allowed attributes
     */
    function updateGameAttributes(address game, bytes32[] calldata attributes) external onlyOwner {
        require(games[game].isRegistered, "Game not registered");
        require(attributes.length > 0, "No attributes specified");

        games[game].allowedAttributes = attributes;
        
        emit AttributesUpdated(game, attributes);
    }

    /**
     * @notice Check if a game is registered
     * @param game Address of the game contract
     * @return bool indicating if the game is registered
     */
    function isGameRegistered(address game) external view override returns (bool) {
        return games[game].isRegistered;
    }

    /**
     * @notice Get attributes a game can modify
     * @param game Address of the game contract
     * @return Array of attribute IDs the game can modify
     */
    function getGamePermissions(address game) external view override returns (bytes32[] memory) {
        require(games[game].isRegistered, "Game not registered");
        return games[game].allowedAttributes;
    }

    /**
     * @notice Get registration data for a game
     * @param game Address of the game contract
     * @return isRegistered Registration status
     * @return attributes Allowed attributes
     * @return registrationTime Time of registration
     * @return registeredBy Address that registered the game
     */
    function getGameData(address game) external view returns (
        bool isRegistered,
        bytes32[] memory attributes,
        uint256 registrationTime,
        address registeredBy
    ) {
        GameData memory data = games[game];
        return (
            data.isRegistered,
            data.allowedAttributes,
            data.registrationTime,
            data.registeredBy
        );
    }

    /**
     * @notice Get all registered games
     * @return Array of registered game addresses
     */
    function getAllRegisteredGames() external view returns (address[] memory) {
        return registeredGames;
    }

    /**
     * @notice Check if a game has permission for specific attributes
     * @param game Address of the game contract
     * @param attributes Attributes to check
     * @return bool indicating if the game has permission for all attributes
     */
    function hasPermissions(address game, bytes32[] calldata attributes) external view returns (bool) {
        if (!games[game].isRegistered) return false;
        
        bytes32[] memory allowedAttrs = games[game].allowedAttributes;
        for (uint i = 0; i < attributes.length; i++) {
            bool hasPermission = false;
            for (uint j = 0; j < allowedAttrs.length; j++) {
                if (attributes[i] == allowedAttrs[j]) {
                    hasPermission = true;
                    break;
                }
            }
            if (!hasPermission) return false;
        }
        return true;
    }
}