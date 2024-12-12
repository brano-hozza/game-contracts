// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BaseMultiGameImplementation
 * @dev Abstract contract for game-specific implementations supporting multiple asset types
 */
abstract contract BaseGameImplementation {
    // Mapping of asset type to asset contract address
    mapping(bytes32 => address) public assetContracts;
    
    // Mapping of asset contract address to allowed attributes
    mapping(address => bytes32[]) public allowedAttributes;
    
    // Array of all supported asset types
    bytes32[] public supportedAssetTypes;

    event AssetContractRegistered(bytes32 indexed assetType, address indexed assetContract);
    event AssetContractRemoved(bytes32 indexed assetType, address indexed assetContract);

    /**
     * @dev Register a new asset contract for a specific asset type
     * @param assetType Type of the asset (e.g., "WEAPON", "ARMOR")
     * @param assetContract Address of the asset contract
     * @param attributes Allowed attributes for this asset type
     */
    function _registerAssetContract(
        bytes32 assetType,
        address assetContract,
        bytes32[] memory attributes
    ) internal virtual {
        require(assetContract != address(0), "Invalid asset contract");
        require(assetContracts[assetType] == address(0), "Asset type already registered");
        
        assetContracts[assetType] = assetContract;
        allowedAttributes[assetContract] = attributes;
        supportedAssetTypes.push(assetType);
        
        emit AssetContractRegistered(assetType, assetContract);
    }

    /**
     * @dev Remove an asset contract
     * @param assetType Type of the asset to remove
     */
    function _removeAssetContract(bytes32 assetType) internal virtual {
        address assetContract = assetContracts[assetType];
        require(assetContract != address(0), "Asset type not registered");
        
        delete assetContracts[assetType];
        delete allowedAttributes[assetContract];
        
        // Remove from supportedAssetTypes array
        for (uint i = 0; i < supportedAssetTypes.length; i++) {
            if (supportedAssetTypes[i] == assetType) {
                supportedAssetTypes[i] = supportedAssetTypes[supportedAssetTypes.length - 1];
                supportedAssetTypes.pop();
                break;
            }
        }
        
        emit AssetContractRemoved(assetType, assetContract);
    }

    /**
     * @dev Get asset contract for a specific type
     * @param assetType Type of the asset
     * @return Address of the asset contract
     */
    function getAssetContract(bytes32 assetType) public view returns (address) {
        return assetContracts[assetType];
    }

    /**
     * @dev Get allowed attributes for an asset contract
     * @param assetContract Address of the asset contract
     * @return Array of allowed attribute IDs
     */
    function getAllowedAttributes(address assetContract) public view returns (bytes32[] memory) {
        return allowedAttributes[assetContract];
    }

    /**
     * @dev Get all supported asset types
     * @return Array of supported asset types
     */
    function getSupportedAssetTypes() public view returns (bytes32[] memory) {
        return supportedAssetTypes;
    }
}