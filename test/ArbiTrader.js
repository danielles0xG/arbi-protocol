const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
const { upgrades } = require("hardhat");
const {BigNumber} =require( "ethers");
const Web3 = require('web3');
const web3 = new Web3();
const { 
  AAVE,
  DYDX,
  ASSETS,
  TREASURY,
  KYBER,
  UNISWAP_V2,
  UNISWAP_V3,
  SUSHI,
  GRAVITYFINANCE,
  DFYN,
  QUICKSWAP,
  BALANCERV2
} = require("../migrations/address_lookup.js");

const { STRATEGIES , ENCODE_STRUCTS} = require("./Strategies.js");

let strategy, provider, adminBalance, deposit, balanceETH;

describe("ArbiTrader",function () {
      it("Should start the loan", async function () {
        let strategy, registry, kyber, sushi, uniV2;

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
       this.strategy = await ArbiTrader.deploy(
                                           AAVE.poolAddressesProvider['matic'],
                                           TREASURY.DEV
                                         );
       this.strategy = await this.strategy.deployed();
       console.log("strategy at : ",this.strategy.address);
       provider  = await ethers.getDefaultProvider("http://localhost:8545");
       adminBalance = await provider.getBalance(ADMIN.address);
       deposit = adminBalance * 1000 * .05 / 1000;
       balanceETH =   ethers.utils.formatEther(adminBalance.toString());
       console.log("ADMIN: ",ADMIN.address, 'balance : ',balanceETH);
       console.log('deposit: ',ethers.utils.formatEther(deposit.toString()));
     });
 
 
     describe("Deposit gas funds",function () {
       it("Should deposit", async function () {
 
             let wallet = new ethers.Wallet(process.env.PRIVATE_KEY_POC , provider);
             let receiverAddress = this.strategy.address
             let amountInEther = ethers.utils.formatEther(deposit.toString());
 
             let tx = { to: receiverAddress, value: ethers.utils.parseEther(amountInEther) };
 
             await wallet.sendTransaction(tx).then((txObj) => {
                 console.log('txHash', txObj.hash)
             }).catch(err => console.log(err));
           
             const traderBalance = await provider.getBalance(this.strategy.address);
             console.log('traderBalance: ',traderBalance);
 
         });
     });

        // Test strategy
        const LOAN_AMOUNT = 5000;
        const AMOUNT_OUT = LOAN_AMOUNT;

        const operations = web3.eth.abi.encodeParameters(
          [
            {
              "swap1":{ 
                "_dexAddress_1" : 'address',
                "_amountIn_1" : 'uint256',
                "_amountOut_1" : 'uint256',
                "_path_1" : 'address[]',
                "_poolFees_1" : 'uint24[]'
              }
            },
            {
              "swap1":{ 
                "_dexAddress_1" : 'address',
                "_amountIn_1" : 'uint256',
                "_amountOut_1" : 'uint256',
                "_path_1" : 'address[]',
                "_poolFees_1" : 'uint24[]'
              }
            }
          ],
          [
            {
              "_dexAddress_1" : UNISWAP_V3.swapRouter,
              "_amountIn_1" : LOAN_AMOUNT,
              "_amountOut_1" : BigNumber.from(AMOUNT_OUT), 
              "_path_1" :[ASSETS.matic.WMATIC,ASSETS.matic.WETH,ASSETS.matic.WMATIC],
              "_poolFees_1" :[400,2000]
            },
            {
              "_dexAddress_1" : UNISWAP_V3.swapRouter,
              "_amountIn_1" : LOAN_AMOUNT,
              "_amountOut_1" : BigNumber.from(AMOUNT_OUT), 
              "_path_1" :[ASSETS.matic.WMATIC,ASSETS.matic.WETH,ASSETS.matic.WMATIC],
              "_poolFees_1" :[400,2000]
            }
          ]
        );
        console.log('operations: ',operations)
        // const operations = await abiCoder.encode(
        //   ['bytes'], [ OPERATIONS ]
        // );


        /***********************************************/
        // **********  INIT FLASH BOYZ (LOAN)  *********
        /***********************************************/  

         await this.strategy.connect(ADMIN).performStrategy(
            ASSETS[network].AAVE, // loan asset
            LOAN_AMOUNT, // amount to milk aave
            operations // operations byte[]
          );

         
        });
    });