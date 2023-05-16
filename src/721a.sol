// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "../lib/erc721a/contracts/ERC721A.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";


//0xfcbd5664F49d22F3102DE725DB42b91bB388B949
//
/** @author Omnes Blockchain team www.omnestech.org (@Afonsodalvi, @G-Deps @EWCunha, and @renancorreadev)
    Main course tutor: Alexandre Senra: https://www.linkedin.com/in/alexandresenra/
    @title ERC721A contract for smart contract course for law professionals
    ipfs: https://bafybeid7rsqvtd454ra4tkfa3y2vobmz75zexgxe6zndsj5jk23tbjdnsq.ipfs.nftstorage.link/
    */
contract ContractA is ERC721A, Pausable, Ownable {

    //erros
    error NonExistentTokenURI();
    error WithdrawTransfer();

    string private material;
    string baseURI;
    mapping(address => bool) approveAdr;
    mapping(address => mapping(uint256 => string)) private materialId;

    //collections
    IERC721 public collectionGotasSUP = IERC721(0xcA4a7363A939f5686Bd7268c3b895D720d1929aA);//https://opensea.io/collection/supofficialdrops
    IERC721 public collectionOmnes = IERC721(0x9574B5878Dc8d527556675628548706B8cA1a5d9);//https://opensea.io/collection/omnes-web3club-soulbound


    // SFTRec settings -- omnesprotocol
    uint256 public price;
    uint256 public maxDiscount;
    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;


    constructor(string memory _name,
        string memory _symbol,
        string memory baseuri) ERC721A(_name, _symbol) {
       baseURI = baseuri;
    }

    function mintLegalEng() external payable whenNotPaused{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, 1);
    }

    function mintTo(address recipient, uint256 quantity) public payable returns (uint256) {
        require(
            msg.value == MINT_PRICE,
            "Transaction value did not equal the mint price"
        );
         uint256 newTokenId = _nextTokenId() + 1;
        require(newTokenId <= TOTAL_SUPPLY, "Max supply reached");
        _safeMint(recipient, quantity);
        return newTokenId;
    }

    function requestMaterial(uint256 id)external view returns(string memory){
        require(ownerOf(id) == msg.sender || 
        collectionGotasSUP.balanceOf(msg.sender) > 0 || 
        collectionOmnes.balanceOf(msg.sender) > 0, "you are not the owner of this NFT to request the material");
        return material;
    }

    function requestMyPlusMaterial(uint256 id)external view returns(string memory){
        require(ownerOf(id) == msg.sender, "you are not the owner of this NFT to request the material");
        string memory materialPlus = materialId[msg.sender][id];
        return materialPlus;
    }

    function setMaterialLink(string memory Material, uint256 id, address sorteado)external addrApprove{
        materialId[sorteado][id] = Material;
        material = Material;
    }

    function setMaterialGlobal(string memory Material)external addrApprove{
        material = Material;
    }

    function setApprAddr(address _addrApprove, bool aprovar)external onlyOwner{
        approveAdr[_addrApprove] = aprovar;
    }

    function setURI(string memory newUri)external onlyOwner{
        baseURI = newUri;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseuRI = _baseURI();
        string memory json = ".json";
        return bytes(baseuRI).length != 0 ? string(abi.encodePacked(baseuRI, _toString(tokenId), json)) : '';
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal view override returns (string memory){
        return baseURI;
    }
    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

    modifier addrApprove(){
        require(approveAdr[msg.sender], "not approve");
        _;
    }
}
