require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

// Task action function receives the Hardhat
// Runtime Environment as second argument
task(
  "blockNumber",
  "Prints the current block number",
  async (_, { ethers }) => {
    await ethers.provider.getBlockNumber().then((blockNumber) => {
      console.log("Current block number: " + blockNumber);
      console.log(ethers.provider);
    });
  }
);

module.exports = {
  defaultNetwork: "matic",
  networks: {
    development: {
      url: "http://localhost:8545",
      gasPrice: "auto",
      gas: 868514334772,
      accounts: [process.env.PRIVATE_KEY],
    },

    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.PROJECT_ID}`,
      // wss://polygon-mumbai.infura.io/ws/v3/${process.env.PROJECT_ID}
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.10",
      },
      {
        version: "0.8.0",
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    paths: {
      sources: "./contracts",
      tests: "./test",
      cache: "./cache",
      artifacts: "./artifacts",
    },
    mocha: {
      timeout: 40000,
    },
  },
};
