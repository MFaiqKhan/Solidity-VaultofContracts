// we know that in merkletree every parent node foster a maximum of two leaf nodes
// If there are uneven number of leaf nodes exists, then a parent node will foster a single leaf node only

// each leaf node should be some of hashed data.

const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256'); // using keccak256 hashing function because it will be used in 
// later smart contract

//Drawback::: we need to know the number of leaf nodes beforehand etc
// merkletree, leaves and roothash are all determined prior to claim. the project would
// have some sort of whitelist process where whitelisted addresses are collected and known beforehand.

// an array of strings 
let whitelistAddresses = [
  // write 7 dummy wallet address
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d0",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d1",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d2",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d3",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d4",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d5",
  "0x35a9f94af726f07b5162df7e828cc9dc8439e7d6",
];

// convert each address to keccak256 hash
const leafNodes = whitelistAddresses.map((addr) => keccak256(addr));
console.log(leafNodes); // print the hash of each address, this is an array of strings
// create a merkle tree, // sortPairs: true is used to sort the pairs of nodes before hashing them
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
console.log(merkleTree); // print the merkle tree
console.log(merkleTree.toString()); // print the merkle tree as a string

// get the root hash of the merkle tree
// root hash is the hash of the root node
// each leaf node is hashed with its sibling node to form a parent node
// the parent node is hashed with its sibling node to form a grandparent node
// the grandparent node is hashed with its sibling node to form a great grandparent node
// the great grandparent node is hashed with its sibling node to form a great great grandparent node
// In the last step, the great great grandparent node is hashed with its sibling node to form the root node
const rootHash = merkleTree.getRoot();
console.log(rootHash); // print the root hash

// lets make it what would happen in website implementation

// when we have both our merkletree Object and its rootHash , how can we provide merkleproof 
//  to the whitelisted user who wants to claim the reward?

//  from the client side we will recieve the connected wallet address  through msg.sender API sort of, and return the designated proof
//  On server side , we will recieve the address , willl hash it , and retreive the proof using getHexProof() on our
//  merkletree object that we have made prior to claim 


const claimingAddress = leafNodes[0]; // the address of the user who wants to claim the reward

// get the proof of the address
// the proof determine says that the address is in the whitelist
//getHexProof will contain neighbour leaf and all parent nodes hashes that are needed to verify the claiming address
const proof = merkleTree.getHexProof(claimingAddress);

// print the proof

console.log(proof); // print the proof

// after the proof is recieved and sent as a parameter with the participants transaction 
// we will use the proof to verify the claiming address is in the whitelist in our smart contract








