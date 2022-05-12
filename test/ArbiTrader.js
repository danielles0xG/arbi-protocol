const { expect } = require("chai");
const { ethers } = require("hardhat");
const { AAVE, ASSETS, TREASURY } = require("../migrations/address_lookup.js");
const { STRATEGIES, ENCODE_STRUCTS } = require("./Strategies.js");
let strategy;

before(async () => {
  const ArbiTrader = await hre.ethers.getContractFactory("ArbiTrader");
  strategy = await ArbiTrader.deploy(
    AAVE.poolAddressesProvider["matic"],
    TREASURY.DEV
  );
  strategy = await strategy.deployed();
});

// Encode Params
before(async () => {
  const ArbiTrader = await hre.ethers.getContractFactory("ArbiTrader");
  strategy = await ArbiTrader.deploy(
    AAVE.poolAddressesProvider["matic"],
    TREASURY.DEV
  );
  strategy = await strategy.deployed();
});

describe("ArbiTrader", function () {
  it("Should return the new greeting once it's changed", async function () {
    const encoded_params = [];
    const abiCoder = ethers.utils.defaultAbiCoder;

    STRATEGIES.map((s) => {
      encoded_params.push(
        abiCoder.encode(
          ENCODE_STRUCTS.DataTypeTemplate,
          ENCODE_STRUCTS.DataValues(s)
        )
      );
    });

    console.log(encoded_params);

    // await strategy.performStrategy(
    //   LOAN_ASSET,
    //   LOAN_AMOUNT,
    //   ENCODED_STRATEGIES,

    // );
    // console.log("strategy: ",strategy)
    // expect(await greeter.greet()).to.equal("Hello, world!");
  });
});
-``;
