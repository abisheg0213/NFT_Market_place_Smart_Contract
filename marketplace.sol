// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract NFTMarket is ERC721URIStorage
{
    using Counters for Counters.Counter;
    Counters.Counter private tokenid;
    Counters.Counter private itemssold;
    uint private listingprice=100 wei;
    constructor() ERC721("SENFT","SEN"){
        owner=payable(msg.sender);
    }
    address payable owner;
    mapping (uint => marketitem) public idmarket;
    struct marketitem
    {
        string uri;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }
    modifier onlyowner(address a)
    {
        require(a==owner);
        _;
    }
    function updatelistingprice(uint rate) public onlyowner(msg.sender)
    {
        listingprice=rate;
    }
    function getlistingprice() public view returns(uint)
    {
        return listingprice;
    }
    function createtoken(string memory uri,uint price) public  payable 
    {
        tokenid.increment();
        owner.transfer(msg.value);
        uint currentid=tokenid.current();
        _safeMint(msg.sender, currentid);
        _setTokenURI(currentid, uri);
        createmarketitem(currentid,price,uri);
    }
    function createmarketitem(uint tokenid,uint price,string memory u) private
    {
        idmarket[tokenid].price=price;
        idmarket[tokenid].sold=false;
        idmarket[tokenid].uri=u;
        idmarket[tokenid].seller=payable(msg.sender);
        idmarket[tokenid].owner=payable(address(this));
        _transfer(msg.sender, address(this), tokenid);
    }
    function marketsale(uint tokenid) public payable 
    {
        uint price=idmarket[tokenid].price;
        require(msg.value==price);
        idmarket[tokenid].owner=payable(msg.sender);
        idmarket[tokenid].sold=true;
        itemssold.increment();
        _transfer(address(this), msg.sender, tokenid);
        payable(idmarket[tokenid].seller).transfer(msg.value);
    }
    uint public gh=0;
    function fetchmarketitem() public view returns (marketitem[] memory)
    {
        uint itemcount=tokenid.current();
        uint unsold=itemcount-itemssold.current();
        marketitem [] memory kop=new marketitem[](unsold);
        uint j=0;
        for (uint i=itemcount;i>0;i--)
        {
            if(idmarket[i].sold==false)
            {
                kop[j]=idmarket[i];
            }
        }
        return kop;
        
    }
    function ownertokens(address ad) public view returns (marketitem[] memory)
    {
        uint count=tokenid.current();
        uint own_count=0;
        for (uint i=count;i>0;i--)
        {
            if(idmarket[i].owner==ad)
            {
                own_count++;
            }
        }
        uint h=0;
        marketitem[] memory own_list=new marketitem[](own_count);
        for (uint i=count;i>0;i--)
        {
            if(idmarket[i].owner==ad)
            {
                own_list[h]=idmarket[i];
                h++;
            }
        }
        return own_list;
    }
}
