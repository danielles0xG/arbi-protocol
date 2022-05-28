const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
const { AAVE,ASSETS,TREASURY} = require("../migrations/address_lookup.js")
const { STRATEGIES ,ENCODE_STRUCTS} = require("./Strategies.js");
let strategy, registry;

before(async () => {
  const ArbiTrader = await hre.ethers.getContractFactory("ArbiTrader");
  strategy = await ArbiTrader.deploy(AAVE.poolAddressesProvider['matic'], TREASURY.DEV);
  strategy = await strategy.deployed();
})


before(async () => {
  const accounts = await hre.ethers.getSigners();
  console.log("accounts: ",accounts);

  // DEPLOY REGISTRY
  const DexRegistry = await hre.ethers.getContractFactory("DexRegistry");
  registry = await DexRegistry.deploy();
  registry = await DexRegistry.deployed();

  // DEPLOY EXCHANGE



  console.log("registry deployed at: ",registry);
  
  // INIT STRATEGY
  strategy = await ArbiTrader.deploy(
    AAVE.poolAddressesProvider['matic'],
    TREASURY.DEV,
    registry.address
  );

  strategy = await strategy.deployed();
  console.log("Strategy deployed to: ",strategy.address);
});

describe("ArbiTrader",function () {
  it("Should return the new greeting once it's changed", async function () {
    const encoded_params = [];
    const abiCoder = ethers.utils.defaultAbiCoder;

    STRATEGIES.map(s => {
      encoded_params.push(
           abiCoder.encode(
             ENCODE_STRUCTS.DataTypeTemplate,
             ENCODE_STRUCTS.DataValues(s)
           )
        );
    });
    
    console.log(encoded_params)
  });
});