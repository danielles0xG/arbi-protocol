//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IDMMRouter02.sol";

import "./interfaces/IDMMFactory.sol";
import "./interfaces/IDMMPool.sol";

import "../../interfaces/IExchange.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract KyberswapV2 is OwnableUpgradeable, IExchange {

    IDMMRouter02 public _router;
    IDMMFactory public _factory;

    function initialize(address router_, address _factoryV2) external initializer {
        __Ownable_init();
        _router = IDMMRouter02(router_);
        _factory = IDMMFactory(_factoryV2);
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
        IERC20(path[0]).transferFrom(_msgSender(),address(this),amountIn);
        IERC20(path[0]).approve(address(_router), amountIn);

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

        function getPools(IERC20 _token0, IERC20 _token1)
        external
        view
        returns (address[] memory _tokenPools){
            _tokenPools = _factory.getPools(_token0,_token1);
    }

    function getReserves(address poolAddress_) external view returns (address _poolAddress,uint112 reserve0, uint112 reserve1){
        (reserve0,reserve1) = IDMMPool(poolAddress_).getReserves();
    }

    function getTradeInfo(address _poolAddress) public view returns(
            uint112 _vReserve0,
            uint112 _vReserve1,
            uint112 reserve0,
            uint112 reserve1,
            uint256 feeInPrecision
        ){
        (_vReserve0,
         _vReserve1,
         reserve0,
         reserve1,
         feeInPrecision) = IDMMPool(_poolAddress).getTradeInfo();
    }

        function getUnamplifiedPool(IERC20 token0, IERC20 token1) external view returns (address){
            return _factory.getUnamplifiedPool(token0,token1);
        }


}
