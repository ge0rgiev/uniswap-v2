import { Record, String } from "runtypes";

export const EnvVarsRecord = Record({
  // Uniswap V2
  UNISWAP_V2_FACTORY: String,
  UNISWAP_V2_ROUTER_02: String,

  // ERC20
  WETH: String,
  WBTC: String,
  USDC: String,
  DAI: String,
  USDT: String,
});

const env = EnvVarsRecord.check(process.env);

export { env };
