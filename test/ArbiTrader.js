const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
const { AAVE,ASSETS,TREASURY,KYBER,UNISWAP_V2,SUSHI} = require("../migrations/address_lookup.js")
const { STRATEGIES ,ENCODE_STRUCTS} = require("./Strategies.js");
const { upgrades } = require("hardhat");
const {BigNumber} =require( "ethers")


    describe("ArbiTrader",function () {
      it("Should start the loan", async function () {
        let strategy, registry, kyber, sushi, uniV2;

       //***********************************************/
       // **********     WALLET SETUP    ***************
                      network = "matic"
       //***********************************************/
   
        const accounts = await ethers.getSigners();
        let ADMIN = accounts[0];
        let USER1 = accounts[1];
        console.log("accounts: ",ADMIN.address)

      /***********************************************/
      // *********    DEPLOY REGISTRY    *************
      /***********************************************/

      const DexRegistry = await ethers.getContractFactory("DexRegistry");
      registry = await DexRegistry.deploy();
      registry = await registry.deployed();
      console.log("registry deployed at: ",registry.address);

      //***********************************************/
      // *******    DEPLOY STRATEGY LOAN    ***********
      /***********************************************/

      const loopSwapLimit = 3;
      const ArbiTrader = await ethers.getContractFactory("ArbiTrader");
      strategy = await ArbiTrader.deploy(
                                          AAVE.poolAddressesProvider[network],
                                          TREASURY.DEV,
                                          registry.address,
                                          loopSwapLimit
                                        );
      strategy = await strategy.deployed();

      /***********************************************/
      // *******    DEPLOY EXCHANGE PROXIES   ********
      /***********************************************/

      const KyberswapV2 = await ethers.getContractFactory("KyberswapV2");
      kyber = await upgrades.deployProxy(
        KyberswapV2,
        [ 
          KYBER.router[network],
          KYBER.factory[network]
        ]);
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
      // *******    ADD DEXES TO REGISTRY     ********
      /***********************************************/

      await registry.addExchange('KYBER',kyber.address);
      console.log("Successfully added KYBER to registry...")

      await registry.addExchange('UNIV2',uniV2.address);
      console.log("Successfully added UNIV2 to registry...")

      await registry.addExchange('SUSHI',sushi.address);
      console.log("Successfully added SUSHI to registry...")

      /***********************************************/
      // **********   ARBITRAGE  STRATEGY    *********
      /***********************************************/  

        // load gas budget        
        const gasBudget = ethers.utils.parseUnits("1", "ether");
        const strategyBalance = await strategy.connect(ADMIN).deposit({value: gasBudget});
        console.log("Contract gas budget loaded with: ",gasBudget);
        
        // Define loan amount
        const LOAN_AMOUNT =  ethers.utils.parseEther(".05");
        const AMOUNT_OUT = '23340100000000000000';

        // Sushi params
        console.log("PREPERING sushi params");     
        const AAVE_WETH_DAI_PATH = [ASSETS[network].AAVE, ASSETS[network].WETH, ASSETS[network].DAI];
        const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"
        // encode param operations swaps opportunities        
        const abiCoder = ethers.utils.defaultAbiCoder;
        const timeout = 600;


      const uniswapV2_swapExactTokensForTokens = "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)";
      let ABI = [uniswapV2_swapExactTokensForTokens];
      let iface = new ethers.utils.Interface(ABI);

      const abiCoder = await ethers.utils.defaultAbiCoder;
      const _dexSymbol = "SUSHI";
      
      const swap_dex = await abiCoder.encode(['string'],["SUSHI"]);
      const swap_bytes = iface.encodeFunctionData(
        "swapExactTokensForTokens", [
          100, 99,
          ["0x0157f8eae9754e164cb28d4bdcfea06a833ff561","0x0157f8eae9754e164cb28d4bdcfea06a833ff561"],
          "0x0157f8eae9754e164cb28d4bdcfea06a833ff561",
          0
        ]);
        const opsArray = new Array();

        const encode_strat = await abiCoder.encode([ 'bytes','bytes'],[swap_dex,swap_bytes] );
        opsArray.push(encode_strat);
        
        const operations = await abiCoder.encode(['bytes', encode_strat]);


         console.log(operations)

          /***********************************************/
          // **********  INIT FLASH BOYZ (LOAN)  *********
          /***********************************************/  

         await strategy.connect(ADMIN).performStrategy(
            ASSETS[network].AAVE, // loan asset
            LOAN_AMOUNT, // amount to milk aave
            operations // operations byte[]
          );

         
        });
    });


            //  .swapExactTokensForTokens(
        //   _amountIn_2,
        //   _amountOut_2,
        //   _path_2,
        //   address(this),
        //   block.timestamp)[_path_2.length -1];