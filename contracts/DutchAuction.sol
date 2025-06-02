// Advanced Challenge 13: NFT Dutch Auction
// 🧠 Objective:
// Implement a Dutch auction contract where the price of an NFT starts high and decreases over time until someone buys it or it hits a reserve price.

// 📘 Expected Skills & Concepts:
// ERC721 token handling (IERC721, transferFrom)

// Auction mechanics and dynamic pricing

// block.timestamp and time-based logic

// ETH payment flow (msg.value, transfer)

// Event logging for auction lifecycle

// (Optional): OpenZeppelin IERC721, Ownable, ReentrancyGuard

// 🧾 Requirements:
// Create Auction:

// Seller lists an NFT with:

// starting price

// reserve price

// price drop rate

// duration

// Buy NFT:

// Buyer can call buy() to purchase the NFT at the current price.

// Send ETH equal to or greater than current price.

// Auction Expiry:

// If auction ends without a buyer, seller can reclaim the NFT.

// Security:

// Only NFT owner can create the auction.

// Prevent multiple purchases or early reclamation.

// Events:

// Emit AuctionCreated, NFTPurchased, and AuctionEnded.

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract DutchAuction {
    struct nft {
        address nft;
        uint startPrice;
        uint reservePrice;
        uint priceDropPerSecond;
        uint startTime;
    }

    mapping(uint => nft) nftAuction;
    event AuctionCreated(
        address nft,
        address creator,
        uint startPrice,
        uint id
    );

    event NftBought(address buyer, uint price, uint it);

    constructor() {}

    function createAuction(
        address _nft,
        uint _tokenId,
        uint _startPrice,
        uint _reservePrice,
        uint _priceDropPerSecond
    ) external {
        require(_startPrice > 0, "Price can not be set to 0");
        require(
            _priceDropPerSecond > 0,
            "Price Drop Per Second can not be set to 0"
        );
        require(
            IERC721(_nft).ownerOf(_tokenId) == msg.sender,
            "You can only list nft which you own"
        );
        require(
            _reservePrice < _startPrice,
            "Reserve Price can can not be greater than start Price"
        );
        require(
            nftAuction[_tokenId].startPrice == 0,
            "Nft already listed for auction"
        );
        nftAuction[_tokenId] = nft({
            nft: _nft,
            startPrice: _startPrice,
            reservePrice: _reservePrice,
            priceDropPerSecond: _priceDropPerSecond,
            startTime: block.timestamp
        });
        IERC721(_nft).safeTransferFrom(msg.sender, address(this), _tokenId);
        emit AuctionCreated(_nft, msg.sender, _startPrice, _tokenId);
    }

    function buy(uint _tokenId, address _nft) external payable {
        IERC721 nft = IERC721(_nft);
        require(
            nft.ownerOf(_tokenId) == address(this),
            "Nft id not available for auction"
        );
        uint currentPrice;

        uint starTime = nftAuction[_tokenId].startTime;
        uint startPrice = nftAuction[_tokenId].startPrice;
        uint resPrice = nftAuction[_tokenId].reservePrice;
        uint priceDropPerSecond = nftAuction[_tokenId].priceDropPerSecond;
        uint difSeconds = block.timestamp - starTime;

        if (startPrice - (priceDropPerSecond * difSeconds) > resPrice) {
            currentPrice = startPrice - (priceDropPerSecond * difSeconds);
        } else {
            currentPrice = resPrice;
        }
        require(msg.value >= currentPrice, "Insufficient amount to buy nft");
        delete nftAuction[_tokenId];
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit NftBought(msg.sender, currentPrice, _tokenId);
    }

    function getCurrentPrice(
        uint _tokenId,
        address _nft
    ) external view returns (uint) {
        IERC721 nft = IERC721(_nft);
        require(
            nft.ownerOf(_tokenId) == address(this),
            "Nft id not available for auction"
        );
        uint currentPrice;

        uint starTime = nftAuction[_tokenId].startTime;
        uint startPrice = nftAuction[_tokenId].startPrice;
        uint resPrice = nftAuction[_tokenId].reservePrice;
        uint priceDropPerSecond = nftAuction[_tokenId].priceDropPerSecond;
        uint difSeconds = block.timestamp - starTime;

        if (startPrice - (priceDropPerSecond * difSeconds) > resPrice) {
            currentPrice = startPrice - (priceDropPerSecond * difSeconds);
        } else {
            currentPrice = resPrice;
        }
        return currentPrice;
    }
}
