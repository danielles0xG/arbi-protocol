# Arbi-protocol

Flash loan arbitrage strategy.

- Flash loan providers
    - Aave
- Exchanges
    - 1Inch
    - KyberSwap
    - Uniswap V3 (v2 tbd)
    - SushiSwap (tbd)
    - Dodo
    - ParaSwap
    - Balancer

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