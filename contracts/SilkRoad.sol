//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./tokens/ERC721Standard.sol";

contract SilkRoad is Initializable, AccessControlUpgradeable {
    event NFTCreated(address owner, address nft);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");    
    // owner => list of nfts mapping
    mapping(address => address[]) nfts;
    mapping(string => address) registry;

    function initialize() public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function createNft(string memory id, string memory _name, string memory _symbol) public {
        require(registry[id] == address(0), "Contract with ID already exists");
        address nftOwner = msg.sender;
        ERC721Standard nft = new ERC721Standard(_name, _symbol, nftOwner);
        address nftAddress = address(nft);
        nfts[nftOwner].push(nftAddress);
        registry[id] = nftAddress;
        emit NFTCreated(nftOwner, nftAddress);
    }
}
