//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IDMMRouter02.sol";
import "../../interfaces/IExchange.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract KyberswapV2 is OwnableUpgradeable,IExchange {

    IDMMRouter02 public _router;
    function init(address router_)public initializer {
        _router = IDMMRouter02(router_);
    }


    function swapExactTokensForTokens(
                uint256 amountIn,
                uint256 amountOutMin,
                address[] calldata poolsPath,
                address[] calldata path,
                address to,
                uint256 swapTimeout,
                uint160 loopLimit
    ) external override returns (uint256 amounts){
        SafeERC20.safeTransferFrom(IERC20(path[0]),_msgSender(),address(this),amountIn);
        SafeERC20.safeApprove(IERC20(path[0]), address(_router), amountIn);

        IERC20[] memory currentPath = _wrapIERC20(path,loopLimit);

        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                 amountIn,
                 amountOutMin,
                 poolsPath,
                 currentPath, // IERC20 []
                 to,
                 block.timestamp + swapTimeout
            );
    }

    function _wrapIERC20(address[] calldata _addresses, uint160 _limit) internal returns(IERC20[] memory path){
         for (uint160 i = 0; i < _limit + 1; i++) {
            IERC20 _wrappedAsset = IERC20(_addresses[i]);
            path[i] = _wrappedAsset;
         }
         return path;
        }
}
