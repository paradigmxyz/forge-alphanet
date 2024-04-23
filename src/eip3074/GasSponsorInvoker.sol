// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import { BaseAuth } from "./BaseAuth.sol";

/// @title Gas Sponsor Invoker
/// @notice Invoker contract using EIP-3074 to sponsor gas for authorized transactions
contract GasSponsorInvoker is BaseAuth {
    event CallExecuted(address indexed target, uint256 value, bytes data);

    /// @notice Executes a call authorized by an external account (EOA)
    /// @param authority The address of the authorizing external account
    /// @param v The recovery byte of the signature
    /// @param r Half of the ECDSA signature pair
    /// @param s Half of the ECDSA signature pair
    /// @param to The target contract address to call
    /// @param data The data payload for the call
    /// @param value The ETH value to send with the call
    /// @param gasLimit The maximum amount of gas to use for the call
    /// @return success True if the call was successful
    function sponsorCall(
        address authority,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address to,
        bytes calldata data,
        uint256 value,
        uint256 gasLimit
    ) external returns (bool success) {
        bytes32 commit = keccak256(abi.encode(to, data));

        // Ensure the transaction is authorized by the signer
        require(authSimple(authority, commit, v, r, s), "Authorization failed");

        // Execute the call as authorized by the signer
        success = authCallSimple(to, data, value, gasLimit);
        require(success, "Call execution failed");

        emit CallExecuted(to, value, data);
    }
}
