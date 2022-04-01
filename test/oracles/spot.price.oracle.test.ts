/* eslint-disable no-unused-expressions */

import chai from "chai";
import { run } from "hardhat";
import { SpotPriceOracle } from "../../typechain";
import { deploy, data, calculatePercentage } from "./spot.price.oracle.env";

const { expect } = chai;

describe("UniswapV2 Spot Price Oracle", async () => {
  let spotPriceOracle: SpotPriceOracle;
  const {
    ERC20: { WETH, USDC, DAI, USDT, WBTC },
  } = data;

  const priceDiscrepancyThreshold = calculatePercentage(1); // 1%

  before(async () => {
    await run("compile");
    ({ spotPriceOracle } = await deploy());
  });

  describe("Get Uniswap V2 WETH prices", async () => {
    it("Should get the prices for WETH / USDC | DAI | USDT | WBTC", async () => {
      await spotPriceOracle.getPrice(WETH, USDC).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WETH/USDC -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WETH, DAI).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WETH/DAI -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WETH, USDT).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WETH/USDT -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WETH, WBTC).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WETH/WBTC -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });
    });
  });

  describe("Get Uniswap V2 WBTC prices", async () => {
    it("Should get the prices for WBTC / USDC | DAI | USDT | WETH", async () => {
      await spotPriceOracle.getPrice(WBTC, USDC).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WBTC/USDC -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WBTC, DAI).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WBTC/DAI -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WBTC, USDT).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WBTC/USDT -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });

      await spotPriceOracle.getPrice(WBTC, WETH).then(async (quote) => {
        const priceDiscrepancy = await spotPriceOracle.getPriceDiscrepancyRange(
          quote,
          priceDiscrepancyThreshold
        );
        console.log(`WBTC/WETH -> ${quote} | 1% -> ${priceDiscrepancy}`);
        console.log("--- --- --- --- --- --- --- --- ---");
      });
    });
  });
});
