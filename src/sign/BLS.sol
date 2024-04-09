// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title BLS
/// @notice Wrapper functions to abstract low level details of calls to BLS precompiles
///         defined in EIP-2537, see <https://eips.ethereum.org/EIPS/eip-2537>.
/// @dev Precompile addresses come from the BLS addresses submodule in AlphaNet, see
///      <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>
///      Being addresses we can't use them as constants in inline assembly
library BLS {
    /// @notice Output sizes come from the ABI definition for each of the BLS operations
    ///         in EIP-2537, see: <https://eips.ethereum.org/EIPS/eip-2537#abi-for-operations>
    /// @notice G1ADD output size allocation
    uint256 constant G1ADD_OUTPUT_SIZE = 128;
    /// @notice G1MUL output size allocation
    uint256 constant G1MUL_OUTPUT_SIZE = 128;
    /// @notice G1MSM output size allocation
    uint256 constant G1MSM_OUTPUT_SIZE = 128;
    /// @notice G2ADD output size allocation
    uint256 constant G2ADD_OUTPUT_SIZE = 256;
    /// @notice G2MUL output size allocation
    uint256 constant G2MUL_OUTPUT_SIZE = 256;
    /// @notice G2MSM output size allocation
    uint256 constant G2MSM_OUTPUT_SIZE = 256;
    /// @notice PAIRING output size allocation
    uint256 constant PAIRING_OUTPUT_SIZE = 32;
    /// @notice MAP_FP_TO_G1 output size allocation
    uint256 constant MAP_FP_TO_G1_OUTPUT_SIZE = 128;
    /// @notice MAP_FP2_TO_G2 output size allocation
    uint256 constant MAP_FP2_TO_G2_OUTPUT_SIZE = 256;

    //// @notice G1ADD operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1Add(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G1ADD_OUTPUT_SIZE);
        assembly {
            // G1ADD address is 0x0b
            success := staticcall(gas(), 0x0b, add(input, 0x20), mload(input), output, G1ADD_OUTPUT_SIZE)
        }
    }

    /// @notice G1MUL operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1Mul(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G1MUL_OUTPUT_SIZE);
        assembly {
            // G1MUL address is 0x0c
            success := staticcall(gas(), 0x0c, add(input, 0x20), mload(input), output, G1MUL_OUTPUT_SIZE)
        }
    }

    /// @notice G1MSM operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G1MSM(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G1MSM_OUTPUT_SIZE);
        assembly {
            // G1MSM address is 0x0d
            success := staticcall(gas(), 0x0d, add(input, 0x20), mload(input), output, G1MSM_OUTPUT_SIZE)
        }
    }

    /// @notice G2ADD operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2Add(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G2ADD_OUTPUT_SIZE);
        assembly {
            // G2ADD address is 0x0e
            success := staticcall(gas(), 0x0e, add(input, 0x20), mload(input), output, G2ADD_OUTPUT_SIZE)
        }
    }

    /// @notice G2MUL operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2Mul(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G2MUL_OUTPUT_SIZE);
        assembly {
            // G2MUL address is 0x0f
            success := staticcall(gas(), 0x0f, add(input, 0x20), mload(input), output, G2MUL_OUTPUT_SIZE)
        }
    }

    /// @notice G2MSM operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function G2MSM(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(G2MSM_OUTPUT_SIZE);
        assembly {
            // G2MSM address is 0x10
            success := staticcall(gas(), 0x10, add(input, 0x20), mload(input), output, G2MSM_OUTPUT_SIZE)
        }
    }

    /// @notice PAIRING operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function Pairing(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(PAIRING_OUTPUT_SIZE);
        assembly {
            // PAIRING address is 0x11
            success := staticcall(gas(), 0x11, add(input, 0x20), mload(input), output, PAIRING_OUTPUT_SIZE)
        }
    }

    /// @notice MAP_FP_TO_G1 operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function MapFpToG1(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(MAP_FP_TO_G1_OUTPUT_SIZE);
        assembly {
            // MAP_FP_TO_G1 address is 0x12
            success := staticcall(gas(), 0x12, add(input, 0x20), mload(input), output, MAP_FP_TO_G1_OUTPUT_SIZE)
        }
    }

    /// @notice MAP_FP2_TO_G2 operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    /// @return output Result bytes of the operation
    function MapFp2ToG2(bytes memory input) internal view returns (bool success, bytes memory output) {
        output = new bytes(MAP_FP2_TO_G2_OUTPUT_SIZE);
        assembly {
            // MAP_FP2_TO_G2 address is 0x13
            success := staticcall(gas(), 0x13, add(input, 0x20), mload(input), output, MAP_FP2_TO_G2_OUTPUT_SIZE)
        }
    }
}
