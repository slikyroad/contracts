// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../interfaces/ISilkRandom.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract SilkRandom is ISilkRandom, AccessControlUpgradeable {
    uint256 private constant sufficientlyLargeNumber = 9007199254740991;

    bytes32 public seed;
    uint256 public batchSize;    

    // ============================ INITIALIZER ============================
    function initialize(uint256 initialSalt) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        batchSize = 10;
        seed = keccak256(
            abi.encodePacked(block.timestamp, initialSalt, msg.sender, seed)
        );
    }

    // ============================ PRIVILEGED METHODS ============================
    function updateBatchSize(uint256 _batchSize) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        batchSize = _batchSize;
        emit BatchSizeUpdated(msg.sender);
    }

    // ============================ PUBLIC METHODS ============================
    function random() external override returns (uint256) {
        return _random(1);
    }

    function randomWithSalt(uint256 salt) external override returns (uint256) {
        return _random(salt);
    }

    function batchRandom() external override returns (uint256[] memory) {
        return _batchRandom(1);
    }

    function batchRandomWithSalt(uint256 salt)
        external    
        override
        returns (uint256[] memory)
    {
        return _batchRandom(salt);
    }

    // ============================ PRIVATE METHODS ============================
    function _random(uint256 salt) internal returns (uint256) {
        uint256 rnd = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, salt, seed))
        ) % sufficientlyLargeNumber;

        bytes32 oldSeed = seed;
        seed = keccak256(abi.encodePacked(block.timestamp, msg.sender, salt, oldSeed, rnd));
        emit SeedUpdated(msg.sender, oldSeed, seed);
        emit RandomNumber(oldSeed, rnd);
        return rnd;
    }

    function _batchRandom(uint256 salt) internal returns (uint256[] memory) {
        uint256[] memory rands = new uint256[](batchSize);

        for (uint256 i = 0; i < batchSize; i++) {
            rands[i] = _random(i + salt);
        }

        return  rands;
    }
}
