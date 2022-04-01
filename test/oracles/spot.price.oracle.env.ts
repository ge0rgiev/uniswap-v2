import { BigNumber } from "ethers";
import { ethers } from "hardhat";

import { ERC20, uniswap } from "../../utils/constants";

const data = { ERC20, uniswap };

/**
 * 100% = 1e18    -> 1000000000000000000
 * 20% = 2e17     -> 200000000000000000
 * 2% = 2e16      -> 20000000000000000
 * 0.2% = 2e15    -> 2000000000000000
 * 0.022% = 22e13 -> 220000000000000
 * etc.
 */
const calculatePercentage = (percentage: number): BigNumber =>
  ethers.constants.WeiPerEther.div(100).mul(percentage);

const prepareDeploy = (data: any) => async () => {
  const { router, factory } = data.uniswap.v2;

  const spotPriceOracle = await (
    await ethers.getContractFactory("SpotPriceOracle")
  ).deploy(router, factory);

  return { spotPriceOracle };
};

const deploy = prepareDeploy(data);

export { deploy, data, calculatePercentage };
