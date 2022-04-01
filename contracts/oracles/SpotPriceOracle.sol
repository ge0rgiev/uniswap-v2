//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "../libraries/UniswapV2Library.sol";

/**
 * @title UniswapV2 Spot Oracle
 *  Features:
 *   # Get spot price for any pair.
 *   # Calculate percentage from given price.
 *
 * @author https://github.com/ge0rgiev
 **/
contract SpotPriceOracle {
    IUniswapV2Router02 router;
    IUniswapV2Factory factory;

    constructor(IUniswapV2Router02 _router, IUniswapV2Factory _factory) {
        router = _router;
        factory = _factory;
    }

    /**
     * @notice Get the exchange rate for 1 `fromAsset` = ? `toAsset`
     * @param fromAsset the input asset
     * @param toAsset the output asset
     */
    function getPrice(address fromAsset, address toAsset)
        external
        view
        returns (uint256 quote)
    {
        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(
            address(factory),
            fromAsset,
            toAsset
        );

        quote = IUniswapV2Router02(router).quote(
            10**(ERC20(fromAsset).decimals()),
            reserveA,
            reserveB
        );
    }

    /**
     * @notice Calculate the `percentage` from `price`
     * @param price Example: 3415308340
     * @param percentage 100% = 1e18
     */
    function getPriceDiscrepancyRange(uint256 price, uint256 percentage)
        external
        pure
        returns (uint256 discrepancyRange)
    {
        require(percentage > 0, "SpotPriceOracle: INVALID_PERCENTAGE");
        discrepancyRange = (price * percentage) / 1e18;
    }
}
