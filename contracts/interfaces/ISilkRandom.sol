// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISilkRandom {
    function updateSeed(uint256 salt) external;
    function updateBatchSize(uint256 batchSize) external;
    function random() external view returns (bytes32 seed, uint256 rnd);
    function randomWithSalt(uint256 salt) external view returns (bytes32 seed, uint256 rnd);
    function batchRandom() external view returns (bytes32 seed, uint256[] memory rnd);
    function batchRandomWithSalt(uint256 salt) external view returns (bytes32 seed, uint256[] memory rnd);

    event SeedUpdated(address indexed who, bytes32 indexed oldSeed, bytes32 indexed newSeed);
    event BatchSizeUpdated(address indexed who);
}