// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/BaseGameImplementation.sol";

contract WoWGame is BaseGameImplementation {
    // Attribute IDs
    bytes32 public constant STAMINA = keccak256("wow.sword.stamina");
    bytes32 public constant HASTE = keccak256("wow.sword.haste");
    bytes32 public constant INTELLECT = keccak256("wow.sword.intellect");

     // Struct for WoW-specific attributes
    struct SwordAttributes {
        uint8 stamina;
        uint8 haste;
        uint8 intellect;
    }
    
    constructor(address assetAddress) BaseGameImplementation(assetAddress) {
        // Register supported attributes
        bytes32[] memory attributes = new bytes32[](3);
        attributes[0] = STAMINA;
        attributes[1] = HASTE;
        attributes[2] = INTELLECT;
        assetContract.registerGame(attributes);
    }
    
    function createSword(
        address to,
        uint256 tokenId,
        uint8 stamina,
        uint8 haste
    ) external {
        bytes32[] memory attrs = new bytes32[](2);
        attrs[0] = STAMINA;
        attrs[1] = HASTE;
        
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(stamina);
        values[1] = abi.encode(haste);
        
        assetContract.setAttributes(tokenId, attrs, values);
    }
    
    function enchantSword(uint256 tokenId, uint8 intellect) external {
        bytes32[] memory attrs = new bytes32[](1);
        attrs[0] = INTELLECT;
        
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(intellect);
        
        assetContract.setAttributes(tokenId, attrs, values);
    }
    
    function getSwordStats(uint256 tokenId) external view returns (
        uint8 stamina,
        uint8 haste,
        uint8 intellect
    ) {
        bytes32[] memory attrs = new bytes32[](3);
        attrs[0] = STAMINA;
        attrs[1] = HASTE;
        attrs[2] = INTELLECT;
        
        bytes[] memory values = assetContract.getAttributes(tokenId, attrs);
        
        return (
            abi.decode(values[0], (uint8)),
            abi.decode(values[1], (uint8)),
            abi.decode(values[2], (uint8))
        );
    }



    /// @dev Implementation of abstract method from BaseGameImplementation
    /// @param attributes Array of attribute IDs
    /// @param values Array of corresponding values
    function _encodeAttributes(
        bytes32[] memory attributes,
        bytes[] memory values
    ) internal pure virtual override returns (bytes memory) {
        // Create a SwordAttributes struct and encode it
        SwordAttributes memory swordAttrs = SwordAttributes(0, 0, 0);
        
        for (uint i = 0; i < attributes.length; i++) {
            if (attributes[i] == STAMINA) {
                swordAttrs.stamina = abi.decode(values[i], (uint8));
            } else if (attributes[i] == HASTE) {
                swordAttrs.haste = abi.decode(values[i], (uint8));
            } else if (attributes[i] == INTELLECT) {
                swordAttrs.intellect = abi.decode(values[i], (uint8));
            }
        }
        
        return abi.encode(swordAttrs);
    }

    /// @dev Implementation of abstract method from BaseGameImplementation
    /// @param data Encoded sword attributes
    function _decodeAttributes(
        bytes memory data
    ) internal pure virtual override returns (
        bytes32[] memory attributes,
        bytes[] memory values
    ) {
        SwordAttributes memory swordAttrs = abi.decode(data, (SwordAttributes));
        
        // Count non-zero attributes to determine array size
        uint8 attributeCount = 0;
        if (swordAttrs.stamina > 0) attributeCount++;
        if (swordAttrs.haste > 0) attributeCount++;
        if (swordAttrs.intellect > 0) attributeCount++;
        
        attributes = new bytes32[](attributeCount);
        values = new bytes[](attributeCount);
        
        uint8 index = 0;
        
        if (swordAttrs.stamina > 0) {
            attributes[index] = STAMINA;
            values[index] = abi.encode(swordAttrs.stamina);
            index++;
        }
        
        if (swordAttrs.haste > 0) {
            attributes[index] = HASTE;
            values[index] = abi.encode(swordAttrs.haste);
            index++;
        }
        
        if (swordAttrs.intellect > 0) {
            attributes[index] = INTELLECT;
            values[index] = abi.encode(swordAttrs.intellect);
            index++;
        }
    }
}