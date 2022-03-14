//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./tokens/ERC721Standard.sol";
import "./interfaces/IERC721Standard.sol";

contract SilkRoad is Initializable, AccessControlUpgradeable {
    event NFTCreated(address owner, address nft);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // owner => list of nfts mapping
    mapping(address => address[]) nfts;
    // id => nft mapping
    mapping(string => address) registry;

    IERC721Standard controller;

    // 0x5452c62412E12B87e29D8E5ef72783ADE4de93a4 - RandomAura
    address randomContract;

    function initialize(address _randomContract) public initializer {        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        randomContract = _randomContract;
    }

    function createNft(
        uint256 _maxTokens,
        string memory _id,
        string memory _name,
        string memory _symbol,
        string memory _randomType
    ) public {
        require(registry[_id] == address(0), "Contract with ID already exists");
        address nftOwner = _msgSender();
        ERC721Standard nft;
        if(keccak256(abi.encodePacked(_randomType)) == keccak256(abi.encodePacked("RandomAuRa"))) {
            nft = new ERC721Standard(_maxTokens, _name, _symbol, nftOwner, randomContract);
        } else {
            revert("random type not recognized");
        }
        address nftAddress = address(nft);
        nfts[nftOwner].push(nftAddress);
        registry[_id] = nftAddress;
        emit NFTCreated(nftOwner, nftAddress);
    }
}
