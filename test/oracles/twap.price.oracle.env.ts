import { ethers } from "hardhat";
import { ERC20, uniswap } from "../../utils/constants";

const data = { ERC20, uniswap };

const prepareDeploy = (data: any) => async () => {
  const { factory } = data.uniswap.v2;
  const { WETH, USDC } = data.ERC20;

  const twapPriceOracle = await (
    await ethers.getContractFactory("TwapPriceOracle")
  ).deploy(factory, WETH, USDC);

  return { twapPriceOracle };
};

const sleep = (seconds: number) => {
  console.log(`Wait for ${seconds} seconds..`);
  return new Promise((resolve) => {
    setTimeout(resolve, seconds * 1000);
  });
};

const deploy = prepareDeploy(data);

export { deploy, data, sleep };
