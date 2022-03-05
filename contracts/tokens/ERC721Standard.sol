// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC721Standard is
    AccessControl,
    ERC721Enumerable
{
    uint256 public currentTokenId;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => string) public uri;

    uint256 public constant UNIT = 1e18;

    address owner;

    constructor(string memory _name, string memory _symbol, address _owner)
        ERC721(_name, _symbol)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(MINTER_ROLE, _owner);
        _setupRole(MINTER_ROLE, _msgSender());
    }    

    // ========== ADMIN FUNCTIONS ==========
    
    function mint(address _to, string memory _uri) external virtual {        
        require(hasRole(MINTER_ROLE, _msgSender()), "Only minter");
        _safeMint(_to, _uri);        
    }

    function batchMint(address[] memory _to, string[] memory _uri) external virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "Only minter");
        require(_to.length == _uri.length, "Invalid params");
        for (uint256 i = 0; i < _to.length; i++) {
            _safeMint(_to[i], _uri[i]);
        }
    }

    // ========== VIEW FUNCTIONS ==========
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return uri[_tokenId];
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    // ========== INTERNAL FUNCTIONS ==========

    function _safeMint(address _to, string memory _uri) internal {
        require(bytes(_uri).length > 0, "Invalid URI");
        require(_to != address(0), "Invalid Address");

        super._safeMint(_to, currentTokenId);

        uri[currentTokenId] = _uri;
        currentTokenId++;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
