// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import { BaseAuth } from "./BaseAuth.sol";

/// @title Invoker
/// @notice Basic contract that allows to send transactions in the context of an
///         Externally Owned Account using EIP-3074 AUTH and AUTHCALL instructions.
contract Invoker is BaseAuth {
    struct Signature {
        uint256 r;
        uint256 s;
        bool v;
    }

    struct Payload {
        address to;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }

    /// @notice Thrown when the `AUTH` opcode fails due to invalid signature.
    /// @dev Selector 0xd386ef3e.
    error BadAuth();

    /// @notice call AUTH opcode with a given a commitment + signature
    /// @param authority - signer to AUTH
    /// @param v - signature input
    /// @param r - signature input
    /// @param s - signature input
    /// @param commit - any 32-byte value used to commit to transaction validity conditions
    /// @dev payload - transaction data to send on behalf of authority
    /// @custom:reverts BadAuth() if  AUTH fails due to invalid signature
    function invoke(address authority, uint8 v, bytes32 r, bytes32 s, bytes32 commit, Payload calldata payload) external payable {
        bool success = authSimple(authority, commit, v, r, s);
        if (!success) revert BadAuth();

        uint256 startBalance = address(this).balance - msg.value;

        success = call(payload);
        require(success, "Transaction failed");

        // To ensure that the caller does not send more funds than used in the transaction payload, we check if the contract
        // balance is less or equal to the starting balance here.
        require(address(this).balance <= startBalance, "Invalid balance");
    }

    // @notice Send an authenticated call to the address provided in the payload.
    // @dev Currently this function does not return the call data.
    // @param payload - The payload to send.
    // @return success - Whether the call succeeded.
    function call(Payload calldata payload) private returns (bool success) {
        uint256 gasLimit = payload.gasLimit;
        address to = payload.to;
        uint256 value = payload.value;
        bytes memory data = payload.data;

        success = authCallSimple(to, data, value, gasLimit);
    }
}
