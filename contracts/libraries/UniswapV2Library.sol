// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "./SafeMath.sol";

/**
 * @title UniswapV2 Library
 * @dev Manages all Price Sources
 * - Features:
 *   # Sorts token addresses.
 *   # Calculates the address for a pair without making any external calls via the v2 SDK.
 *   # Given some asset amount and reserves, returns an amount of the other asset representing equivalent value.
 *   # TODO ...  
 * @author Uniswap Labs
 **/
library UniswapV2Library {
    using SafeMath for uint256;

    /**
     * @notice Sorts token addresses.
     * @param tokenA First token pair address
     * @param tokenB Second token pair address
     */
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    /**
     * @notice Calculates the address for a pair without making any external calls via the v2 SDK.
     * @param factory UniswapV2 Factory address
     * @param tokenA First token pair address
     * @param tokenB Second token pair address
     */
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    /**
     * @notice Calls getReserves on the pair for the passed tokens,
     * and returns the results sorted in the order that the parameters were passed in.
     *
     * @param factory UniswapV2 Factory address
     * @param tokenA First token pair address
     * @param tokenB Second token pair address
     */
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    /**
     * @notice Given some asset amount and reserves,
     * returns an amount of the other asset representing equivalent value.
     *
     * @param amountA First token amount
     * @param reserveA First token reserve
     * @param reserveB Second token reserve
     */
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    /**
     * @notice Given an input asset amount,
     * returns the maximum output amount of the other asset
     * (accounting for fees) given reserves.
     *
     * @param amountIn Input asset amount
     * @param reserveIn Input asset reserve
     * @param reserveOut Output asset reserve
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    /**
     * @notice Returns the minimum input asset amount,
     * required to buy the given output asset amount
     * (accounting for fees) given reserves.
     *
     * @param amountOut TODO
     * @param reserveIn TODO
     * @param reserveOut TODO
     */
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    /**
     * @notice Given an input asset amount and an array of token addresses,
     * calculates all subsequent maximum output token amounts by calling getReserves
     * for each pair of token addresses in the path in turn, and using these to call getAmountOut.
     *
     * @param factory UniswapV2 Factory address
     * @param amountIn TODO
     * @param path TODO
     */
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    /**
     * @notice Given an output asset amount and an array of token addresses,
     * calculates all preceding minimum input token amounts by calling getReserves for each pair of token addresses
     * in the path in turn, and using these to call getAmountIn.
     *
     * @param factory UniswapV2 Factory address
     * @param amountOut TODO
     * @param path TODO
     */
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
