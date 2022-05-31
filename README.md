# Arbi-protocol

Flash loan arbitrage strategy.

- Flash loan providers
    - Aave
      - Token list avaiable for Flash loan on Polygon
        - Aave
        - Dai
        - USDC
        - USDT
        - WBTC
        - WETH
        - WMATIC
- Exchanges we are currently aggregating

    - Gravityfinance
    - Dfyn
    - balancer
    - quickswap
    - sushiswap
    - Uniswap V3

- Other Exchanges not yet in bot:
    - 1Inch
    - KyberSwap
    - Uniswa (v2 tbd)
    - Dodo
    - ParaSwap

### Testing
 - Polygon mainnet fork
 ````
 struct Pool{
        address token0;
        address token1;
        uint8   poolFee;
    }
    struct Swap{
        Pool pool;
        uint256 amountIn;
        uint256 amountOutMin;
    }

    struct ArbitrageOperation{
        string dexSymbol;
        Swap [] operations;
    }
 */
````
