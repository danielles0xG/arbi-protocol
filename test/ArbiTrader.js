const { expect } = require("chai");
const { ethers, hre, network } = require("hardhat");
const { AAVE,ASSETS,TREASURY,KYBER,UNISWAP_V2,SUSHI} = require("../migrations/address_lookup.js")
const { STRATEGIES ,ENCODE_STRUCTS} = require("./Strategies.js");
const { upgrades } = require("hardhat");
const {BigNumber} =require( "ethers")

    // before(async function() {

    // })


    // before(async function() {
    
    // });

    describe("ArbiTrader",function () {
      it("Should start the loan", async function () {
   
        const accounts = await ethers.getSigners();
        let ADMIN = accounts[0];
        let USER1 = accounts[1];
        console.log("accounts: ",ADMIN.address)


        let strategy, registry, kyber, sushi, uniV2;
        network = "matic"

        const encoded_params = [];
        const abiCoder = ethers.utils.defaultAbiCoder;
      /***********************************************/
      // ********** DEPLOY REGISTRY **********
      /***********************************************/

      const DexRegistry = await ethers.getContractFactory("DexRegistry");
      registry = await DexRegistry.deploy();
      registry = await registry.deployed();
      console.log("registry deployed at: ",registry.address);

      //***********************************************/
      // ********** DEPLOY STRATEGY LOAN **********
      /***********************************************/
      const ArbiTrader = await ethers.getContractFactory("ArbiTrader");
      strategy = await ArbiTrader.deploy('0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb', TREASURY.DEV,registry.address);
      strategy = await strategy.deployed();
   


      /***********************************************/
      // ********** DEPLOY EXCHANGE PROXIES **********
      /***********************************************/

      const KyberswapV2 = await ethers.getContractFactory("KyberswapV2");
      kyber = await upgrades.deployProxy(KyberswapV2,[ KYBER.router[network] ]);
      kyber = await kyber.deployed(); 
      console.log("KyberSwap deployed at: ",kyber.address);

      // DEPLOY UniswapV2 EXCHANGE CONTRACT
      const UniswapV2 = await ethers.getContractFactory("UniswapV2");
      uniV2 = await upgrades.deployProxy(UniswapV2,[ KYBER.router[network] ]);
      uniV2 = await uniV2.deployed(); 
      // await uniV2.init( UniswapV2, );
      console.log("UniswapV2 deployed at: ", uniV2.address);


    // DEPLOY Sushiswap EXCHANGE CONTRACT
      const Sushiswap = await ethers.getContractFactory("Sushiswap");
      sushi = await upgrades.deployProxy(Sushiswap,[ SUSHI.router[network] ] );
      sushi = await sushi.deployed(); 
      console.log("Sushiswap deployed at: ", sushi.address);


      /***********************************************/
      // ********** ADD DEXES TO REGISTRY **********
      /***********************************************/
      await registry.addExchange('KYBER',kyber.address);
      await registry.addExchange('UNIV2',uniV2.address);
      await registry.addExchange('SUSHI',sushi.address);
      console.log("Successfully added exchanges to registry...")


      
      /***********************************************/
      // **********  STRATEGY ******************
      /***********************************************/  


        // load gas budget        
        const gasBudget = ethers.utils.parseUnits("1", "ether");
        const strategyBalance = await strategy.connect(ADMIN).deposit({value: gasBudget});
        console.log("Contract gas budget loaded with: ", ethers.utils.parseUnits(strategyBalance, "gwei"));
        
        // Define loan amount
        const LOAN_AMOUNT =  ethers.utils.parseUnits("5", "ether");
        const fake_slippage = LOAN_AMOUNT - ethers.utils.formatUnits(02, "gwei");

        //Kyber get pools involved
        const AAVE_DAI_POOLS = await kyber.getUnamplifiedPool(ASSETS[network].AAVE,ASSETS[network].DAI);
        console.log("AAVE_DAI_POOLS: ",AAVE_DAI_POOLS.toString())        

        // encode param operations swaps opportunities        
        // const params = await abiCoder.encode(
        //   [ 'string', //_dexSymbol,
        //     'uint256', //_amountIn,
        //     'uint256', //_amountOut,
        //     'address[]', // pools path kyberOnly
        //     'address[]', //_path,
        //     'address', //_to,
        //     'uint256' //_swapTimeout
        //   ],
        //   [
        //     "KYBER",
        //     LOAN_AMOUNT,
        //     fake_slippage, 
        //     AAVE_DAI_POOLS,
        //   ]
        //  )
         console.log(encoded_params)

         // init loan
         await strategy.connect(ADMIN).performStrategy(
            ASSETS[network].AAVE, // loan asset
            loanAmount, // amount to milk aave
            params // operations byte[]
          );

         
        });
    });