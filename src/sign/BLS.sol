// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title BLS
/// @notice Wrapper functions to abstract low level details of calls to BLS precompiles
///         defined in EIP-2537, see <https://eips.ethereum.org/EIPS/eip-2537>.
/// @dev Precompile addresses come from the BLS addresses submodule in AlphaNet, see
///      <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>
///      Being addresses we can't use them as constants in inline assembly
library BLS {
    /// @notice G1ADD operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1Add(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G1ADD address is 0x0b
        (success, output) = address(0x0b).staticcall(input);
    }

    /// @notice G1MUL operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1Mul(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G1MUL address is 0x0c
        (success, output) = address(0x0c).staticcall(input);
    }

    /// @notice G1MSM operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1MSM(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G1MSM address is 0x0d
        (success, output) = address(0x0d).staticcall(input);
    }

    /// @notice G2ADD operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2Add(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G2ADD address is 0x0e
        (success, output) = address(0x0e).staticcall(input);
    }

    /// @notice G2MUL operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2Mul(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G2MUL address is 0x0f
        (success, output) = address(0x0f).staticcall(input);
    }

    /// @notice G2MSM operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2MSM(bytes memory input) internal view returns (bool success, bytes memory output) {
        // G2MSM address is 0x10
        (success, output) = address(0x10).staticcall(input);
    }

    /// @notice PAIRING operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function Pairing(bytes memory input) internal view returns (bool success, bytes memory output) {
        // PAIRING address is 0x11
        (success, output) = address(0x11).staticcall(input);
    }

    /// @notice MAP_FP_TO_G1 operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function MapFpToG1(bytes memory input) internal view returns (bool success, bytes memory output) {
        // MAP_FP_TO_G1 address is 0x12
        (success, output) = address(0x12).staticcall(input);
    }

    /// @notice MAP_FP2_TO_G2 operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function MapFp2ToG2(bytes memory input) internal view returns (bool success, bytes memory output) {
        // MAP_FP2_TO_G2 address is 0x13
        (success, output) = address(0x13).staticcall(input);
    }
}
