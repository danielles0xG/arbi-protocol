import { Fetcher, Route, Token, WETH } from "@uniswap/sdk";

export default class UniswapV2Api {
  static priceTokenAtoETH(chainId, tokenA) {
    const TokenA = new Token(Number(chainId), tokenA, 18);

    return Fetcher.fetchPairData(TokenA, WETH[chainId]).then((pair) => {
      const route = new Route([pair], WETH[chainId]);
      return route.midPrice.toSignificant(6);
    });
  }

  static priceTokenAtoTokenB(chainId, tokenA, tokenB) {
    const TokenA = new Token(Number(chainId), tokenA, 18);
    const TokenB = new Token(Number(chainId), tokenB, 18);

    return Fetcher.fetchPairData(TokenA, TokenB).then((pair) => {
      const route = new Route([pair], TokenB);
      return route.midPrice.toSignificant(6);
    });
  }
}
