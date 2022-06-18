// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExchange {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath, // kyberOnly
        address[] calldata path,
        address to,
        uint256 swapTimeout,
        uint160 _loopLimit
    ) external returns (uint256 amounts);
}
