// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract CombineNFT is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Strings for uint256;
    uint256 private _tokenIdCounter;
    Horse[] public horses;
    struct Horse {
        address owner;
        uint tokenId;
        uint8 level;
        uint faId;
        uint moId;
        string uri;
    }

    constructor() ERC721("Combine NFT ", "CN") {}

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://turquoise-real-jellyfish-905.mypinata.cloud/ipfs/bafybeicq2vb72wznqybo663ptmthuralk2ubwzwetl56zjphnylkqnqy3u/";
    }

    function _setURI(uint256 _level) internal view returns (string memory uri) {
        uint random = _random(100);
        uri = string(
            abi.encodePacked(_level.toString(), "/", random.toString(), ".png")
        );
    }

    function _random(uint _max) internal view returns (uint256) {
        uint random = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    block.timestamp,
                    block.coinbase,
                    gasleft()
                )
            )
        );
        return
            (random > block.number)
                ? (random - block.number) % _max
                : (block.number - random) % _max;
    }

    function safeMint(address _to) public {
        _interSafeMint(_to, 0, 0, 0);
    }

    function _interSafeMint(
        address _to,
        uint8 _level,
        uint256 _faId,
        uint256 _moId
    ) internal {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        string memory uriPart = _setURI(_level);
        string memory uri = string(abi.encodePacked(_baseURI(), uriPart));

        Horse memory horse = Horse(_to, tokenId, _level, _faId, _moId, uri);
        horses.push(horse);

        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, uriPart);
    }

    function getHorse(
        uint256 _tokenId
    ) public view returns (Horse memory horse) {
        horse = horses[_tokenId];
    }

    function getHorses(
        address _owner
    ) public view returns (Horse[] memory ownerHorse) {
        uint balance = balanceOf(_owner);
        ownerHorse = new Horse[](balance);
        for (uint i = 0; i < balance; i++) {
            uint index = tokenOfOwnerByIndex(_owner, i);
            ownerHorse[i] = horses[index];
        }
    }

    function combine(uint _faId, uint _moId) public {
        Horse memory father = horses[_faId];
        Horse memory mother = horses[_moId];
        require(
            father.owner == msg.sender && mother.owner == msg.sender,
            "Is Right Owner ?"
        );
        require(father.level == mother.level, "Level up failed");
        require(father.level < 3, "NFT MAX level is 3");
        _interSafeMint(
            msg.sender,
            father.level + 1,
            father.tokenId,
            mother.tokenId
        );
        // 销毁合成使用的两个NFT
        _burn(father.tokenId);
        _burn(mother.tokenId);
        delete horses[_faId];
        delete horses[_moId];
    }

    function updateOwner(address buyer, uint256 _tokenId) public {
        // 确保购买者不是零地址
        require(buyer != address(0), "Buyer address cannot be zero");
        // 更新 horses 数组中的所有者
        horses[_tokenId].owner = buyer;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }
}
