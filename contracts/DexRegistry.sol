// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.4;

contract DexRegistry {
    address public admin;
    mapping(string => address) public exchangeRegistryMap;
    event AddDexEvent(string _symbol, address _dexAddress);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addExchange(string memory _symbol, address _dexAddress)
        public
        onlyAdmin
    {
        require(_dexAddress != address(0), "EXR1: Invalid DEX Address");
        require(
            exchangeRegistryMap[_symbol] == address(0),
            "EXR2: DEX Already Exists"
        );
        exchangeRegistryMap[_symbol] = _dexAddress;
        emit AddDexEvent(_symbol, _dexAddress);
    }
}
