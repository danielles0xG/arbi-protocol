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

/**
 * @notice Functional contract is FlashLoanReceiverBase
 * @dev Contract will NOT store funds or store any given state.
 */
contract ArbiTrader is IFlashLoanSimpleReceiver, ReentrancyGuard {
    IPoolAddressesProvider public aavePoolProvider;
    IPool public aavePool;

    address public owner;
    address public treassury;
    address public dexRegistry;
    uint160 public _loopLimit;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    constructor(
        address _aavePoolProvider,
        address _treassury,
        address _dexRegistry,
        uint160 loopLimit_
    ) {
        owner = msg.sender;
        treassury = payable(_treassury);
        dexRegistry = _dexRegistry;
        aavePoolProvider = IPoolAddressesProvider(_aavePoolProvider);
        aavePool = IPool(aavePoolProvider.getPool());
        _loopLimit = loopLimit_;
    }

    /// @dev Deposit funds to cover gas costs
    function deposit() external payable onlyOwner returns (uint256) {
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
    ) external onlyOwner {
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
        _executeOperation(_operations);
        // Repay: Approve aave pool to take loan amount + fees

        IERC20(_asset).approve(
            address(aavePool),
            _amount + aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL()
        );
        return true;
    }

    struct Operations {
            address _dexAddress;
            uint256 _amountIn;
            uint256 _amountOut;
            address[] _path;
            uint24[] _poolFees;
    }

    /**
     * @notice IFlashLoanSimpleReceiver implementation
     * @dev Loan provider lending criteria
     * @param _operations Array of encoded operarions (swaps)
     */
    function _executeOperation(bytes calldata _operations) internal {
        (Operations[] memory _ops) = abi.decode(_operations,(Operations[]));
        for (uint256 i = 0; i < _ops.length; i++) {
            address dex = _ops[i]._dexAddress;
        }
    }


    function _withdrawProfit(address _asset) internal onlyOwner {
        uint256 assetBalance = IERC20(_asset).balanceOf(address(this));
        require(assetBalance > 0, "No profit yet for this asset.");
        IERC20(_asset).approve(address(treassury), assetBalance);
        IERC20(_asset).transferFrom(
            address(this),
            address(treassury),
            assetBalance
        );
    }
    

    function _withdrawNativeProfit() internal onlyOwner nonReentrant {
        uint256 _nativeTokenBalance = address(this).balance;
        require(
            _nativeTokenBalance > 0,
            "No profit yet for this native currency."
        );
        (bool _success, ) = treassury.call{value: _nativeTokenBalance}(" ");
        require(_success);
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }
}
