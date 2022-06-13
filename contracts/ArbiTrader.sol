//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "../lib/forge-std/src/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/Address.sol";
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
contract ArbiTrader is IFlashLoanSimpleReceiver {
    IPoolAddressesProvider public aavePoolProvider;
    IPool public aavePool;

    address public owner;
    address public treassury;
    mapping(string => address) public _dexRouters;

    struct Trade {
        string  _dexSymbol;
        address _assetToApprove;
        uint256 _amountExpectedOut;
    }

    mapping(uint256 => Trade) public _trades;

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

    /// @dev Deposit funds to cover gas costs
    function deposit() external payable  returns (uint256) {
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
        aavePool.flashLoanSimple(
            address(this),
            _asset,
            _amount,
            _operations,
            0
         );
    }

    function addDexRouter(string memory _dexSymbol, address _dexRouter) external{
        _dexRouters[_dexSymbol] = _dexRouter;
    }

    function setTrades(uint256 _index, Trade memory _trade) external{
        _trades[_index] = _trade;
    }
    /**
     * @notice IFlashLoanSimpleReceiver implementation
     * @dev Function called by AAVE protocol
     * @param _asset loan asset address (token borrowed)
     * @param _amount loaned amount
     * @param _premium loan fee
     * @param _initiator caller address - this contract
     * @param _operations  strategy
     */
    function executeOperation(
        address _asset,
        uint256 _amount,
        uint256 _premium,
        address _initiator,
        bytes calldata _operations
    ) external override returns (bool) {
        require(IERC20(_asset).balanceOf(address(this)) >= _amount,"AT1 Loan Transfer Fail");
        
        console.log('executeOperation ::: ');
        bytes[] memory results = new bytes[](_operations.length);

        for (uint256 i = 0; i < _operations.length; i++) {
            
            // get router address by dexSymbol
            address _dexAddress = _dexRouters[_trades[i]._dexSymbol];

            // approve router to take _amountin of _tokenA
            IERC20(address(_trades[i]._assetToApprove)).approve(_dexAddress, uint256(_trades[i]._amountExpectedOut));

            // exec external call (swap)
            (bool success, bytes memory returndata) = _dexAddress.delegatecall(
                abi.encode(_operations[i])
                );
            require(success,"delegatecall failed");

            (string memory msg) = abi.decode(returndata, (string));
            console.log("msg: ",msg);

            // Address.functionDelegateCall(_dexAddress, _operations[i]);
            // require(abi.decode(results[i],(bool)),  "External call Failed");
        }

          
        // Repay: Approve aave pool to take loan amount + fees
        IERC20(_asset).approve(address(aavePool),_amount + aavePool.FLASHLOAN_PREMIUM_TO_PROTOCOL());
        return true;
    }

    function _withdrawProfit(address _asset) internal  {
        uint256 assetBalance = IERC20(_asset).balanceOf(address(this));
        require(assetBalance > 0, "No profit yet for this asset.");
        IERC20(_asset).approve(address(treassury), assetBalance);
        IERC20(_asset).transferFrom(
            address(this),
            address(treassury),
            assetBalance
        );
    }

    function _withdrawNativeProfit() internal  {
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
