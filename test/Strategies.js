const { ASSETS } = require("../migrations/address_lookup.js");

const LOAN_AMOUNT = ethers.utils.formatUnits(1000, "gwei");
const LOAN_ASSET = ASSETS.matic.AAVE;

module.exports.STRATEGIES = [
  {
    dex: "UNIV3",
    token0: ASSETS.matic.AAVE,
    token1: ASSETS.matic.WETH,
    poolFee: 3000, // 3% fee on AAVE/WETH pool
    amountIn: "TOTAL_LOAN_AMOUNT", // in case we want to fraction the borrowed amount
    amountOutMinimum: LOAN_AMOUNT - ethers.utils.formatUnits(02, "gwei"), // 2% slippage
  },
  {
    dex: "UNIV2",
    token0: ASSETS.matic.WETH,
    token1: ASSETS.matic.AAVE,
    poolFee: null, // univ2 no need for pool
    amountIn: "TOTAL_LOAN_AMOUNT", // in case we want to fraction the borrowed amount
    amountOutMinimum: LOAN_AMOUNT - ethers.utils.formatUnits(02, "gwei"), // 2% slippage
  },
];

module.exports.ENCODE_STRUCTS = {
  DataTypeTemplate: [
    "string dex",
    "address token0",
    "address token1",
    "uint256 poolFee",
    "uint256 amountIn",
    "uint256 amountOutMinimum",
  ],
  DataValues: (s) => [
    s.dex,
    s.token0,
    s.token1,
    s.poolFee,
    s.amountIn,
    s.amountOutMinimum,
  ],
};
