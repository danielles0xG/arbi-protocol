require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-contract-sizer");
require("@openzeppelin/hardhat-upgrades");
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
    dev: {
      url: "http://localhost:8545",
      gasPrice: "auto",
      accounts: [
        process.env.PRIVATE_KEY
      ],
    },
    polygon: {
      // url:`https://rpc.ankr.com/polygon`,
      url: `https://twilight-icy-log.matic.quiknode.pro/${process.env.QUICK_NODE_KEY}/`,
      accounts: [process.env.PRIVATE_KEY],
      network_id: 137, // polygon's id
      gasPrice: "auto", //44Wei
      timeoutBlocks: 200,
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
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
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
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
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.7.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200, // 1000000, reduces costs in tx but increases them in deployment
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
  etherscan:{
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
};
