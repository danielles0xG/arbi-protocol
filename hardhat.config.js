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
      console.log( ethers.provider)
    });
  }
);

module.exports = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/<key>",
        blockNumber: 14390000,
      },
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
  },
};
