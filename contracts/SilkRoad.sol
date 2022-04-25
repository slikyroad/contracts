//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./tokens/RandomizedCollection.sol";
import "./interfaces/IERC721Standard.sol";

// TODO: Unit Tests
// contract SilkRoad is Initializable, AccessControlUpgradeable {
contract SilkRoad is AccessControl {
    event CollectionCreated(address indexed owner, address indexed collection);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // owner => list of nfts mapping
    mapping(address => address[]) public nfts;
    // id => nft mapping
    mapping(string => address) public registry;

    IERC721Standard controller;

    mapping(string => address) public randomContract;
    string[] public randomContracts;

    // function initialize(string memory name, address _randomContract) public initializer {
    constructor(string memory name, address _randomContract) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        addRandomContract(name, _randomContract);
    }

    function addRandomContract(string memory name, address _randomContract) public {
        console.log("RCN: ", name);
        randomContract[name] = _randomContract;
        randomContracts.push(name);
    }

    function getRandomContractsLists() public view returns (string[] memory) {
        return randomContracts;
    }

    function createCollection(
        uint256 _maxTokens,
        uint256 _price,
        string memory _id,
        string memory _name,
        string memory _symbol,
        string memory _randomContractName
    ) public {
        require(registry[_id] == address(0), "Contract with ID already exists");
        address collectionOwner = _msgSender();
        require(randomContract[_randomContractName] != address(0), "Unknown random contract");
        RandomizedCollection collection = new RandomizedCollection(
            _maxTokens,
            _price,
            _name,
            _symbol,
            collectionOwner,
            randomContract[_randomContractName]
        );
        address collectionAddress = address(collection);
        nfts[collectionOwner].push(collectionAddress);
        registry[_id] = collectionAddress;
        emit CollectionCreated(collectionOwner, collectionAddress);
    }
}
