// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC4907Rent} from "./ERC4907/ERC4907.sol";


error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();

contract BRcommunity is ERC4907Rent, Pausable, Ownable {

    using Strings for uint256;
    string public generalURI;
    string public baseURI;
    string public collectionCover;
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10_000;

    //omnes protocol
    uint256 public price;
    uint256 public maxDiscount;

    //acess rules 
    uint256 monthlyFee;
    uint256 constant timeForpay = 30 days;

    struct Infopayment{
        uint256 timepay;
        uint256 valuepay;
    }

    mapping(uint256 => Infopayment) public monthlyPayment;
    event MonthlyPayment(uint256 indexed tokenId, address indexed user, uint256 time);
    event Accessdate(address indexed user, uint256 time);


    constructor(
        string memory _name,
        string memory _symbol,
        string memory _generalURI,
        string memory _collectionCover
    ) ERC4907Rent(_name, _symbol) {
        generalURI = _generalURI;
        collectionCover = _collectionCover;// set ipfs/CID/collection.json
    }

    function mint() external payable whenNotPaused {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
        if (msg.value < price - ((price * maxDiscount) / 10000)) {
            revert MintPriceNotPaid();
        }
        _mint(msg.sender, 1);
    }

    function mintOwner(address _to) external payable onlyOwner{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
    }

    //acess rules

    function acessPlatform(uint tokenId) external {
        require(balanceOf(msg.sender) >= 1 || userOf(tokenId) == msg.sender,
        "you do not have access NFTs or your term to use has expired");
        require(block.timestamp <= monthlyPayment[tokenId].timepay + timeForpay, 
        "It is only possible to access the platform by paying the monthly fee.");
        emit Accessdate(msg.sender,block.timestamp);
    }

    function payMonthlyFee(uint tokenId) payable external{
        require(_exists(tokenId));
        require(msg.value >= monthlyFee, "monthly fee is not correct");
        monthlyPayment[tokenId] =  Infopayment({
            timepay: block.timestamp,
            valuepay: 0
        });
        emit MonthlyPayment(tokenId,msg.sender,block.timestamp);
    }

    function rentAcess(uint256 tokenId, address user, uint64 expires) public{
        setUser(tokenId, user,expires);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : generalURI;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setmonthlyFee(uint256 _monthlyFee) external onlyOwner {
        monthlyFee = _monthlyFee;
    }

    function setMaxdiscont(uint256 _maxDiscont) external onlyOwner {
        maxDiscount = _maxDiscont;
    }

    function setGeneralURI(string memory _generalURI) external onlyOwner {
        generalURI = _generalURI;
    }

    function setCollectionURI(string memory _collectionCover) external onlyOwner{ ///set ipfs/CID/collection.json
        collectionCover = _collectionCover;
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{ value: balance }("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

     function contractURI() //collection cover
        external
        view
        returns (string memory)
    {
        return string(abi.encodePacked(collectionCover)); 
        //set in the folder of the files the file named as collection
    }


 }