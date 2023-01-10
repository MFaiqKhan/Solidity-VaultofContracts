// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// import openzeppelin MerkleProof contract , this imported contract will be helpful as we will use
// MerkleProof.verfiy() function to verify the proof
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

//If the smart contract is deployed to ethereum mainnet
// We can make some setter function if we want to update the value at a later point in time
// here we have hardcoded the root merkle hash value

contract Merkle {
    // root hash of the merkleTree ,
    // same as we generated in our javascript code 
    //bytes32 public merkleRoot;
    // this is a bytes32 type and not a string
    bytes32 public merkleRoot = 0x6783182a4bce52cc5c3bb67af4b9258c69d5b3fc3ce8d86e476cb0d35ecdbe87;

    mapping(address => bool) public whitelistClaimed; // To mark addresses as being claimed

    // constructor
 /*    constructor(bytes32 _root) {
        root = _root;
    } */

    // verify proof
    /***
        * @dev Verify the merkle proof given to us from the client side using Hexproof method on merkletreee object
        * @param _proof bytes32[] proof array
     */
    function whitelistMint(bytes32[] calldata _merkleproof) public  {
        require(!whitelistClaimed[msg.sender], "You have already claimed your token");

        //hashing the leaf given to us as a msg.sender from client side
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender)); // abi.encodePacked() is used to convert the address to bytes32
        // verify the proof
        require(MerkleProof.verify(_merkleproof, merkleRoot, leaf), "Invalid proof");

        // mark the address as claimed
        whitelistClaimed[msg.sender] = true;

        // mint the token to that address
        mint(msg.sender);

    }
}