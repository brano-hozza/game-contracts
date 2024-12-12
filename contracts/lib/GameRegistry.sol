// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GameRegistry is Ownable {
    struct AssetPermission {
        bool isRegistered;
        bytes32[] allowedAttributes;
    }

    struct GameData {
        bool isRegistered;
        // Mapping: asset contract address => permissions
        mapping(address => AssetPermission) assetPermissions;
        uint256 registrationTime;
        address registeredBy;
    }

    // Mapping: game address => game data
    mapping(address => GameData) private games;
    address[] public registeredGames;

    event GameRegistered(address indexed game, address indexed registeredBy);
    event GameUnregistered(address indexed game, address indexed unregisteredBy);
    event AssetPermissionGranted(
        address indexed game, 
        address indexed assetContract, 
        bytes32[] attributes
    );
    event AssetPermissionRevoked(
        address indexed game, 
        address indexed assetContract
    );

    constructor() Ownable(msg.sender){}

    /**
     * @notice Register a new game
     * @param game Address of the game to register
     */
    function registerGame(address game) external onlyOwner {
        require(game != address(0), "Invalid game address");
        require(!games[game].isRegistered, "Game already registered");
        
        games[game].isRegistered = true;
        games[game].registrationTime = block.timestamp;
        games[game].registeredBy = msg.sender;
        
        registeredGames.push(game);
        emit GameRegistered(game, msg.sender);
    }

    /**
     * @notice Grant permission to a game for specific asset contract attributes
     * @param game Address of the game
     * @param assetContract Address of the asset contract
     * @param attributes Array of attribute IDs the game can modify
     */
    function grantAssetPermission(
        address game,
        address assetContract,
        bytes32[] calldata attributes
    ) external onlyOwner {
        require(games[game].isRegistered, "Game not registered");
        require(assetContract != address(0), "Invalid asset contract");
        require(attributes.length > 0, "No attributes specified");

        AssetPermission storage permission = games[game].assetPermissions[assetContract];
        permission.isRegistered = true;
        permission.allowedAttributes = attributes;

        emit AssetPermissionGranted(game, assetContract, attributes);
    }

    /**
     * @notice Revoke a game's permission for an asset contract
     * @param game Address of the game
     * @param assetContract Address of the asset contract
     */
    function revokeAssetPermission(
        address game,
        address assetContract
    ) external onlyOwner {
        require(games[game].isRegistered, "Game not registered");
        require(games[game].assetPermissions[assetContract].isRegistered, "Asset not registered for game");

        delete games[game].assetPermissions[assetContract];
        emit AssetPermissionRevoked(game, assetContract);
    }

    /**
     * @notice Check if a game is registered
     * @param game Address of the game to check
     */
    function isGameRegistered(address game) external view returns (bool) {
        return games[game].isRegistered;
    }

    /**
     * @notice Get allowed attributes for a game and asset contract
     * @param game Address of the game
     * @param assetContract Address of the asset contract
     * @return Array of allowed attribute IDs
     */
    function getGamePermissions(
        address game,
        address assetContract
    ) external view returns (bytes32[] memory) {
        require(games[game].isRegistered, "Game not registered");
        require(games[game].assetPermissions[assetContract].isRegistered, "Asset not registered for game");
        
        return games[game].assetPermissions[assetContract].allowedAttributes;
    }

    /**
     * @notice Check if a game has permission for specific attributes on an asset contract
     * @param game Address of the game
     * @param assetContract Address of the asset contract
     * @param attributes Array of attribute IDs to check
     * @return bool indicating if the game has all specified permissions
     */
    function hasPermissions(
        address game,
        address assetContract,
        bytes32[] calldata attributes
    ) external view returns (bool) {
        if (!games[game].isRegistered || !games[game].assetPermissions[assetContract].isRegistered) {
            return false;
        }

        bytes32[] storage allowedAttrs = games[game].assetPermissions[assetContract].allowedAttributes;
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

    /**
     * @notice Get all asset contracts a game has permissions for
     * @param game Address of the game
     * @return Array of asset contract addresses
     */
    function getGameAssetContracts(address game) external view returns (address[] memory) {
        require(games[game].isRegistered, "Game not registered");
        
        // First count how many asset contracts the game has permissions for
        uint256 count = 0;
        for (uint i = 0; i < registeredGames.length; i++) {
            if (games[game].assetPermissions[registeredGames[i]].isRegistered) {
                count++;
            }
        }
        
        // Create and fill the array
        address[] memory assetContracts = new address[](count);
        uint256 index = 0;
        for (uint i = 0; i < registeredGames.length; i++) {
            if (games[game].assetPermissions[registeredGames[i]].isRegistered) {
                assetContracts[index] = registeredGames[i];
                index++;
            }
        }
        
        return assetContracts;
    }
}