// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ISwapRouter.sol";

contract UniswapV3Exchange is OwnableUpgradeable {
    ISwapRouter public router;

    function __UniswapV3Exchange_init(address _router) external initializer {
        __Ownable_init();
        router = ISwapRouter(_router);
    }

    /*function swapTokenForToken(
        address _tokenIn,
        address _tokenOut,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutExpected
    ) external payable returns (uint256) {
    }*/

    function swapExactInputSingle(
        address _tokenIn,
        address _tokenOut,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint24 _poolFee
    ) external payable returns (uint256) {
        SafeERC20.safeTransferFrom(
            IERC20(_tokenIn),
            _msgSender(),
            address(this),
            _amountIn
        );
        SafeERC20.safeApprove(IERC20(_tokenIn), address(router), _amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: _poolFee,
                recipient: _recipient,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMinimum,
                sqrtPriceLimitX96: 0
            });
        return router.exactInputSingle(params);
    }

    function swapExactInput(
        address _tokenIn,
        address _via,
        address _tokenOut,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint24 _poolFeeA,
        uint24 _poolFeeB
    ) external payable returns (uint256) {
        SafeERC20.safeTransferFrom(
            IERC20(_tokenIn),
            _msgSender(),
            address(this),
            _amountIn
        );
        SafeERC20.safeApprove(IERC20(_tokenIn), address(router), _amountIn);
        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: abi.encodePacked(
                    _tokenIn,
                    _poolFeeA,
                    _via,
                    _poolFeeB,
                    _tokenOut
                ),
                recipient: _recipient,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMinimum
            });
        return router.exactInput(params);
    }

    // @dev swap a minimum possible amount of one token
    // for a fixed amount of another token.
    function exactOutputSingle(
        address _tokenIn,
        address _tokenOut,
        address _recipient,
        uint256 _amountOut,
        uint256 _amountInMaximum,
        uint24 _poolFee
    ) external payable returns (uint256 _amountIn) {
        SafeERC20.safeTransferFrom(
            IERC20(_tokenIn),
            _msgSender(),
            address(this),
            _amountInMaximum
        );
        SafeERC20.safeApprove(
            IERC20(_tokenIn),
            address(router),
            _amountInMaximum
        ); // max amount to spend

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: _poolFee,
                recipient: _recipient,
                deadline: block.timestamp,
                amountOut: _amountOut,
                amountInMaximum: _amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        _amountIn = router.exactOutputSingle(params);
        if (_amountIn < _amountInMaximum) {
            SafeERC20.safeApprove(IERC20(_tokenIn), address(router), 0);
            SafeERC20.safeTransfer(
                IERC20(_tokenIn),
                _msgSender(),
                _amountInMaximum - _amountIn
            );
        }
    }

    function exactOutput(
        address _tokenIn,
        address _via,
        address _tokenOut,
        address _recipient,
        uint256 _amountOut,
        uint256 _amountInMaximum,
        uint24 _poolFeeA,
        uint24 _poolFeeB
    ) external payable returns (uint256 _amountIn) {
        SafeERC20.safeTransferFrom(
            IERC20(_tokenIn),
            _msgSender(),
            address(this),
            _amountInMaximum
        );
        SafeERC20.safeApprove(
            IERC20(_tokenIn),
            address(router),
            _amountInMaximum
        );

        ISwapRouter.ExactOutputParams memory params = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(
                    _tokenOut,
                    _poolFeeA,
                    _via,
                    _poolFeeB,
                    _tokenIn
                ),
                recipient: _recipient,
                deadline: block.timestamp,
                amountOut: _amountOut,
                amountInMaximum: _amountInMaximum
            });

        // Executes the swap, returning the amountIn actually spent.
        _amountIn = router.exactOutput(params);
        if (_amountIn < _amountInMaximum) {
            SafeERC20.safeApprove(IERC20(_tokenIn), address(router), 0);
            SafeERC20.safeTransfer(
                IERC20(_tokenIn),
                _msgSender(),
                _amountInMaximum - _amountIn
            );
        }
    }

    /**
     Any contract that calls IUniswapV3PoolActions
     calling a flashwap makes this contract funds recipient

    uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes memory data
    ) external  {
        address sender = abi.decode(data, (address));
        if (amount0Delta > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token0()).transferFrom(sender, msg.sender, uint256(amount0Delta));
        } else {
            assert(amount1Delta > 0);
            IERC20(IUniswapV3Pool(msg.sender).token1()).transferFrom(sender, msg.sender, uint256(amount1Delta));
        }
    }*/
}
