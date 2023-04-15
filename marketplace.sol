//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract NFTMarketplace is ERC721URIStorage
{
    address payable owner;
    using Counters for Counters.Counter;
    Counters.Counter private tokenid;
    Counters.Counter private itemsold;
    uint public listprice=0.0001 ether;
    constructor() ERC721("NFTMarketplace","NFTP")
    {
        owner=payable(msg.sender);

    }
    struct listeditems
    {
        uint tokenid;
        address payable owner;
        address payable seller;
        uint price;
        bool islisted;
    }
    mapping(uint=>listeditems)tokens;
    modifier onlyowner()
    {
        require(msg.sender==owner);
        _;
    }
    function update_list_price(uint p) public onlyowner 
    {
        listprice=p;
    }
    function get_list_price() public view returns(uint)
    {
        return listprice;
    }
    function getLatesttoken() public view returns(listeditems memory)
    {
        return tokens[tokenid.current()];
    }
    function getlistedtoken(uint t) public view returns(listeditems memory)
    {
        return tokens[t];
    }
    function getcurrenttokenid() public view returns(uint)
    {
        return tokenid.current();
    }
    function createToken(string memory uri,uint p) public payable returns(uint)
    {
        require(msg.value==listprice);
        require(p>0);
        tokenid.increment();
        uint y=tokenid.current();
        _safeMint(msg.sender, y);
        _setTokenURI(y,uri);
        cretelistedtoken(y,p);
        return y;
    } 
    function cretelistedtoken(uint t,uint p) public 
    {
        tokens[t].tokenid=t;
        tokens[t].owner=payable(address(this));
        tokens[t].price=p;
        tokens[t].seller=payable(msg.sender);
        tokens[t].islisted=true;
        _transfer(msg.sender, address(this), t);
    }
    function getallNft() public view returns(listeditems[] memory)
    {
        uint count=tokenid.current();
        listeditems[] memory arr=new listeditems[](count);
        for (uint i=0;i<count;i++)
        {
            arr[i]=tokens[i+1];
        }
        return arr;
    }
    function getmynfts() public view returns(listeditems[] memory)
    {

   uint total_count=tokenid.current();
        uint y=0;
        uint count=0;
         for (uint i=0;i<count;i++)
        {
            if(tokens[i+1].seller==msg.sender)
            {
            count+=1;
            }
        }
            listeditems[] memory arr=new listeditems[](count);
        for (uint i=0;i<total_count;i++)
        {
            if(tokens[i+1].seller==msg.sender)
            {
            arr[y]=(tokens[i+1]);
            y+=1;
            }
        }
        return arr;
    }
    function execute_sale(uint token_id) public payable
    {
        require(msg.value==tokens[token_id].price);
        address payable s=payable(tokens[token_id].seller);
        s.transfer(msg.value);
        itemsold.increment();
        _transfer(address(this), msg.sender,token_id);
        approve(address(this), token_id);
        payable(owner).transfer(listprice);
    }
}
