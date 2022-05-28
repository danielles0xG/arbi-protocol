//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract UniswapV2 is OwnableUpgradeable{

    IUniswapV2Router02 public _uniswapRouter;
    constructor(address _router){
        _uniswapRouter = IUniswapV2Router02(_router);
    }


    function _swapTokenForToken(
        uint256 _amountIn,
        address _from,
        address _to,
        address _via
    ) internal returns (uint256) {
        if (_amountIn == 0) {
            return 0;
        }

        address[] memory pairs;

        if (_via == address(0)) {
            pairs = new address[](2);
            pairs[0] = _from;
            pairs[1] = _to;
        } else {
            pairs = new address[](3);
            pairs[0] = _from;
            pairs[1] = _via;
            pairs[2] = _to;
        }

        uint256 _expectedOut = _priceFeed.howManyTokensAinB(_to, _from, _via, _amountIn, false);
        uint256 _amountOutMin = _expectedOut.mul(99).div(100);

        return
            _uniswapRouter.swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                pairs,
                address(this),
                block.timestamp.add(600)
            )[pairs.length.sub(1)];
    }


}