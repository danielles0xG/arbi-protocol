// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

abstract contract AbstractExchange {

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

    event InitStrategy(address _baseAsset, uint256 _loanAmount);

}
