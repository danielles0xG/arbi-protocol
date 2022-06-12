//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import {DataTypes} from "./loans/utils/DataTypes.sol";
import "./loans/aaveV3/interfaces/IFlashLoanSimpleReceiver.sol";
import "./loans/aaveV3/interfaces/IPoolAddressesProvider.sol";
import "./interfaces/IERC20.sol";

import "../lib/forge-std/src/console.sol";
/**
 * @notice Functional contract is FlashLoanReceiverBase
 * @dev Contract will NOT store funds or store any given state.
 */
contract ArbiTrader is IFlashLoanSimpleReceiver,ReentrancyGuard {
    IPoolAddressesProvider public aavePoolProvider;
    IPool public aavePool;

    mapping(string => address) public _uniForkDexes;


    address public owner;
    address public treassury;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    constructor(
        address _aavePoolProvider,
        address _treassury
    ) {
        owner = msg.sender;
        treassury = payable(_treassury);
        aavePoolProvider = IPoolAddressesProvider(_aavePoolProvider);
        aavePool = IPool(aavePoolProvider.getPool());
    }

    function addUniForkDex(string memory _dexTicker, address _dexRouter) external{
        _uniForkDexes[_dexTicker] = _dexRouter;
    }

    /// @dev Deposit funds to cover gas costs 
    function deposit() external payable  returns(uint256){
        require(msg.value > 0, "Gas costs are high come on!");
        return address(this).balance;
    }

    /**
     * @notice Main function to trigger arbitrage
     * @param _asset address
     * @param _amount borrowed
     * @param _operations array of exchanges and swaps to perform
     */
    function performStrategy(
        address _asset,
        uint256 _amount,
        bytes calldata _operations
    ) external  {
        _initFlashLoan(_asset, _amount, _operations);
    }

    function _initFlashLoan(
        address _baseAsset,
        uint256 _loanAmount,
        bytes calldata _params
    ) internal onlyOwner {
        aavePool.flashLoanSimple(
            address(this),
            _baseAsset,
            _loanAmount,
            _params,
            0
        );
    }

    function _logAssetBalance(string memory _msg, address _asset,address _of) internal {
        console.log( _msg, IERC20(_asset).symbol(), ' is :::',IERC20(_asset).balanceOf(address(_of)) );
    }

    function executeOperation(
        address _asset,
        uint256 _amount,
        uint256 _premium,
        address _initiator,
        bytes calldata _operations
    ) external override returns (bool) {

        _logAssetBalance('TRADER LOAN BALANCE ::: ', _asset,address(this));
            

        require(
            IERC20(_asset).balanceOf(address(this)) >= _amount,
            "AT1 Loan Transfer Fail"
        );
        // Avee Pool calling executeOperation function on out contract
           _executeOperation(_asset,_operations);
        // Repay: Approve aave pool to take loan amount + fees

        uint256 _payment = _amount + aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL();

        console.log('Repaying the loan :::', _payment);
        _logAssetBalance('Trader balance after repay :::', _asset, address(this));

        IERC20(_asset).approve( address(aavePool), _payment);

        uint256 loanAssetBalance = IERC20(_asset).balanceOf(address(this));

        if(loanAssetBalance > _payment){
            console.log("PROFIT ::: ",loanAssetBalance - _payment);
        }else{
            console.log("MISSING ::: ",_payment - loanAssetBalance);
        }

        return true;
    }



    /**
    * @notice IFlashLoanSimpleReceiver implementation
    * @dev Loan provider lending criteria
    * @param _strategy Array of encoded operarions (swaps)
     */
    function _executeOperation(address _asset,bytes calldata _strategy) internal {
            
            (
             string memory _dexSymbol_1,
             address[] memory _path_1,
             string memory _dexSymbol_2,
             address[] memory _path_2
             ) =  abi.decode( _strategy,(string, address[], string, address[] ));
        
            console.log("_dexSymbol_1:" ,_dexSymbol_1);
            console.log('_path_1: ',_path_1[0]);
          
          
            // SWAP 1

            address _routerAddress_1 = _uniForkDexes[_dexSymbol_1];

            require(_asset == _path_1[0], "loan asset diff from first swap tokenA");
            uint256 _amountIn_1 = IERC20(_asset).balanceOf(address(this));

            uint256 _amountOut_1 = IUniswapV2Router02(_routerAddress_1).getAmountsOut(_amountIn_1, _path_1)[_path_1.length -1];

            IERC20(_asset).approve(address(_routerAddress_1),_amountIn_1);
            console.log('_amountIn_1: ',_amountIn_1);
            console.log('_amountOut_1: ',_amountOut_1);
            uint256 swapResult_1 = IUniswapV2Router02(_routerAddress_1).swapExactTokensForTokens(
                    _amountIn_1,
                    _amountOut_1,
                    _path_1,
                    address(this),
                    block.timestamp)[_path_1.length -1];

            console.log('swapResult_1: ',swapResult_1);
            require(swapResult_1 > 0, 'swap1 failed.');
            
            // SWAP 2

            if(IERC20(_path_1[_path_1.length-1]).balanceOf(address(this)) >= swapResult_1){
        
                address _routerAddress_2 = _uniForkDexes[_dexSymbol_2];

                IERC20(_path_2[0]).approve(address(_routerAddress_2),_amountIn_1);

                uint256 _amountIn_2 = swapResult_1;

                uint256 _amountOut_2 = IUniswapV2Router02(_routerAddress_2).getAmountsOut(_amountIn_2, _path_2)[_path_2.length -1];
                
                console.log('_amountIn_2: ',swapResult_1);
                console.log('_amountOut_2: ',_amountOut_2);
                
                uint256 swapResult_2 = IUniswapV2Router02(_routerAddress_2).swapExactTokensForTokens(
                    _amountIn_2,
                    _amountOut_2,
                    _path_2,
                    address(this),
                    block.timestamp)[_path_2.length -1];

                console.log('swapResult_2: ',swapResult_2);
                require(swapResult_2 > 0, 'swap2 failed.');
            }
    
    }


    function _withdrawProfit(address _asset) internal  {
        uint256 assetBalance = IERC20(_asset).balanceOf(address(this));
        require(assetBalance > 0 , "No profit yet for this asset.");
        IERC20(_asset).approve(address(treassury),assetBalance);
        IERC20(_asset).transferFrom(address(this),address(treassury),assetBalance);
    }

    function _withdrawNativeProfit() internal  nonReentrant {
        uint256 _nativeTokenBalance = address(this).balance;
        require(_nativeTokenBalance > 0 , "No profit yet for this native currency.");
        (bool _success, ) = treassury.call{value: _nativeTokenBalance}(" ");
        require(_success);
    }


    fallback() external payable {
    }
    receive() external payable {
    } 
}


