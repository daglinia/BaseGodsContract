// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import "../src/OlympusClash.sol";
import "../src/Battlecontract.sol";
import "../forge-std/Test.sol";

contract OlympusClashTest is Test {
    OlympusClash nft;
    address alice;
    address bob;
    address treasury;
    uint256 mintPrice;
    uint256 initialSupply;
    uint256 tokken;
    address BattleContractAddress;

    Battlecontract battle_contract;

    function setUp() public {
        alice = address(1);
        bob = address(2);
        tokken = uint256(1);
        BattleContractAddress = address(3);

        vm.label(alice, "alice");
        vm.label(bob, "alice");
        vm.label(address(this), "deployer");

        nft = new OlympusClash();

        battle_contract = new Battlecontract();

        treasury = nft.TREASURY();
        vm.label(treasury, "treasury");

        mintPrice = nft.mintPrice();
        initialSupply = nft.totalSupply();
        assertEq(initialSupply, 0);

        vm.warp(nft.mintStartTimestamp());
    }

    function testPublicMint() public {
        vm.deal(alice, mintPrice);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(1);
        vm.stopPrank();
        assertEq(nft.balanceOf(alice), 1);
        assertEq(nft.ownerOf(1), alice);
        assertEq(nft.totalSupply(), 1 + initialSupply);
        assertEq(nft.TREASURY().balance, mintPrice);
    }

    function testPublicMintWithoutPayment() public {
        vm.expectRevert(OlympusClash.MintPriceNotPaid.selector);
        vm.startPrank(alice);
        nft.mint{ value: 0 }(1);
        vm.stopPrank();
    }

    function testPublicMintWithExcessPayment() public {
        vm.deal(alice, mintPrice + 1);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice + 1 }(1);
        vm.stopPrank();
        assertEq(nft.balanceOf(alice), 1);
        assertEq(nft.ownerOf(1), alice);
        assertEq(nft.totalSupply(), 1 + initialSupply);
        assertEq(nft.TREASURY().balance, mintPrice);
        assertEq(alice.balance, 1);
    }

    function testPublicMintWithInsufficientPayment() public {
        vm.expectRevert(OlympusClash.MintPriceNotPaid.selector);
        vm.deal(alice, mintPrice - 1);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice - 1 }(1);
        vm.stopPrank();
    }

    function testPublicMintWithZeroAmount() public {
        vm.expectRevert(OlympusClash.InvalidAmount.selector);
        vm.deal(alice, mintPrice);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(0);
        vm.stopPrank();
    }

    function testPublicMintingNotStarted() public {
        nft.setMintStartTimestamp(block.timestamp + 1);

        vm.deal(alice, mintPrice);
        vm.expectRevert(OlympusClash.MintingNotStarted.selector);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(1);
        vm.stopPrank();
    }

    function testTokensOfOwner() public {
        vm.deal(alice, mintPrice);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(1);
        vm.stopPrank();
        assertEq(nft.tokensOfOwner(alice).length, 1);
        assertEq(nft.tokensOfOwner(alice)[0], 1);

        vm.deal(alice, mintPrice);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(1);
        vm.stopPrank();
        assertEq(nft.tokensOfOwner(alice).length, 2);
        assertEq(nft.tokensOfOwner(alice)[0], 1);
        assertEq(nft.tokensOfOwner(alice)[1], 2);

        vm.prank(alice);
        nft.transferFrom(alice, bob, 1);
        assertEq(nft.tokensOfOwner(alice).length, 1);
        assertEq(nft.tokensOfOwner(alice)[0], 2);
        assertEq(nft.tokensOfOwner(bob).length, 1);
        assertEq(nft.tokensOfOwner(bob)[0], 1);
    }

    function testSetMintPrice() public {
        assertEq(nft.mintPrice(), mintPrice);
        nft.setMintPrice(100);
        assertEq(nft.mintPrice(), 100);
    }

    function testSetMintStartTimestamp() public {
        nft.setMintStartTimestamp(block.timestamp + 1);
        assertEq(nft.mintStartTimestamp(), block.timestamp + 1);
    }

    function testSetMintStartTimestampUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        nft.setMintStartTimestamp(block.timestamp + 1);
    }

    function testSetBaseURI() public {
        nft.mint{ value: mintPrice }(1);
        nft.setBaseURI("https://example.com/");
        assertEq(nft.baseURI(), "https://example.com/");
        assertEq(nft.tokenURI(1), "https://example.com/1");
    }

    function testSetBaseURIUnauthorized() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        nft.setBaseURI("https://example.com/");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function testburn_mint() public {
        vm.deal(alice, mintPrice);
        vm.startPrank(alice);
        nft.mint{ value: mintPrice }(1);
        vm.stopPrank();
        assertEq(nft.tokensOfOwner(alice).length, 1);
        assertEq(nft.tokensOfOwner(alice)[0], 1);
    }

    receive() external payable {}
}
