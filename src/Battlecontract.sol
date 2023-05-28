// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.14;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";

contract Battlecontract is ERC721, ERC721Enumerable, Ownable, Pausable {
    uint256 public constant MAX_SUPPLY = 100000;
    string public baseURI;
    address public expectedAddress = 0x0000000000000000000000000000000000000000;
    uint256 public maxMint = 0;

    error MaxSupplyReached();
    event BaseURIChanged(string previousBaseURI, string newBaseURI);

    constructor() ERC721("Battlecontract", "BTLC") {
        baseURI = "https://olympusclash.io/api/v1/collections/battle-nfts/metadata/";
    }

    function setExpectedAddress(address _address) public onlyOwner {
        expectedAddress = _address;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        string memory previousBaseURI = baseURI;
        baseURI = baseURI_;
        emit BaseURIChanged(previousBaseURI, baseURI_);
    }

    function mint_Battle(address _from, address _owner, uint256 atokenId) public {
        require(_from == expectedAddress, "Sender is not the expected contract address");
        if (atokenId >= maxMint) {
            maxMint = atokenId;
        }
        _safeMint(_owner, atokenId);
    }

    function mint_unminted(address _address) public onlyOwner {
        for (uint256 i = 1; i < maxMint; i++) {
            if (!_exists(i)) {
                _safeMint(_address, i);
            }
        }
    }

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        }

        uint256[] memory tokens = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokens;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
