// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

import "./interfaces/IExchange.sol";
abstract contract AbstractExchange is IExchange{
    struct Pool {
        address token0;
        address token1;
        uint8 poolFee;
    }
    struct Swap {
        Pool pool;
        uint256 amountIn;
        uint256 amountOutMin;
    }

    struct ArbitrageOperation {
        string dexSymbol;
        Swap[] operations;
    }

    function swap(
                address token0,
                address token1,
                uint256 poolFee,
                uint256 amountIn,
                uint256 amountOutMinimum
    ) external returns (bool _success){
        
    }

    event InitStrategy(address _baseAsset, uint256 _loanAmount);
}
