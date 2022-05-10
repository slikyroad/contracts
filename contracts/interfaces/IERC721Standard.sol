//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IERC721Standard is IERC721Enumerable {
    function mint() external payable;
    function setTokenUri(uint256 _tokenId, string memory _uri) external;
    function batchMint(uint256 howMany)  external payable;
    function withdraw() external;
}