// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.4;

import "./interfaces/IExchange.sol";

abstract contract AbstractExchange {
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
    
    struct Operation {
            address _dexAddress; 
            uint256 _amountIn; 
            uint256 _amountOut; 
            address[] _paths;
            uint24[] _poolFees;
    }

    struct Strategy {
        string _lenderSymbol;
        address _loanAsset;
        uint256 _loanAmount;
        bytes[] _ops;
    }

    event InitStrategy(address _baseAsset, uint256 _loanAmount);
}
