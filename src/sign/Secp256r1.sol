// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

//( @title Secp256r1
/// @notice Wrapper function to abstract low level details of call to the Secp256r1
///         signature verification precompile as defined in EIP-7212, see
///         <https://eips.ethereum.org/EIPS/eip-7212>.
library Secp256r1 {
    /// @notice P256VERIFY output size allocation
    uint256 constant P256VERIFY_OUTPUT_SIZE = 32;

    /// @notice P256VERIFY operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    function verify(bytes memory input) internal view returns (bool success) {
        bytes memory output = new bytes(P256VERIFY_OUTPUT_SIZE);
        assembly {
            // P256VERIFY address is 0x13 from <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>
            let callSuccess := staticcall(gas(), 0x13, add(input, 0x20), mload(input), output, P256VERIFY_OUTPUT_SIZE)
            // Directly load the output into the success variable.
            // Assuming the precompile writes 0 or 1 to the first byte of output
            // to indicate failure/success.
            success := mload(add(output, 0x20))

            // Check if the call to the precompile itself was successful
            // This is to differentiate between a precompile execution failure
            // and a verification failure.
            if iszero(callSuccess) {
                success := 0
            }
        }
    }
}
