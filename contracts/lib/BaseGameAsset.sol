// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IGameAsset.sol";
import "./IGameRegistry.sol";
/**
 * @title BaseGameAsset
 * @dev Abstract implementation of IGameAsset with core functionality
 */
abstract contract BaseGameAsset is IGameAsset {
    // Registry of games and their permissions
    IGameRegistry public immutable registry;
    
    // Attribute storage
    mapping(uint256 => mapping(bytes32 => bytes)) private _attributes;
    
    // Token existence mapping
    mapping(uint256 => bool) private _tokenExists;
    
    constructor(address registryAddress) {
        registry = IGameRegistry(registryAddress);
    }


    /// @dev Internal function to check if a token exists
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenExists[tokenId];
    }

    /// @dev External function to check if a token exists
    function exists(uint256 tokenId) external view override returns (bool) {
        return _exists(tokenId);
    }
    
    /// @notice Modifier to check if game is registered and has permission
    modifier onlyRegisteredGame(bytes32[] calldata attributes) {
        require(registry.isGameRegistered(msg.sender), "Game not registered");
        bytes32[] memory permissions = registry.getGamePermissions(msg.sender);
        for (uint i = 0; i < attributes.length; i++) {
            bool hasPermission = false;
            for (uint j = 0; j < permissions.length; j++) {
                if (attributes[i] == permissions[j]) {
                    hasPermission = true;
                    break;
                }
            }
            require(hasPermission, "Missing permission");
        }
        _;
    }
    
    function setAttributes(
        uint256 tokenId,
        bytes32[] calldata attributes,
        bytes[] calldata values
    ) external override onlyRegisteredGame(attributes) {
        require(attributes.length == values.length, "Length mismatch");
        require(_exists(tokenId), "Token doesn't exist");
        
        for (uint i = 0; i < attributes.length; i++) {
            _attributes[tokenId][attributes[i]] = values[i];
            emit AttributeModified(tokenId, msg.sender, attributes[i], values[i]);
        }
    }
    
    function getAttributes(
        uint256 tokenId,
        bytes32[] calldata attributes
    ) external view override returns (bytes[] memory) {
        require(_exists(tokenId), "Token doesn't exist");
        
        bytes[] memory values = new bytes[](attributes.length);
        for (uint i = 0; i < attributes.length; i++) {
            values[i] = _attributes[tokenId][attributes[i]];
        }
        return values;
    }
}
