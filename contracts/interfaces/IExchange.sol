// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

interface IExchange {
    function swap(
                address token0,
                address token1,
                uint256 poolFee,
                uint256 amountIn,
                uint256 amountOutMinimum
    ) external returns (bool _success);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
