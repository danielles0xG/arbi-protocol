// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { AAVE ,TREASURY} = require("./address_lookup.js");
const {BigNumber} = require( "ethers");

/**
 * Main script for Strategy deployment
 */
async function main() {
  // Deploy Registry
  // const DexRegistry = await hre.ethers.getContractFactory("DexRegistry");
  // const dexRegistry = await DexRegistry.deploy();
  // await dexRegistry.deployed();
  // console.log("Arbitrage Strategy deployed to:", dexRegistry.address);

  //***********************************************/
  // *******       L2 DEPLOYMENT       ***********
  /***********************************************/

  const ArbiTrader = await hre.ethers.getContractFactory("ArbiTrader");
  const deploymentData = ArbiTrader.interface.encodeDeploy([
    AAVE.poolAddressesProvider["matic"],
    "0x8B13f183e27AaD866b0d71F0CD17ca83A9a54ae2"
  ]);
  let estimatedGas = await ethers.provider.estimateGas({ data: deploymentData });
  let standardGasCost =  ethers.utils.formatEther('44000000000000000000'); // Jun 19th 22 : 12pm 
  console.log('estimatedGas: ',estimatedGas);
  console.log('standardGasCost: ',standardGasCost);

  // Init Arbi trader strategy
  const strategy = await ArbiTrader.deploy(
    "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
    "0x0157f8EAe9754e164cB28D4bDcFEa06A833ff561"
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
