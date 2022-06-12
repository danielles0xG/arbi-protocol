require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-contract-sizer');
require('@openzeppelin/hardhat-upgrades');
// Task action function receives the Hardhat
// Runtime Environment as second argument


module.exports = {
  defaultNetwork: "hardhat",
  // paths: {
  //   sources: './contracts',
  //   tests: './test',
  //   artifacts: './artifacts',
  //   cache: './cache'
  // },
  networks: {
    hardhat: {
      forking: {
        url: "http://localhost:8545",
        accounts: [
          process.env.PRIVATE_KEY_POC
        ],
      }
    },
    dev: {
      url: "http://localhost:8545",
      gasPrice: "auto",
      accounts: [
        process.env.PRIVATE_KEY_POC
      ],
    },

    // matic: {
    //   // url: `https://twilight-icy-log.matic.quiknode.pro/${process.env.QUICK_NODE_KEY}`,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    // mumbai: {
    //   // url: `https://polygon-mumbai.infura.io/v3/${process.env.PROJECT_ID}`,
    //   // wss://polygon-mumbai.infura.io/ws/v3/${process.env.PROJECT_ID}
    //   accounts: [process.env.PRIVATE_KEY],
    // },
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
          // outputSelection: {
          //     "*": {
          //         "*": ["storageLayout"],
          //     },
          // },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.7.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200 // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
    ],
    // paths: {
    //   sources: "./contracts",
    //   tests: "./test",
    //   // cache: "./cache",

    // },
    mocha: {
      timeout: 40000,
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: false,
    strict: true
  }
};
