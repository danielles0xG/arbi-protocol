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

/**
 * @notice Functional contract is FlashLoanReceiverBase
 * @dev Contract will NOT store funds or store any given state.
 */
contract ArbiTrader is IFlashLoanSimpleReceiver, ReentrancyGuard, AbstractExchange{

    IPoolAddressesProvider public _aavePoolProvider;
    IPool public _aavePool;

    address public _owner;
    address public _treassury;
    uint24  public _strategyLength;
    address public test;

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
    function performStrategy(Strategy memory _strategy,uint8 strategyLength_) external onlyOwner {
        (bytes memory _data) = abi.encode(_strategy);
        _strategyLength = strategyLength_;
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
        require(IERC20(_asset).balanceOf(address(this)) >= _amount,"AT1 Loan Transfer Fail");
        
        Strategy memory _strategy = abi.decode(_data,(Strategy));

        for(uint8 i = 0; i < _strategyLength; i++){
            Operation memory _operation = _decodeOperation(_strategy._ops[i]);
            test = _operation._paths[0];
        }

        IERC20(_asset).approve(
            address(_aavePool),
            _amount + _aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL()
        );
        return true;
    }

    function _decodeOperation(bytes memory operation) internal returns(Operation memory _operation){
       (_operation._dexAddress,
        _operation._amountIn,
        _operation._amountOut,
        _operation._paths,
        _operation._poolFees) = abi.decode(operation,(address, uint256, uint256, address[], uint24[]));
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
