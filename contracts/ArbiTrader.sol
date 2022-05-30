//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {DataTypes} from "./loans/utils/DataTypes.sol";
import "./loans/aaveV3/interfaces/IFlashLoanSimpleReceiver.sol";
import "./loans/aaveV3/interfaces/IPoolAddressesProvider.sol";
import "./AbstractExchange.sol";
import "./interfaces/IExchangeRegistry.sol";
import "./interfaces/IExchange.sol";

/**
 * @notice Functional contract is FlashLoanReceiverBase
 * @dev Contract will NOT store funds or store any given state.
 */
contract ArbiTrader is IFlashLoanSimpleReceiver, AbstractExchange {
    IPoolAddressesProvider public aavePoolProvider;
    IPool public aavePool;

    address public owner;
    address public treassury;
    address public dexRegistry;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    constructor(
        address _aavePoolProvider,
        address _treassury,
        address _dexRegistry
    ) {
        owner = msg.sender;
        treassury = payable(_treassury);
        dexRegistry = _dexRegistry;
        aavePoolProvider = IPoolAddressesProvider(_aavePoolProvider);
        aavePool = IPool(aavePoolProvider.getPool());
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
    ) external onlyOwner returns (bool) {
        _initFlashLoan(_asset, _amount, _operations);
        return true;
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

    function executeOperation(
        address _asset,
        uint256 _amount,
        uint256 _premium,
        address _initiator,
        bytes calldata _operations
    ) external override returns (bool) {
        require(
            IERC20(_asset).balanceOf(address(this)) >= _amount,
            "AT1 Loan Transfer Fail"
        );
        // Avee Pool calling executeOperation function on out contract
            // _executeOperation();
        // Repay: Approve aave pool to take loan amount + fees
        SafeERC20.safeApprove(
            IERC20(_asset),
            address(aavePool),
            _amount + aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL()
        );
        return true;
    }

    /**
    * @notice IFlashLoanSimpleReceiver implementation
    * @dev Loan provider lending criteria
    * @param _operations Array of encoded operarions (swaps)
     */
    function _executeOperation(bytes[] memory _operations, uint160 _loopLimit) internal {
        // start multicall
        for (uint256 i = 0; i < _loopLimit + 1; i++) {
            (
                string memory _dexSymbol,
                uint256 _amountIn,
                uint256 _amountOut,
                address[] memory _poolsPath, // kyberOnly
                address[] memory _path,
                address _to,
                uint256 _swapTimeout
            ) = _decodeOperation(_operations[i]);

            address _dexAddress = IExchangeRegistry(dexRegistry).exchangeRegistryMap(_dexSymbol);
            IERC20(_path[0]).approve(address(_dexAddress),_amountIn);
            require(_dexAddress != address(0),"Dex not found");
            
            IExchange(_dexAddress).swapExactTokensForTokens(
                 _amountIn,
                 _amountOut,
                 _poolsPath, // kyberOnly address [] 
                 _path, // IERC20 []
                 address(this),
                 _swapTimeout,
                 _loopLimit
            );
        }
    }

    function _decodeOperation(bytes memory _operation)
        internal returns(
                string memory,
                 uint256,
                 uint256,
                 address[] memory,
                 address[] memory,
                 address,
                 uint256){
        return
            abi.decode(
                (_operation),
                (string,
                 uint256,
                 uint256,
                 address[],
                 address[],
                 address,
                 uint256)
            );
    }

    function deposit() external payable onlyOwner returns(uint256){
        require(msg.value > 0, "Gascosts are high come on!");
        return address(this).balance;
    }

    fallback() external payable {
        revert();
    }
    receive() external payable {
        revert();
    } 
}


