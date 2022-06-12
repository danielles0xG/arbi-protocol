//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
import "../../lib/forge-std/src/Test.sol";
import "../../contracts/ArbiTrader.sol";


contract ArbiTraderTest is Test {
    ArbiTrader public trader;
    address ADMIN = 0x0157f8EAe9754e164cB28D4bDcFEa06A833ff561;

    address DAI =    0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; //18 decimals
    address AAVE =   0xD6DF932A45C0f255f85145f286eA0b292B21C90B; //18 decimals
    address USDC =   0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // 6 decimals
    address USDT =   0xc2132D05D31c914a87C6611C10748AEb04B58e8F; // 6 decimals
    address WBTC =   0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6; // 8 decimals
    address WETH =   0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; // 18 decimals
    address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // 18 decimals


    address GRAVITY_FINANCE_ROUTER = 0x57dE98135e8287F163c59cA4fF45f1341b680248;
    address QUICK_SWAP_ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address SUSHI_SWAP_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506; 


    function setUp() external{
        trader = new ArbiTrader(
            0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb,
            0x1d3Af21a1889A1262980Fb8021bF91B792584A88
        );
        console.log('ADMIN NBALANCE ::: ',address(ADMIN).balance);

        trader.addUniForkDex("GF", GRAVITY_FINANCE_ROUTER);
        console.log('DEX GRAVITY_FINANCE_ROUTER :::',trader._uniForkDexes("GF"));

        trader.addUniForkDex("QS", QUICK_SWAP_ROUTER);
        console.log('DEX QUICK_SWAP_ROUTER :::',trader._uniForkDexes("QS"));

        trader.addUniForkDex("SUSHI", SUSHI_SWAP_ROUTER);
        console.log('DEX SUSHI_SWAP_ROUTER :::',trader._uniForkDexes("SUSHI"));
    }

    function testDeposit() external{
        vm.prank(ADMIN);
        trader.deposit{value:address(ADMIN).balance}();
        vm.stopPrank();

        console.log('thisBalance:  ',address(trader).balance);
    }

    function testStrategy() external {

        address[] memory path1 = new address[](2);
        path1[0] = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        path1[1] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

        address[] memory path2 = new address[](2);
        path2[0] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        path2[1] = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

        bytes memory __data = abi.encode(
                "SUSHI", path1,
                "QS", path2
            );

        trader.performStrategy(
                WMATIC,
                500000000000000000000,
                __data
            );
    }
}
