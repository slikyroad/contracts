// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISilkRandom {
    function updateBatchSize(uint256 batchSize) external;
    function random() external returns (uint256 rnd);
    function randomWithSalt(uint256 salt) external returns (uint256 rnd);
    function batchRandom() external returns (uint256[] memory rnd);
    function batchRandomWithSalt(uint256 salt) external returns (uint256[] memory rnd);

    event SeedUpdated(address indexed who, bytes32 indexed oldSeed, bytes32 indexed newSeed);
    event BatchSizeUpdated(address indexed who);
    event RandomNumber(bytes32 indexed seed, uint256 randomNumber);
}