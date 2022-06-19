//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {DataTypes} from "./loans/utils/DataTypes.sol";
import "./loans/aaveV3/interfaces/IFlashLoanSimpleReceiver.sol";
import "./loans/aaveV3/interfaces/IPoolAddressesProvider.sol";
import "./AbstractExchange.sol";
import "./interfaces/IExchangeRegistry.sol";
import "./interfaces/IExchange.sol";
import "./AbstractExchange.sol";
import "./exchanges/UniswapV2/interfaces/IUniswapV2Router02.sol";
import "./exchanges/UniswapV3/interfaces/ISwapRouter.sol";

/**
 * @notice Functional contract is FlashLoanReceiverBase
 * @dev Contract will NOT store funds or store any given state.
 */
contract ArbiTrader is IFlashLoanSimpleReceiver, ReentrancyGuard, AbstractExchange{

    IPoolAddressesProvider public _aavePoolProvider;
    IPool public _aavePool;

    address public _owner;
    address public _treassury;
    event FailSwapEvent(address _dexAddress);
    event StrategyEvent(string _strategyId);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only Owner");
        _;
    }

    constructor(
        address aavePoolProvider_,
        address treassury_
    ) {
        _owner = msg.sender;
        _treassury = payable(treassury_);
        _aavePoolProvider = IPoolAddressesProvider(aavePoolProvider_);
        _aavePool = IPool(_aavePoolProvider.getPool());
    }

    /// @dev Deposit funds to cover gas costs
    function deposit() external payable onlyOwner returns (uint256) {
        require(msg.value > 0, "Gas costs are high come on!");
        return address(this).balance;
    }

    /**
     * @notice Main function to trigger arbitrage
     * @param _strategy Object containing loan details and swap operations 
     */
    function performStrategy(Strategy memory _strategy) external onlyOwner {
        (bytes memory _data) = abi.encode(_strategy);
        _aavePool.flashLoanSimple(
            address(this),
            _strategy._loanAsset,
            _strategy._loanAmount,
            _data,
            0
        );
    }
    /**
     * @notice IFlashLoanSimpleReceiver implementation
     * @dev Loan provider lending criteria
     */
    function executeOperation(
        address _asset,
        uint256 _amount,
        uint256 _premium,
        address _initiator,
        bytes calldata _data
    ) external override returns (bool) {
        require(IERC20(_asset).balanceOf(address(this)) >= _amount,"AT: Loan Transfer Fail");
        Strategy memory strategy = abi.decode(_data, (Strategy));

        for(uint8 i = 0; i < strategy._strategyLength; i++){
            Operation memory _operation = _decodeOperation(strategy._ops[i]);
            if(_swap(_operation) < _operation._amountOut) emit FailSwapEvent(_operation._dexAddress);
        }
        IERC20(_asset).approve(address(_aavePool),_amount + _aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL());
        
        // Event to fire when profitable strategy completes; Monitor strat IDs on controller logs
        emit StrategyEvent(strategy._strategyId);
        return true;
    }

    /* 
         @dev Current version only supports single hop routes.
    */
    function _swap(Operation memory operation) internal returns(uint256 _amountOut){
        IERC20(operation._paths[0]).approve(operation._dexAddress, operation._amountIn);
        if(keccak256(bytes(operation._dexSymbol)) == keccak256(bytes("UNIV3"))){
            _amountOut = ISwapRouter(operation._dexAddress).exactInputSingle(
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: operation._paths[0],
                    tokenOut: operation._paths[1],
                    fee: operation._poolFees[0],
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: operation._amountIn,
                    amountOutMinimum: operation._amountOut,
                    sqrtPriceLimitX96: 0
                })
            );
        }else{
             _amountOut = IUniswapV2Router02(operation._dexAddress)
                                .swapExactTokensForTokens(
                                    operation._amountIn,
                                    operation._amountOut,
                                    operation._paths,
                                    address(this),
                                    block.timestamp
                                )[1];
        }
    } 

    function _decodeOperation(bytes memory operation) internal returns(Operation memory _operation){
       (
        _operation._dexSymbol,
        _operation._dexAddress,
        _operation._amountIn,
        _operation._amountOut,
        _operation._paths,
        _operation._poolFees) = abi.decode(operation,(string, address, uint256, uint256, address[], uint24[]));
    }
    
    function _withdrawProfit(address _asset) internal onlyOwner {
        uint256 assetBalance = IERC20(_asset).balanceOf(address(this));
        require(assetBalance > 0, "No profit yet for this asset.");
        IERC20(_asset).approve(address(_treassury), assetBalance);
        IERC20(_asset).transfer(address(_treassury),assetBalance);
    }
    

    function _withdrawNativeProfit() internal onlyOwner nonReentrant {
        uint256 _nativeTokenBalance = address(this).balance;
        require(
            _nativeTokenBalance > 0,
            "No profit yet for this native currency."
        );
        (bool _success, ) = _treassury.call{value: _nativeTokenBalance}(" ");
        require(_success);
    }

    fallback() external payable {

    }

    receive() external payable {
    }
}
