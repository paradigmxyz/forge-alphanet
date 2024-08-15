// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

//( @title Secp256r1
/// @notice Wrapper function to abstract low level details of call to the Secp256r1
///         signature verification precompile as defined in EIP-7212, see
///         <https://eips.ethereum.org/EIPS/eip-7212>.
library Secp256r1 {
    /// @notice P256VERIFY operation
    /// @param input Slice of bytes representing the input for the precompile operation
    /// @return success Represents if the operation was successful
    function verify(bytes memory input) internal view returns (bool) {
        // P256VERIFY address is 0x14 from <https://github.com/paradigmxyz/alphanet/blob/main/crates/precompile/src/addresses.rs>
        (bool success, bytes memory output) = address(0x14).staticcall(input);
        success = success && output.length == 32 && output[31] == 0x01;

        return success;
    }
}
