const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
const { 
  AAVE,
  ASSETS,
  TREASURY,
  KYBER,
  UNISWAP_V2,
  SUSHI,
  GRAVITYFINANCE,
  DFYN,
  QUICKSWAP,
  BALANCERV2,

} = require("../migrations/address_lookup.js")
const { STRATEGIES ,ENCODE_STRUCTS} = require("./Strategies.js");
const { upgrades } = require("hardhat");
const {BigNumber} =require( "ethers")
    
let strategy, registry, kyber, sushi, uniV2, network, ADMIN;

  before("setup", async function () {
       //***********************************************/
       // **********     WALLET SETUP    ***************
       network = "matic"
       //***********************************************/
   
        const accounts = await ethers.getSigners();
        ADMIN = accounts[0];
        let USER1 = accounts[1];
        console.log("accounts: ",ADMIN.address)

      //***********************************************/
      // *******    DEPLOY STRATEGY LOAN    ***********
      /***********************************************/

      const loopSwapLimit = 3;
      const ArbiTrader = await ethers.getContractFactory("ArbiTrader");
      strategy = await ArbiTrader.deploy(
                                          AAVE.poolAddressesProvider['matic'],
                                          TREASURY.DEV
                                        );
      strategy = await strategy.deployed();
      console.log("strategy at : ",strategy.address);

      const provider  = await ethers.getDefaultProvider("http://localhost:8545");
      const adminBalance = await provider.getBalance(ADMIN.address);

      console.log("ADMIN: ",ADMIN.address, adminBalance);

      await strategy.connect(ADMIN).deposit({value:adminBalance});

      const traderBalance = await provider.getBalance(strategy.address);
      console.log('traderBalance: ',traderBalance);
    })



    describe("ArbiTrader",function () {
      it("Should start the loan", async function () {

      /***********************************************/
      // **********   ARBITRAGE  STRATEGY    *********
      /***********************************************/  

      //  const data = {
      //       "loanInfo": {
      //           "amount": LOAN_AMOUNT,
      //           "asset": token1
      //       },
      //       "strategies": [
      //           {
      //               "dexSymbol": {'dexA': node_left.dex, 'dexB': node_right.dex},
      //               "tokenA": TOKENS[token1],
      //               "tokeB": TOKENS[token2] if token2 in TOKENS else STABLES[token2],
      //               "pool": {"poolA": node_left.address, "poolB": node_right.address},
      //               "priceA": minimum,
      //               "priceB": maximum
      //           }
      //       ]
      //   };

        // Test strategy
        const LOAN_AMOUNT =  ethers.utils.parseEther("500");

        const abiCoder = await ethers.utils.defaultAbiCoder;
        const operations = await abiCoder.encode(
          [ 
            'string',
            'address[]',
            'string',
            'address[]'
          ],
           [
             "SUSHI",
            ["0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"],
            "QS",
            ["0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174","0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"]
        ] );
         console.log(operations)

          /***********************************************/
          // **********  INIT FLASH BOYZ (LOAN)  *********
          /***********************************************/  

          const UNI_DEXES_MATIC  = {
            GF: GRAVITYFINANCE.router[network],
            QS: QUICKSWAP.router[network],
            SUSHI: SUSHI.router[network],
            // UNIV2: UNISWAP_V2.router[network]
          }
          
          for (const ticker in UNI_DEXES_MATIC) {
            await strategy.connect(ADMIN).addUniForkDex(ticker,UNI_DEXES_MATIC[ticker]);
            console.log('trader added: ', ticker,' with address: ',UNI_DEXES_MATIC[ticker])
          }

         await strategy.connect(ADMIN).performStrategy(
            "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", // loan asset
            LOAN_AMOUNT, // amount to milk aave
            operations // operations byte[]
          );

         
        });
    });