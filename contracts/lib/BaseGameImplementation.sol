// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IGameAsset.sol";

/**
 * @title BaseGameImplementation
 * @dev Abstract contract for game-specific implementations
 */
abstract contract BaseGameImplementation {
    IGameAsset public immutable assetContract;
    
    constructor(address assetAddress) {
        assetContract = IGameAsset(assetAddress);
    }
    
    /// @dev Convert game-specific attributes to base format
    function _encodeAttributes(bytes32[] memory attributes, bytes[] memory values)
        internal
        pure
        virtual
        returns (bytes memory);
    
    /// @dev Convert base format to game-specific attributes
    function _decodeAttributes(bytes memory data)
        internal
        pure
        virtual
        returns (bytes32[] memory attributes, bytes[] memory values);
}