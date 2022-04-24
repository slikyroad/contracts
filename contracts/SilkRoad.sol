//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./tokens/RandomizedCollection.sol";
import "./interfaces/IERC721Standard.sol";

// TODO: Unit Tests
contract SilkRoad is Initializable, AccessControlUpgradeable {
    event NFTCreated(address indexed owner, address indexed nft);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // owner => list of nfts mapping
    mapping(address => address[]) public nfts;
    // id => nft mapping
    mapping(string => address) public registry;

    IERC721Standard controller;
    
    mapping(string => address) randomContract;
    string[] public randomContracts;


    function initialize(string memory name, address _randomContract) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        addRandomContract(name, _randomContract);
    }

    function addRandomContract(string memory name, address _randomContract) public {
        randomContract[name] = _randomContract;
        randomContracts.push(name);
    }

    function getRandomContractsLists() public view returns (string[] memory) {
        return randomContracts;
    }

    function createNft(
        uint256 _maxTokens,
        string memory _id,
        string memory _name,
        string memory _symbol,
        string memory _randomContractName
    ) public {
        require(registry[_id] == address(0), "Contract with ID already exists");
        address nftOwner = _msgSender();
        RandomizedCollection nft;        
        require(randomContract[_randomContractName] != address(0), 'Unknown random contract');
        nft = new RandomizedCollection(_maxTokens, _name, _symbol, nftOwner, randomContract[_randomContractName]);
        address nftAddress = address(nft);
        nfts[nftOwner].push(nftAddress);
        registry[_id] = nftAddress;
        emit NFTCreated(nftOwner, nftAddress);
    }
}
