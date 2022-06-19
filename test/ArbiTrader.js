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
       provider  = await ethers.getDefaultProvider("http://localhost:8545");
       adminBalance = await provider.getBalance(ADMIN.address);
       deposit = adminBalance * 1000 * .5 / 1000;
       balanceETH = ethers.utils.formatEther(adminBalance.toString());
       
       console.log("ADMIN: ",ADMIN.address, 'balance : ',balanceETH);
       console.log('deposit: ',ethers.utils.formatEther(deposit.toString()));
 
      let wallet = new ethers.Wallet(process.env.PRIVATE_KEY_POC , provider);
      let amountInEther = ethers.utils.formatEther(deposit.toString());
      
      let tx = { 
        to: strategy.address,
        value: ethers.utils.parseEther(amountInEther)
      };

      await wallet.sendTransaction(tx)
      .then((txObj) => {console.log('txHash', txObj.hash)})
      .catch(err => console.log(err));
    
      const traderBalance = await provider.getBalance(strategy.address);
      console.log('traderBalance: ',traderBalance);
 

        // Test strategy
        const LOAN_AMOUNT = ethers.utils.parseEther(500);
        const AMOUNT_OUT = ethers.utils.parseEther();
        const abiCoder = await ethers.utils.defaultAbiCoder;

        const operation_1 = abiCoder.encode(
            ['string','address','uint256','uint256','address[]','uint24[]'],
            [
              "UNIV3",
              UNISWAP_V3.swapRouter,
              ethers.utils.parseUnits("66080.2");,
              BigNumber.from(AMOUNT_OUT), 
              [ 
                ASSETS[network].AAVE, 
                ASSETS[network].WMATIC
              ],
              [3000]
            ]
        ) 

        const operation_2 = abiCoder.encode(
          ['string','address','uint256','uint256','address[]','uint24[]'],
          [ 
            "UNIV2",
            UNISWAP_V2.router[network],
            LOAN_AMOUNT,
            BigNumber.from(AMOUNT_OUT), 
            [
              ASSETS[network].WMATIC,
              ASSETS[network].AAVE
            ],
            [0]
          ]
      ) 


        const Operations = new Array();
        Operations.push(operation_1);
        Operations.push(operation_2);

        const Strategy =
         {
            _strategyId: 'V1/polygon/001',
            _strategyLength: 2,
            _lenderSymbol: "AAVE",
            _loanAsset: ASSETS[network].AAVE,
            _loanAmount: LOAN_AMOUNT ,
            _ops: Operations
         }

        /***********************************************/
        // **********  INIT FLASH BOYZ (LOAN)  *********
        /***********************************************/  
        // console.log('_strategyLength: ',Strategy._strategyLength);
        await strategy.connect(ADMIN).performStrategy(Strategy);
        
    });
  });
