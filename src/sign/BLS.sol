// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Wrapper functions to abstract low level details of calls to BLS precompiles
// defined in EIP-2537, see <https://eips.ethereum.org/EIPS/eip-2537>.
library BLS {
    // Precompile addresses come from the BLS addresses submodule in AlphaNet, see:
    // <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>

    // Output sizes come from the ABI definition for each of the BLS operations
    // in EIP-2537, see: <https://eips.ethereum.org/EIPS/eip-2537#abi-for-operations>
    // G1ADD output size allocation
    uint256 constant G1ADD_OUTPUT_SIZE = 128;
    // G1MUL output size allocation
    uint256 constant G1MUL_OUTPUT_SIZE = 128;
    // G1MULTIEXP output size allocation
    uint256 constant G1MULTIEXP_OUTPUT_SIZE = 128;
    // G2ADD output size allocation
    uint256 constant G2ADD_OUTPUT_SIZE = 256;
    // G2MUL output size allocation
    uint256 constant G2MUL_OUTPUT_SIZE = 256;
    // G2MULTIEXP output size allocation
    uint256 constant G2MULTIEXP_OUTPUT_SIZE = 256;
    // PAIRING output size allocation
    uint256 constant PAIRING_OUTPUT_SIZE = 32;
    // MAP_FP_TO_G1 output size allocation
    uint256 constant MAP_FP_TO_G1_OUTPUT_SIZE = 128;
    // MAP_FP2_TO_G2 output size allocation
    uint256 constant MAP_FP2_TO_G2_OUTPUT_SIZE = 256;

    // Function to perform G1ADD operation
    function G1Add(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G1ADD_OUTPUT_SIZE);
        bool success;
        assembly {
            // G1ADD address is 0x0b
            success := staticcall(gas(), 0x0b, add(input, 0x20), mload(input), output, G1ADD_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform G1MUL operation
    function G1Mul(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G1MUL_OUTPUT_SIZE);
        bool success;
        assembly {
            // G1MUL address is 0x0c
            success := staticcall(gas(), 0x0c, add(input, 0x20), mload(input), output, G1MUL_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform G1MULTIEXP operation
    function G1MultiExp(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G1MULTIEXP_OUTPUT_SIZE);
        bool success;
        assembly {
            // G1MULTIEXP address is 0x0d
            success := staticcall(gas(), 0x0d, add(input, 0x20), mload(input), output, G1MULTIEXP_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform G2ADD operation
    function G2Add(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G2ADD_OUTPUT_SIZE);
        bool success;
        assembly {
            // G2ADD address is 0x0e
            success := staticcall(gas(), 0x0e, add(input, 0x20), mload(input), output, G2ADD_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform G2MUL operation
    function G2Mul(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G2MUL_OUTPUT_SIZE);
        bool success;
        assembly {
            // G2MUL address is 0x0f
            success := staticcall(gas(), 0x0f, add(input, 0x20), mload(input), output, G2MUL_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform G2MULTIEXP operation
    function G2MultiExp(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(G2MULTIEXP_OUTPUT_SIZE);
        bool success;
        assembly {
            // G2MULTIEXP address is 0x10
            success := staticcall(gas(), 0x10, add(input, 0x20), mload(input), output, G2MULTIEXP_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform PAIRING operation
    function Pairing(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(PAIRING_OUTPUT_SIZE);
        bool success;
        assembly {
            // PAIRING address is 0x11
            success := staticcall(gas(), 0x11, add(input, 0x20), mload(input), output, PAIRING_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform MAP_FP_TO_G1 operation
    function MapFpToG1(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(MAP_FP_TO_G1_OUTPUT_SIZE);
        bool success;
        assembly {
            // MAP_FP_TO_G1 address is 0x12
            success := staticcall(gas(), 0x12, add(input, 0x20), mload(input), output, MAP_FP_TO_G1_OUTPUT_SIZE)
        }
        return (success, output);
    }

    // Function to perform MAP_FP2_TO_G2 operation
    function MapFp2ToG2(bytes memory input) internal view returns (bool, bytes memory) {
        bytes memory output = new bytes(MAP_FP2_TO_G2_OUTPUT_SIZE);
        bool success;
        assembly {
            // MAP_FP2_TO_G2 address is 0x13
            success := staticcall(gas(), 0x13, add(input, 0x20), mload(input), output, MAP_FP2_TO_G2_OUTPUT_SIZE)
        }
        return (success, output);
    }
}
