// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title BLS
/// @notice Wrapper functions to abstract low level details of calls to BLS precompiles
///         defined in EIP-2537, see <https://eips.ethereum.org/EIPS/eip-2537>.
/// @dev Precompile addresses come from the BLS addresses submodule in AlphaNet, see
///      <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>
library BLS {
    /// @dev A base field element (Fp) is encoded as 64 bytes by performing the
    /// BigEndian encoding of the corresponding (unsigned) integer. Due to the size of p,
    /// the top 16 bytes are always zeroes.
    struct Fp {
        uint256 a;
        uint256 b;
    }

    /// @dev For elements of the quadratic extension field (Fp2), encoding is byte concatenation of
    /// individual encoding of the coefficients totaling in 128 bytes for a total encoding.
    /// c0 + c1 * v
    struct Fp2 {
        Fp c0;
        Fp c1;
    }

    /// @dev Points of G1 and G2 are encoded as byte concatenation of the respective
    /// encodings of the x and y coordinates.
    struct G1Point {
        Fp x;
        Fp y;
    }

    /// @dev Points of G1 and G2 are encoded as byte concatenation of the respective
    /// encodings of the x and y coordinates.
    struct G2Point {
        Fp2 x;
        Fp2 y;
    }

    /// @notice G1ADD operation
    /// @param a First G1 point
    /// @param b Second G1 point
    /// @return result Resulted G1 point
    function G1Add(G1Point memory a, G1Point memory b) internal view returns (G1Point memory result) {
        // G1ADD address is 0x0b
        (bool success, bytes memory output) = address(0x0b).staticcall(abi.encode(a, b));
        require(success, "G1ADD failed");
        return abi.decode(output, (G1Point));
    }

    /// @notice G1MUL operation
    /// @param point G1 point
    /// @param scalar Scalar to multiply the point by
    /// @return result Resulted G1 point
    function G1Mul(G1Point memory point, uint256 scalar) internal view returns (G1Point memory result) {
        // G1MUL address is 0x0c
        (bool success, bytes memory output) = address(0x0c).staticcall(abi.encode(point, scalar));
        require(success, "G1MUL failed");
        return abi.decode(output, (G1Point));
    }

    /// @notice G1MSM operation
    /// @param points Array of G1 points
    /// @param scalars Array of scalars to multiply the points by
    /// @return result Resulted G1 point
    function G1MSM(G1Point[] memory points, uint256[] memory scalars) internal view returns (G1Point memory result) {
        bytes memory input;

        for (uint256 i = 0; i < points.length; i++) {
            input = bytes.concat(input, abi.encode(points[i], scalars[i]));
        }

        // G1MSM address is 0x0d
        (bool success, bytes memory output) = address(0x0d).staticcall(input);
        require(success, "G1MSM failed");
        return abi.decode(output, (G1Point));
    }

    /// @notice G2ADD operation
    /// @param a First G2 point
    /// @param b Second G2 point
    /// @return result Resulted G2 point
    function G2Add(G2Point memory a, G2Point memory b) internal view returns (G2Point memory result) {
        // G2ADD address is 0x0e
        (bool success, bytes memory output) = address(0x0e).staticcall(abi.encode(a, b));
        require(success, "G2ADD failed");
        return abi.decode(output, (G2Point));
    }

    /// @notice G2MUL operation
    /// @param point G2 point
    /// @param scalar Scalar to multiply the point by
    /// @return result Resulted G2 point
    function G2Mul(G2Point memory point, uint256 scalar) internal view returns (G2Point memory result) {
        // G2MUL address is 0x0f
        (bool success, bytes memory output) = address(0x0f).staticcall(abi.encode(point, scalar));
        require(success, "G2MUL failed");
        return abi.decode(output, (G2Point));
    }

    /// @notice G2MSM operation
    /// @param points Array of G2 points
    /// @param scalars Array of scalars to multiply the points by
    /// @return result Resulted G2 point
    function G2MSM(G2Point[] memory points, uint256[] memory scalars) internal view returns (G2Point memory result) {
        bytes memory input;

        for (uint256 i = 0; i < points.length; i++) {
            input = bytes.concat(input, abi.encode(points[i], scalars[i]));
        }

        // G2MSM address is 0x10
        (bool success, bytes memory output) = address(0x10).staticcall(input);
        require(success, "G2MSM failed");
        return abi.decode(output, (G2Point));
    }

    /// @notice PAIRING operation
    /// @param g1Points Array of G1 points
    /// @param g2Points Array of G2 points
    /// @return result Returns whether pairing result is equal to the multiplicative identity (1).
    function Pairing(G1Point[] memory g1Points, G2Point[] memory g2Points) internal view returns (bool result) {
        bytes memory input;
        for (uint256 i = 0; i < g1Points.length; i++) {
            input = bytes.concat(input, abi.encode(g1Points[i], g2Points[i]));
        }

        // PAIRING address is 0x11
        (bool success, bytes memory output) = address(0x11).staticcall(input);
        require(success, "Pairing failed");
        return abi.decode(output, (bool));
    }

    /// @notice MAP_FP_TO_G1 operation
    /// @param element Fp element
    /// @return result Resulted G1 point
    function MapFpToG1(Fp memory element) internal view returns (G1Point memory result) {
        // MAP_FP_TO_G1 address is 0x12
        (bool success, bytes memory output) = address(0x12).staticcall(abi.encode(element));
        require(success, "MAP_FP_TO_G1 failed");
        return abi.decode(output, (G1Point));
    }

    /// @notice MAP_FP2_TO_G2 operation
    /// @param element Fp2 element
    /// @return result Resulted G2 point
    function MapFp2ToG2(Fp2 memory element) internal view returns (G2Point memory result) {
        // MAP_FP2_TO_G2 address is 0x13
        (bool success, bytes memory output) = address(0x13).staticcall(abi.encode(element));
        require(success, "MAP_FP2_TO_G2 failed");
        return abi.decode(output, (G2Point));
    }
}
