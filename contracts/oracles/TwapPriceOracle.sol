//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

import "../libraries/UniswapV2OracleLibrary.sol";
import "../libraries/UniswapV2Library.sol";

/**
 * @title UniswapV2 TWAP Oracle
 *  Features:
 *   # Update average prices for a pair.
 *   # Get the current average price for one of the pair tokens.
 * @author https://github.com/ge0rgiev
 **/
contract TwapPriceOracle {
    using FixedPoint for *;

    uint256 public constant PERIOD = 60 seconds;

    IUniswapV2Pair immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint32 public blockTimestampLast;

    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    /**
     * @notice Construct and initialize the Twap UniswapV2 Contract
     * Stored state:
     * # pair tokens
     * # cumulative prices
     * # last updated timestamp
     */
    constructor(
        address factory,
        address tokenA,
        address tokenB
    ) public {
        IUniswapV2Pair _pair = IUniswapV2Pair(
            UniswapV2Library.pairFor(factory, tokenA, tokenB)
        );
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();

        // Fetch the current accumulated price value (1 / 0)
        price0CumulativeLast = _pair.price0CumulativeLast();
        // Fetch the current accumulated price value (0 / 1)
        price1CumulativeLast = _pair.price1CumulativeLast();

        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = _pair.getReserves();
        // Ensure that there's liquidity in the pair
        require(
            reserve0 != 0 && reserve1 != 0,
            "TwapPriceOracle: NO_LIQUIDITY"
        );
    }

    /**
     * @notice Syncs the average prices if defined period elapsed.
     */
    function syncPrices() external {
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        // Overflow is desired
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        // Ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, "TwapPriceOracle: PERIOD_NOT_ELAPSED");

        // Overflow is desired, casting never truncates
        // Cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(
            uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
        );
        price1Average = FixedPoint.uq112x112(
            uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)
        );

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    /**
     * @notice Get the current average price for a token from the pair.
     * It will be 0 before the first successfull update call.
     *
     * @param token One of the pair tokens
     */
    function getPrice(address token) external view returns (uint256 price) {
        if (token == token0) {
            price = price0Average.mul(10**(ERC20(token).decimals())).decode144();
        } else {
            require(token == token1, "TwapPriceOracle: INVALID_TOKEN");
            price = price1Average.mul(10**(ERC20(token).decimals())).decode144();
        }
    }
}
