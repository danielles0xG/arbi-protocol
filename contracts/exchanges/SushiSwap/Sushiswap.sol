//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../../interfaces/IExchange.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Sushiswap is OwnableUpgradeable,IExchange {
  IUniswapV2Router02 public _sushiswapRouter;
    function initialize(address router_) external initializer {
         __Ownable_init();
        _sushiswapRouter = IUniswapV2Router02(router_);
    }

    function swapExactTokensForTokens(
                uint256 amountIn,
                uint256 amountOut,
                address[] calldata poolsPath, // kyberOnly
                address[] calldata path,
                address to,
                uint256 swapTimeout,
                uint160 loopLimit
        ) external override returns (uint256) {
        IERC20(path[0]).transferFrom(_msgSender(),address(this),amountIn);
        IERC20(path[0]).approve(address(_sushiswapRouter), amountIn);
        address[] memory pairs;

        if (path[1] == address(0)) {
            pairs = new address[](2);
         pairs[0] = path[0];
            pairs[1] = path[1];
        } else {
            pairs = new address[](3);
            pairs[0] = path[0];
            pairs[1] = path[1];
            pairs[2] = path[2];
        }

        return
                _sushiswapRouter.swapExactTokensForTokens(
                amountIn,
                amountOut,
                pairs,
                to,
                block.timestamp + swapTimeout
            )[pairs.length - (1)];
}
}