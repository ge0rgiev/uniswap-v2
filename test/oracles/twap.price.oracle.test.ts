/* eslint-disable no-unused-expressions */

import chai from "chai";
import { run } from "hardhat";
import { TwapPriceOracle } from "../../typechain";
import { deploy, data, sleep } from "./twap.price.oracle.env";

const { expect } = chai;

describe("UniswapV2 TWAP Price Oracle", function () {
  this.timeout(60 * 60 * 1000);

  let twapPriceOracle: TwapPriceOracle;
  const {
    ERC20: { WETH },
  } = data;

  before(async () => {
    await run("compile");
    ({ twapPriceOracle } = await deploy());
  });

  describe("Get Uniswap V2 TWAP WETH prices", function () {
    it("Should get the prices for WETH/USDC", async () => {
      // #1
      await twapPriceOracle
        .blockTimestampLast()
        .then(async (blockTimestampLast) => {
          const price = await twapPriceOracle.getPrice(WETH);
          console.log(`${blockTimestampLast} -> ${price}`);
        });

      await sleep(60);

      // #2
      await twapPriceOracle.syncPrices();
      await twapPriceOracle
        .blockTimestampLast()
        .then(async (blockTimestampLast) => {
          const price = await twapPriceOracle.getPrice(WETH);
          console.log(`${blockTimestampLast} -> ${price}`);
        });

      await sleep(60);

      // #3
      await twapPriceOracle.syncPrices();
      await twapPriceOracle
        .blockTimestampLast()
        .then(async (blockTimestampLast) => {
          const price = await twapPriceOracle.getPrice(WETH);
          console.log(`${blockTimestampLast} -> ${price}`);
        });

      await sleep(60);
    });
  });
});
