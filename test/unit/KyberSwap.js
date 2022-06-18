const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
const {
  AAVE,
  ASSETS,
  TREASURY,
} = require("../../migrations/address_lookup.js");
const { STRATEGIES, ENCODE_STRUCTS } = require("../Strategies.js");
let strategy, registry;

before(async () => {
  const ArbiTrader = await ethers.getContractFactory("ArbiTrader");
  strategy = await ArbiTrader.deploy(
    AAVE.poolAddressesProvider["matic"],
    TREASURY.DEV
  );
  strategy = await strategy.deployed();
});

//        const AAVE_DAI_POOLS = await kyber.getUnamplifiedPool(ASSETS[network].AAVE, ASSETS[network].DAI);
