// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.14;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import { BattleInterface } from "./InterfaceBC.sol";
import { ZeusInterface } from "./InterfaceZS.sol";
import { PaymentInterface } from "./InterfacePC.sol";

contract OlympusClash is ERC721, ERC721Enumerable, ERC721Burnable, ReentrancyGuard, Pausable, Ownable {
    uint256 public constant MAX_SUPPLY = 100000;
    address public TREASURY = 0x0000000000000000000000000000000000000000;
    address public expectedAddress = 0x0000000000000000000000000000000000000000;
    uint256 public mintStartTimestamp;
    uint256 public mintPrice;
    string public baseURI;
    uint256 private tokenId = 0;
    address public BattleContractAddress = 0x0000000000000000000000000000000000000000;
    address public ZeusContractAddress = 0x0000000000000000000000000000000000000000;
    address public OlympusClashContractAddress = 0x0000000000000000000000000000000000000000;
    address public PaymentContractAddress = 0x0000000000000000000000000000000000000000;
    BattleInterface battle_interface = BattleInterface(BattleContractAddress);
    ZeusInterface zeus_interface = ZeusInterface(ZeusContractAddress);
    PaymentInterface payment_interface = PaymentInterface(PaymentContractAddress);

    error MaxSupplyReached();
    error InvalidAmount();
    error MintPriceNotPaid();
    error MintingNotStarted();
    error NonExistentTokenId();
    error ArrayLengthMismatch();
    error TransferFailed(address recipient);

    event MintPriceChanged(uint256 previousMintPrice, uint256 newMintPrice);
    event MintStartTimestampChanged(uint256 previousMintStartTimestamp, uint256 newMintStartTimestamp);
    event BaseURIChanged(string previousBaseURI, string newBaseURI);
    event Mint(address indexed minter, uint256 tokenId);

    constructor() ERC721("OlympusClash", "OLC") {
        mintStartTimestamp = 1668008000; // 2022-11-19T12:00:00Z
        mintPrice = 0.002 ether;
        baseURI = "https://olympusclash.io/api/v1/collections/olympus-clash/metadata/";
    }

    function setExpectedAddress(address _address) public onlyOwner {
        expectedAddress = _address;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint_from_expected(address _from, uint256 amount) public {
        require(_from == expectedAddress, "Sender is not the expected contract address");
        for (uint256 i = 0; i < amount; i++) {
            _mint(msg.sender);
        }
    }

    function _mint(address to) private {
        tokenId += 1;
        if (tokenId > MAX_SUPPLY) {
            revert MaxSupplyReached();
        }

        _safeMint(to, tokenId);
        emit Mint(msg.sender, tokenId);
    }

    function mint(uint256 amount) public payable whenNotPaused nonReentrant {
        if (block.timestamp < mintStartTimestamp) {
            revert MintingNotStarted();
        }

        if (amount == 0) {
            revert InvalidAmount();
        }

        uint256 totalMintPrice = amount * mintPrice;
        if (msg.value < totalMintPrice) {
            revert MintPriceNotPaid();
        }

        for (uint256 i = 0; i < amount; i++) {
            _mint(msg.sender);
        }

        payment_interface.deposit{value: totalMintPrice}();


        uint256 excessPayment = msg.value - totalMintPrice;
        if (excessPayment == 0) {
            return;
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

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        uint256 previousMintPrice = mintPrice;
        mintPrice = _mintPrice;
        emit MintPriceChanged(previousMintPrice, mintPrice);
    }

    function setMintStartTimestamp(uint256 _mintStartTimestamp) public onlyOwner {
        uint256 previousMintStartTimestamp = mintStartTimestamp;
        mintStartTimestamp = _mintStartTimestamp;
        emit MintStartTimestampChanged(previousMintStartTimestamp, mintStartTimestamp);
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        string memory previousBaseURI = baseURI;
        baseURI = baseURI_;
        emit BaseURIChanged(previousBaseURI, baseURI_);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{ value: balance }("");
        if (!success) {
            revert TransferFailed(msg.sender);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function burn_mint(address nft_owner, uint256 _tokenId) public {
        _burn(_tokenId);
        mint_Battlecontract(nft_owner, _tokenId);
    }

    function mint_Battlecontract(address the_nft_owner, uint256 the_tokenId) internal {
        battle_interface.mint_Battle(OlympusClashContractAddress, the_nft_owner, the_tokenId);
    }

    function burn_mint_for_luckyDraw(address nft_owner, uint256 _tokenId) public {
        _burn(_tokenId);
        luckyDraw_Zeuscontract(nft_owner);
    }

    function luckyDraw_Zeuscontract(address the_nft_owner) internal {
        zeus_interface.luckyDraw(the_nft_owner);
    }

    function setBattleAddress(address _address) public onlyOwner {
        BattleContractAddress = _address;
        battle_interface = BattleInterface(BattleContractAddress);
    }

    function setOlympusAddress(address _address) public onlyOwner {
        OlympusClashContractAddress = _address;
    }

    function setZeusAddress(address _address) public onlyOwner {
        ZeusContractAddress = _address;
        zeus_interface = ZeusInterface(ZeusContractAddress);
    }

    function setPaymentAddress(address _address) public onlyOwner {
        PaymentContractAddress = _address;
        payment_interface = PaymentInterface(PaymentContractAddress);
    }

    function setTreasuryAddress(address _address) public onlyOwner {
        TREASURY = _address;
    }
    

    function bulkTransfer(uint256[] memory tokenIds, address _to) public onlyOwner {
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _transfer(msg.sender, _to, tokenIds[i]);
        }
    }
}