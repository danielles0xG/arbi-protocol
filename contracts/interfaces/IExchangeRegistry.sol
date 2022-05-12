// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

interface IExchangeRegistry {
    function exchangeRegistryMap(string memory _dexSymbol)
        external
        returns (address dexAddress);
}
