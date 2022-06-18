// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../../interfaces/IWETH.sol";
import "./IDMMExchangeRouter.sol";
import "./IDMMLiquidityRouter.sol";

/// @dev full interface for router
interface IDMMRouter01 is IDMMExchangeRouter, IDMMLiquidityRouter {
    function factory() external pure returns (address);

    function weth() external pure returns (IWETH);
}
