// Challenge 8: NFT Marketplace (Basic)
//  Objective:
// Build a simple marketplace where users can list their ERC721 NFTs for sale and others can buy them using ETH.

// Expected Skills & Concepts:
// Interfacing with ERC721 (IERC721)

// Ownership and transfer checks

// ETH payment flow with msg.value, transfer

// Mappings for listing management

// Events for marketplace transparency

// (New) OpenZeppelin’s IERC721 interface usage

//  Requirements:
// List NFT:

// User can list their NFT by specifying tokenAddress, tokenId, and price.

// NFT must be approved for the marketplace before listing.

// Buy NFT:

// Any user can buy a listed NFT by sending the exact price in ETH.

// NFT is transferred from seller to buyer.

// ETH is transferred to the seller.

// Cancel Listing:

// Only the original seller can cancel the listing before a purchase.

// Security:

// Check that seller owns the NFT before listing.

// Prevent re-listing already sold NFTs.

// Events:

// Emit Listed, Purchased, and Cancelled events.Challenge 8: NFT Marketplace (Basic)
//  Objective:
// Build a simple marketplace where users can list their ERC721 NFTs for sale and others can buy them using ETH.

//  Expected Skills & Concepts:
// Interfacing with ERC721 (IERC721)

// Ownership and transfer checks

// ETH payment flow with msg.value, transfer

// Mappings for listing management

// Events for marketplace transparency

// (New) OpenZeppelin’s IERC721 interface usage

// Requirements:
// List NFT:

// User can list their NFT by specifying tokenAddress, tokenId, and price.

// NFT must be approved for the marketplace before listing.

// Buy NFT:

// Any user can buy a listed NFT by sending the exact price in ETH.

// NFT is transferred from seller to buyer.

// ETH is transferred to the seller.

// Cancel Listing:

// Only the original seller can cancel the listing before a purchase.

// Security:

// Check that seller owns the NFT before listing.

// Prevent re-listing already sold NFTs.

// Events:

// Emit Listed, Purchased, and Cancelled events.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(
        address indexed nft,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );
    event Purchased(
        address indexed nft,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );
    event Cancelled(
        address indexed nft,
        uint256 indexed tokenId,
        address seller
    );

    function listNFT(address nft, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            token.getApproved(tokenId) == address(this),
            "Marketplace not approved"
        );

        listings[nft][tokenId] = Listing({seller: msg.sender, price: price});

        emit Listed(nft, tokenId, msg.sender, price);
    }

    function buyNFT(
        address nft,
        uint256 tokenId
    ) external payable nonReentrant {
        Listing memory listedItem = listings[nft][tokenId];
        require(listedItem.price > 0, "Not listed");
        require(msg.value == listedItem.price, "Incorrect ETH amount");

        delete listings[nft][tokenId];

        payable(listedItem.seller).transfer(msg.value);

        IERC721(nft).safeTransferFrom(listedItem.seller, msg.sender, tokenId);

        emit Purchased(nft, tokenId, msg.sender, listedItem.price);
    }

    function cancelListing(address nft, uint256 tokenId) external {
        Listing memory listedItem = listings[nft][tokenId];
        require(listedItem.seller == msg.sender, "Not the seller");

        delete listings[nft][tokenId];

        emit Cancelled(nft, tokenId, msg.sender);
    }

    function getListing(
        address nft,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return listings[nft][tokenId];
    }
}
