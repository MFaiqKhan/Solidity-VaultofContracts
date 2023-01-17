// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Sollior is ERC1155, Ownable, Pausable, ERC1155Supply {

    uint256 public publicPrice = 0.02 ether; // price of the token in ether.
    uint256 public allowListPrice = 0.01 ether; // price of the token in ether
    uint256 public Max_supply = 50; // max supply of the single token ID.
    uint public maxPerWallet = 3;

    bool public allowListActive = true; // allow list is active or not.
    bool public publicSaleActive = false; // public sale is active or not.

    mapping (address => bool) public allowList; // allow list mapping.
    mapping (address => uint256) public purchasePerWallet; // allow list mapping.

    /**
        @dev Initialize the contract by setting a name and a symbol to the token collection.
        @dev The URI is set to the IPFS gateway.

     */
    constructor(
        address [] memory _payees,
        uint256[] memory _shares // shares of the payment to be sent to the payees.
    )
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        PaymentSplitter(_payees, _shares) // PaymentSplitter is used to split the payment between multiple addresses.
    {}

    
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setAllowList(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _allowList.length; i++) {
            allowList[_addresses[i]] = true;
        }
    }


    function setPublicPrice(uint256 newPrice) external onlyOwner {
        publicPrice = newPrice;
    }

    function editMintWindow(bool _allowList, bool publicSale) external onlyOwner {
        allowListActive = _allowList;
        publicSaleActive = publicSale;
    }


    function allowListMint(uint256 id, uint256 amount) public payable {
        require(purchasePerWallet[msg.sender] + amount <= maxPerWallet, "Max limit reached");
        require(allowListActive, "Allow List is not active");
        require(allowList[msg.sender], "You are not in the allow list");
        require (id <= 5, "NFT ID Doesn't Exists");
        require(totalSupply(id) + amount <= Max_supply, "Max limit reached");
        require(msg.value == allowListPrice * amount, "Not enough ether sent"); // require is used to check if the user has sent enough ether to mint the token.
        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] += amount;
    }


    /**
        @dev Mint new tokens.
        @dev anybody can mint tokens.
        @notice replacing account address to msg.sender to get the address of the callera and mint tokens to them.
        so deleting the account address from param and replacing it with msg.sender in _mint function.
        @param id token id.
        @param amount amount of tokens to mint.
        @notice data data to pass if receiver is contract. we will be putting this field to empty string 
        because it is only used when we want to send data to the contract and data is showen in the logs.
        @notice msg.value will be equal to the number of tokens to mint multiplied by the price of the token. (Multiple mint functionality )
        @notice totalSupply(id) + amount < Max_supply, "Max limit reached" this is to check if the max supply of the token id is reached or not.
        @notice id <= 5, "NFT ID Doesn't Exists" this is to check if the token id exists or not, and only 5 token ids are allowed.
    */ 

    /*You can see the input data for a transaction in the block explorer but it will be in hexadecimal/binary. 
    If your contract is verified on Etherscan, you can decode it under the Input Data ⇾ View input As section.  */
    function publicMint(uint256 id, uint256 amount)
        public
        payable // payable is used to accept ether from the user, so that the user can pay for the minting of the token.
    {
        require(purchasePerWallet[msg.sender] + amount <= maxPerWallet, "Max limit reached");
        require(publicSaleActive, "Public Sale is not active");
        require (id <= 5, "NFT ID Doesn't Exists");
        require(totalSupply(id) + amount <= Max_supply, "Max limit reached");
        require(msg.value == publicPrice * amount, "Not enough ether sent"); // require is used to check if the user has sent enough ether to mint the token.
        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] += amount;
    }

    /**
        @dev uri function to get the token uri.
        @return abi.encodePacked(super.uri(id), Strings.toString(id)) this is to get the token uri.
        @dev abi.encodePacked is used to concatenate the token uri with the token id.
        @dev Strings.toString(id) is used to convert the token id to string.
        @dev super is a keyword that is used to refer to the parent contract.
        @dev super.uri(id) is used to get the token uri from the parent contract.
        @dev and converts it into json format.
        @dev exists(id) is used to check if the token id exists or not.
        @notice The token uri is the location of the metadata of the token. we will be using ipfs to store the metadata of the token.
        // will have png image of the token and the name of the token and traits of the token.

     */
    function uri(uint256 id) public view override returns (string memory) {
        require(exists(id), "ERC1155Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(super.uri(id), Strings.toString(id), ".json"));
    }

    /**
        @dev get the balance of the this contract.
        @dev address(this) is used to get the address of the contract itself.
        @dev msg.sender is used to get the address of the caller.
        @dev .transfer is used to transfer the balance of the contract to the owner of the contract.
     */
    function withdraw() external onlyOwner {    
        uint256 balance = address(this).balance; 
        payable(msg.sender).transfer(balance);
    }
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}




/*  ERC1155 line 91 (in original oz contract erc1155.sol)
    This is creating an array of type uint256 in memory, 
    with the length of the array being equal to the length of the accounts array.
    The new keyword is used to create a new instance of the array, and the memory keyword specifies 
    that the array will be stored in memory rather than in storage. This array, named batchBalances,
    will be able to store a series of uint256 values, and is being created with the same number of 
    elements as the accounts array.
 */