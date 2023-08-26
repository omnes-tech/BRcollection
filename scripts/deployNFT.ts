import { ethers } from "hardhat";

async function main() {
  const colletion = "https://ipfs.io/ipfs/bafybeid5ahgxf36tvvizvglgcdszh4j65aj3zths36ne7tb7iincfpv2le/collection.json";
  const General = "https://ipfs.io/ipfs/bafybeid5ahgxf36tvvizvglgcdszh4j65aj3zths36ne7tb7iincfpv2le/general.json";
  const totalsupply = 1000;
  const nome = "BRfraternity";
  const symbol = "BRF";

  const NFT = await ethers.getContractFactory("BRfraternity");
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
