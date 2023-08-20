import { ethers } from "hardhat";

async function main() {
  const colletion = "https://ipfs.io/ipfs/bafybeihgrbjb4llwttmlbv4cg3whhyxywodw3g4h667eh5eaureq3bzaaq/collection.json";
  const General = "https://ipfs.io/ipfs/bafybeihgrbjb4llwttmlbv4cg3whhyxywodw3g4h667eh5eaureq3bzaaq/base.json";
  const totalsupply = 10000;
  const nome = "BRcollection";
  const symbol = "BRC";

  const NFT = await ethers.getContractFactory("BRcommunity");
  const nft = await NFT.deploy(nome,symbol,General,colletion,totalsupply);

  await nft.deployed();

  console.log("Lock with 1 ETH deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
