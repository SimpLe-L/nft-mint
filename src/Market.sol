// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Markets {
    uint256 private _indexCounter;

    struct Market {
        address seller;
        uint256 tokenId;
        uint256 index;
        uint256 price;
        string uri;
        bool active;
    }
    Market[] public markets;
    mapping(uint256 => Market) tokenIdToMarket;
    mapping(address => uint) tokenIdToPrice;
    address internal nftMint;

    constructor(address _nft) {
        nftMint = _nft;
    }

    function hasActive(uint256 _tokenId) public view returns (bool) {
        return tokenIdToMarket[_tokenId].active;
    }

    //上架
    function shelve(uint256 _tokenId, uint256 _price) public {
        require(
            IERC721(nftMint).ownerOf(_tokenId) == msg.sender,
            "The is Owner?"
        );
        require(!hasActive(_tokenId), "Alread on shelves");
        require(
            IERC721(nftMint).getApproved(_tokenId) == address(this) ||
                IERC721(nftMint).isApprovedForAll(msg.sender, address(this)),
            "No approve"
        );
        require(_price > 0, "Price must be greater than 0");

        uint256 index = _indexCounter;
        _indexCounter++;

        string memory uri = ERC721(nftMint).tokenURI(_tokenId);
        Market memory newMarket = Market(
            msg.sender,
            _tokenId,
            index,
            _price,
            uri,
            true
        );
        markets.push(newMarket);
        tokenIdToMarket[_tokenId] = newMarket;
    }

    function unShelve(uint256 _tokenId) public {
        require(
            IERC721(nftMint).ownerOf(_tokenId) == msg.sender,
            "Ths is owner"
        );
        require(hasActive(_tokenId), "Removed from shelves");

        _unShelve(_tokenId);
    }

    function _unShelve(uint256 _tokenId) internal {
        Market memory market = tokenIdToMarket[_tokenId];
        delete markets[market.index];
        delete tokenIdToMarket[_tokenId];
    }

    function allMarkets() public view returns (Market[] memory allMarketNft) {
        if (markets.length == 0) {
            return new Market[](0);
        }

        uint256 count = 0;
        for (uint i = 0; i < markets.length; i++) {
            Market memory market = markets[i];
            if (market.active) {
                count++;
            }
        }

        uint j = 0;
        allMarketNft = new Market[](count);
        for (uint i = 0; i < markets.length; i++) {
            if (markets[i].active) {
                allMarketNft[j] = markets[i];
                j++;
            }
            if (j >= count) {
                return allMarketNft;
            }
        }
    }

    function buy(uint256 _tokenId) public payable {
        Market memory market = tokenIdToMarket[_tokenId];
        require(msg.value >= market.price, "Price error");
        require(msg.sender != market.seller, "Address error");
        require(market.active, "No market");

        _unShelve(_tokenId);

        tokenIdToPrice[market.seller] = msg.value;

        IERC721(nftMint).safeTransferFrom(market.seller, msg.sender, _tokenId);
    }

    function withdraw() public {
        uint balance = tokenIdToPrice[msg.sender];
        require(balance > 0, "No price");
        tokenIdToPrice[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "withdraw error");
    }
}
