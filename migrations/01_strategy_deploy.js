// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { AAVE } = require("./address_lookup.js")

/**
 * Main script for Strategy deployment
 */
async function main() {

    // Deploy Registry
  const DexRegistry = await hre.ethers.getContractFactory("DexRegistry");
  const dexRegistry = await DexRegistry.deploy();
  await dexRegistry.deployed();

  // Deploy
  console.log("Arbitrage Strategy deployed to:", dexRegistry.address);

  const ArbiTrader = await hre.ethers.getContractFactory("ArbiTrader");
  
  // Init Arbi trader strategy

  const strategy = await ArbiTrader.deploy(
      AAVE.poolAddressesProvider['matic'],
      "0x8B13f183e27AaD866b0d71F0CD17ca83A9a54ae2",
      dexRegistry.address
    );

  await strategy.deployed();

  console.log("Arbitrage Strategy deployed to:", strategy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
