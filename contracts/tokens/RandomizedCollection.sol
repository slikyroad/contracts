// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/IERC721Standard.sol";
import "../interfaces/ISilkRandom.sol";
import "hardhat/console.sol";

contract RandomizedCollection is AccessControl, ERC721Enumerable, IERC721Standard {
    event Minted(uint256 indexed tokenId, address indexed owner);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => string) public uri;

    mapping(address => uint[]) public ownerTokens;

    address owner;

    uint256 price;

    uint256 public maxTokens;
    uint256 private randomLength;

    uint256 public tokensCount;
    uint256[] public tokens;
    mapping(uint256 => bool) minted;

    ISilkRandom private randomContract; // address of SilkRandom contract
    uint256 private currentTokenId;

    constructor(
        uint256 _maxTokens,
        uint256 _price,
        string memory _name,
        string memory _symbol,
        address _owner,
        address _randomContract
    ) ERC721(_name, _symbol) {
        require(_randomContract != address(0));

        maxTokens = _maxTokens;
        price = _price;
        owner = _owner;

        if (maxTokens > 0) {
            tokens = new uint256[](maxTokens);
            randomLength = maxTokens;
        }

        randomContract = ISilkRandom(_randomContract);
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(MINTER_ROLE, _owner);
        _setupRole(MINTER_ROLE, _msgSender());
    }

    // ========== ADMIN FUNCTIONS ==========

    function mint() external payable virtual override {
        require(msg.value >= price, "Price too low");
        _safeMint(msg.sender);
    }

    function setTokenUri(uint256 _tokenId, string memory _uri) external virtual override {
        require(bytes(_uri).length > 0, "Invalid URI");
        address _owner = ownerOf(_tokenId);
        require(msg.sender == _owner);

        uri[_tokenId] = _uri;
    }

    function withdraw() external override {
        (bool successFee, ) = payable(owner).call{value: address(this).balance}("");

        require(successFee, "Withdrawal Failed");
    }

    function batchMint(uint256 howMany) external payable virtual override {
        require(howMany <= 20, "Not more than 20 at a time");
        require(howMany * price >= msg.value, "Price too low");
        for (uint256 i = 0; i < howMany; i++) {
            _safeMint(msg.sender);
        }
    }

    // ========== VIEW FUNCTIONS ==========
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return uri[_tokenId];
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl, IERC165)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    // ========== INTERNAL FUNCTIONS ==========

    /**
        One problem with random tokenId is how to check if a tokenId is already generated. 
        Even with a random algorithm like SilkRandom collisions still happen. S
        o you need to check tokens[] to be sure that the random tokenId is not already in the list. 
        The only way to do this in solidity is to loop over the array and we all know why that's a problem: Gas.
        The algorithm below is a way to avoid looping over the tokens[] array and at the same time avoid collision

        Say for token length of 5, tokens start out as [0, 0, 0, 0, 0];

        1st time _getTokenId is called let's say randomPosition is 2.            
            tokens[2] = 2 
            _tokenId = 2
            _temp = 2
            maxPosition = 4
            tokens[4] = 4 
            after swap
                tokens = [0, 0, 4, 0, 2]
            randomLength = 4 
        2nd time _getTokenId is called let's say randomPosition is 2 again, i.e a collision 
            tokens[2] = 4
            _tokenId = 4
            _temp = 4
            maxPosition = 3
            tokens[3] = 3
            after swap
                tokens = [0, 0, 3, 4, 2]
            randomLength = 3
        3rd time _getTokenId is called let's say randomPosition is 1
            tokens[1] = 1
            _tokenId = 1
            _temp = 1
            maxPosition = 2
            tokens[2] = 3
            after swap
                tokens = [0, 3, 1, 4, 2]
            randomLength = 2       
        4th time _getTokenId is called let's say randomPosition is 0
            tokens[0] = 0
            _tokenId = 0
            _temp = 0
            maxPosition = 1
            tokens[1] = 3
            after swap
                tokens = [3, 0, 1, 4, 2]
            randomLength = 1
        5th time _getTokenId is called let's say randomPosition can only be 0, randomPosition = randomNumber % 1 ==> 0;
            tokens[0] = 3
            _tokenId = 3
            _temp = 3
            maxPosition = 0
            tokens[0] = 3
            after swap
                tokens = [3, 0, 1, 4, 2]
            randomLength = 0
        6th time _getTokenId is called, it reverts with 'Can not mint. All tokens already minted'
     */
    function _getTokenId() internal returns (uint256) {
        require(randomLength > 0, "Can not mint. All tokens already minted");

        uint256 randomNumber = randomContract.random() % randomLength;

        uint256 randomPosition = uint256(randomNumber % randomLength);
        if (randomPosition != 0 && tokens[randomPosition] == 0) {
            tokens[randomPosition] = randomPosition;
        }

        uint256 _tokenId = tokens[randomPosition];

        uint256 _temp = tokens[randomPosition];
        uint256 maxPosition = randomLength - 1;

        if (tokens[maxPosition] == 0) {
            tokens[maxPosition] = maxPosition;
        }

        tokens[randomPosition] = tokens[maxPosition];
        tokens[maxPosition] = _temp;
        randomLength = maxPosition;

        return _tokenId;
    }

    function _safeMint(address _to) internal {        
        require(_to != address(0), "Invalid Address");

        uint256 _tokenId;
        if (maxTokens > 0) {
            _tokenId = _getTokenId();
            require(minted[_tokenId] == false, "Can not mint. Try again");
            minted[_tokenId] = true;
            super._safeMint(_to, _tokenId);
        } else {
            _tokenId = currentTokenId;
            currentTokenId++;
            tokens[_tokenId] = _tokenId;
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
}
