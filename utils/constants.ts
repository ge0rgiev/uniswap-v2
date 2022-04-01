import { env } from "../env";

const uniswap = {
  v2: {
    factory: env.UNISWAP_V2_FACTORY,
    router: env.UNISWAP_V2_ROUTER_02,
  },
};

const ERC20 = {
  WETH: env.WETH,
  WBTC: env.WBTC,
  USDC: env.USDC,
  USDT: env.USDT,
  DAI: env.DAI,
};

export { ERC20, uniswap };
