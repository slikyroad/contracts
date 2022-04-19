// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/IERC721Standard.sol";

interface IPOSDAORandom {
    function collectRoundLength() external view returns (uint256);

    function currentSeed() external view returns (uint256);
}

contract ERC721Standard is AccessControl, ERC721Enumerable, IERC721Standard {
    event Minted(uint256 indexed tokenId, address indexed owner);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => string) public uri;

    uint256 public constant UNIT = 1e18;

    address owner;

    uint256 public maxTokens;
    uint256 public tokensCount;
    uint256[] public tokens;
    mapping(uint256 => bool) minted;

    IPOSDAORandom private posdaoRandomContract; // address of RandomAuRa contract
    uint256 private seed;
    uint256 private seedLastBlock;
    uint256 private updateInterval;

    uint256 private currentTokenId;

    constructor(
        uint256 _maxTokens,
        string memory _name,
        string memory _symbol,
        address _owner,
        address _randomContract
    ) ERC721(_name, _symbol) {
        require(_randomContract != address(0));

        maxTokens = _maxTokens;

        if (maxTokens > 0) {
            tokens = new uint256[](maxTokens);
        }

        posdaoRandomContract = IPOSDAORandom(_randomContract);
        seed = posdaoRandomContract.currentSeed();
        seedLastBlock = block.number;
        updateInterval = posdaoRandomContract.collectRoundLength();

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(MINTER_ROLE, _owner);
        _setupRole(MINTER_ROLE, _msgSender());
    }

    // ========== ADMIN FUNCTIONS ==========

    function mint(address _to, string memory _uri) external virtual override {
        _safeMint(_to, _uri);
    }

    function batchMint(address[] memory _to, string[] memory _uri) external virtual {
        require(_to.length == _uri.length, "Invalid params");
        require(_to.length <= 20, "Not more than 20 at a time");
        for (uint256 i = 0; i < _to.length; i++) {
            _safeMint(_to[i], _uri[i]);
        }
    }

    // ========== VIEW FUNCTIONS ==========
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return uri[_tokenId];
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721Enumerable, AccessControl, IERC165) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    // ========== INTERNAL FUNCTIONS ==========

    function _safeMint(address _to, string memory _uri) internal {
        require(bytes(_uri).length > 0, "Invalid URI");
        require(_to != address(0), "Invalid Address");

        uint256 _tokenId;
        if (maxTokens > 0) {
            _tokenId = seed % (maxTokens + tokens.length + block.number);

            if (_wasSeedUpdated()) {
                _tokenId = seed % maxTokens;
            }
            
            if (tokens.length < maxTokens) {
                require(minted[_tokenId] == false, "Can not mint. Try again");
                // mint tokenId (indexing and ids start from 0)
                tokens[_tokenId] = _tokenId;
                uri[_tokenId] = _uri;             
                minted[_tokenId] = true;          
                super._safeMint(_to, _tokenId);                         
            } else if (tokens.length > maxTokens) {
                revert("All tokens Minted");
            }
        } else {
            _tokenId = currentTokenId;
            currentTokenId++;
            tokens[_tokenId] = _tokenId;
            uri[_tokenId] = _uri;
            minted[_tokenId] = true;       
            super._safeMint(_to, _tokenId);            
        }

        emit Minted(_tokenId, _to);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _wasSeedUpdated() private returns (bool) {
        if (block.number - seedLastBlock <= updateInterval) {
            return false;
        }

        updateInterval = posdaoRandomContract.collectRoundLength();

        uint256 remoteSeed = posdaoRandomContract.currentSeed();
        if (remoteSeed != seed) {
            seed = remoteSeed;
            seedLastBlock = block.number;
            return true;
        }
        return false;
    }
}
