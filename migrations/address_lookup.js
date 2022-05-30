module.exports.GRAVITYFINANCE = {
  router: {
    matic:"0x57dE98135e8287F163c59cA4fF45f1341b680248",
  },
};
module.exports.DFYN = {
  router: {
    matic:"0xA102072A4C07F06EC3B4900FDC4C7B80b6c57429",
    okc:"0x34686CBF7229ed0bff2Fbe7ED2CFC916317764f6",
    fantom:"0x2724B9497b2cF3325C6BE3ea430b3cec34B5Ef2d",
    arbitrum:"0xaedE1EFe768bD8A1663A7608c63290C60B85e71c"
  },
};
module.exports.QUICKSWAP = {
  router: {
    matic:"0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff",
  },
};
module.exports.BALANCERV2 = {
  vault: {
    matic:"0xBA12222222228d8Ba445958a75a0704d566BF2C8",
    ethereum:"0xBA12222222228d8Ba445958a75a0704d566BF2C8",
    optimism:"0xBA12222222228d8Ba445958a75a0704d566BF2C8",
    arbitrum:"0xBA12222222228d8Ba445958a75a0704d566BF2C8"
  },
};
module.exports.AAVE = {
  poolAddressesProvider: {
    matic: "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
    avax:"0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
    optimism:"0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
    fantom:"0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
    arbitrum:"0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb"
  },
};
module.exports.SUSHI = {
  router: {
    matic: "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
    avax:"0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
    fantom:"0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
    bsc:"0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
    arbitrum:"0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506"
  },
};

module.exports.KYBER = {
  router: {
    matic: "0x546C79662E028B661dFB4767664d0273184E4dD1",
    avax:"0x8Efa5A9AD6D594Cf76830267077B78cE0Bc5A5F8", // no loans on avax
    fantom:"0x5d5A5a0a465129848c2549669e12cDC2f8DE039A",
    bsc:"0x78df70615ffc8066cc0887917f2Cd72092C86409",
    arbitrum:"0xEaE47c5D99f7B31165a7f0c5f7E0D6afA25CFd55"
  },
};
module.exports.UNISWAP_V2 = {
  router: {
    ethereum: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    optimism:"0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    arbitrum:"0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
    matic: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
    avax:"",
  },
  factory: {
    ethereum:"0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
  }

};

module.exports.UNISWAP_V3 = {
  quoter: "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6",
  swapRouter: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
};
module.exports.DYDX = {
  router: {
    matic: "",
    avax:""
  },
};
module.exports.TREASURY = {
  DEV: "0x8B13f183e27AaD866b0d71F0CD17ca83A9a54ae2",
  PROD: "",
};
module.exports.ASSETS = {
  matic: {
    AAVE: "0xD6DF932A45C0f255f85145f286eA0b292B21C90B", //18 decimals
    DAI: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063", //18 decimals
    USDC: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", // 6 decimals
    USDT: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", // 6 decimals
    WBTC: "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6", // 8 decimals
    WETH: "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", // 18 decimals
    WMATIC: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", // 18 decimals
  },
};


