// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";



contract NFTSportsMarketplace is ERC721Enumerable,Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private  ItemsSold ; // Total Items Sold till now 
    uint256 public  TotalItems = 10 ; // Total number of NFTS Items 

   string BaseURI ;

   uint256 ListingPrice = 0.2 ether ; // Listing Price Created by the NFT Marketplace Owner 

   mapping(uint256 => NFTItem) private TokenIdToNFTItem; // mapping of int to struct 

   address public  owner ; // owner of the marketplace he/she is payable because they are given listing price while the NFT ITEm is sold 

    struct NFTItem {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    event NFTItemMinted (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

   constructor(string memory _BaseURI) ERC721("Sports Tokens ", "ST") {
      owner = payable(msg.sender);
      BaseURI = _BaseURI;
    }

   function UpdateListingPrice(uint256 price) public OnlyOwner
   {
      Listing_Price = price;
   }

   function GetListingPrice() public view returns(uint256)
   {
       return Listing_Price;
   }

    function _baseURI() internal view virtual override returns (string memory) 
    {
       return BaseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) 
   {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory baseURI = _baseURI();
            // Here it checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
            // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given 
            // tokenId stored on IPFS
            // If baseURI is empty return an empty string
            return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }
 

      function MintNFT() public payable  
       {
            require(ItemsSold.current()< TotalItems, "All NFTS are Minted");
            require(msg.value == ListingPrice, "Send right amount of ether ");
            ItemsSold.increment();
            _safeMint(msg.sender, ItemsSold.current());
       }
   
   
      function Home() public view returns(NFTItem[] memory)
      {
            uint256 ItemCount = ItemsSold.current();
            uint256 UnsoldItemCount = TotalItems - ItemsSold.current();
            uint256 currentIndex = 0;

            NFTItem[] memory items = new NFTItem[](UnsoldItemCount);
            for (uint256 i = 0; i < itemCount; i++) {
            if (TokenIdToNFTItem[i + 1].owner == address(this)) {
             uint256 currentId = i + 1;
             NFTItem storage currentItem = TokenIdToNFTItem[currentId];
             items[currentIndex] = currentItem;
             currentIndex += 1;
        }
      }
             return items;
      }


      function OnAuction() public view returns(NFTItem[] memory)
      {
            uint totalItemCount = TotalItems;
            uint itemCount = 0;
            uint currentIndex = 0;

            for (uint i = 0; i < totalItemCount; i++) {
            if (TokenIdToNFTItem[i + 1].seller == msg.sender) {
              itemCount += 1;
           }
         }

          NFTItem[] memory items = new NFTItem[](itemCount);
          for (uint i = 0; i < totalItemCount; i++) {
          if (TokenIdToNFTItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          NFTItem storage currentItem = TokenIdToNFTItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
          }
        }
              return items;
      }


     function MyCurrentNFTList() public view returns (NFTItem[] memory)
     {
      uint totalItemCount = TotalItems;
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (TokenIdToNFTItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      NFTItem [] memory items = new NFTItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (NFTItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          NFTItem storage currentItem = TokenIdToNFTItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
     }


     function SellNFT(uint256 tokenId, uint256 price) public payable {

      require(price > 0, "Price must be at least 1 wei");
      require(msg.value == ListingPrice, "Price must be equal to listing price");

      TokenIdToNFTItem[tokenId] =  NFTItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      _transfer(msg.sender, address(this), tokenId);
      emit NFTItemMinted(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

      function AllowReSellPurchasedNFT(uint256 tokenId, uint256 price) public payable {
      require(NFTItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == ListingPrice, "Price must be equal to listing price");
      TokenIdToNFTItem[tokenId].sold = false;
      TokenIdToNFTItem[tokenId].price = price;
      TokenIdToNFTItem[tokenId].seller = payable(msg.sender);
      TokenIdToNFTItem[tokenId].owner = payable(address(this));
      ItemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

       function withdraw() public onlyOwner  
       {
            address _owner = owner();
            uint256 amount = address(this).balance;
            (bool sent, ) =  _owner.call{value: amount}("");
            require(sent, "Failed to send Ether");
       }

        receive() external payable {}

        fallback() external payable {}

}
