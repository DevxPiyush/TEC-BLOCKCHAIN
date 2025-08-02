// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard, ERC721Holder {
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool sold;
    }

    uint256 private _itemIds;
    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        bool sold
    );

    function createMarketItem(address nftContract, uint256 tokenId, uint256 price)
        public
        payable
        nonReentrant
    {
        require(price > 0, "Price must be greater than 0");
        
        _itemIds++;
        uint256 itemId = _itemIds;

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            price,
            false
        );
    }

    function buyMarketItem(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        MarketItem storage item = idToMarketItem[itemId];
        require(msg.value == item.price, "Please submit the exact asking price");
        require(!item.sold, "Item is already sold");

        // Transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, item.tokenId);

        // Transfer the payment to the seller
        item.seller.transfer(msg.value);

        item.sold = true;
    }
    
    // Function to fetch all unsold market items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds;
        uint256 unsoldItemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idToMarketItem[i].sold) {
                unsoldItemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idToMarketItem[i].sold) {
                items[currentIndex] = idToMarketItem[i];
                currentIndex++;
            }
        }
        return items;
    }
}
