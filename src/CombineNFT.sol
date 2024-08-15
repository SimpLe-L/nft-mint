// SPDX-License-Identifier: SEE LICENSE IN LICENSE
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
            "https://raw.githubusercontent.com/SimpLe-L/simp1e-blog/main/public/donkeys/";
    }

    function _setURI(uint256 _level) internal view returns (string memory uri) {
        uint random = _random(100);
        uri = string(
            abi.encodePacked(
                _level.toString(),
                "/images/",
                random.toString(),
                ".png"
            )
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

    function batchSafeMint(address _to, uint8 _val) public {
        require(_val <= 10, "MAX 10");
        for (uint i = 0; i < _val; i++) {
            _interSafeMint(_to, 0, 0, 0);
        }
    }

    function _interSafeMint(
        address _to,
        uint8 _level,
        uint256 _faId,
        uint256 _moId
    ) internal {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        string memory uri = string(
            abi.encodePacked(_baseURI(), _setURI(_level))
        );

        Horse memory horse = Horse(_to, tokenId, _level, _faId, _moId, uri);
        horses.push(horse);

        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _setURI(_level));
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
