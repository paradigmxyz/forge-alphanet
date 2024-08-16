// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Secp256r1} from "./sign/Secp256r1.sol";

contract P256Delegation {
    uint256 authorizedPublicKeyX;
    uint256 authorizedPublicKeyY;

    uint256 public nonce;

    function authorize(uint256 publicKeyX, uint256 publicKeyY) public {
        require(msg.sender == address(this));

        authorizedPublicKeyX = publicKeyX;
        authorizedPublicKeyY = publicKeyY;
    }

    function transact(address to, bytes memory data, uint256 value, bytes32 r, bytes32 s) public {
        bytes32 digest = keccak256(abi.encode(nonce++, to, data, value));
        require(Secp256r1.verify(digest, r, s, authorizedPublicKeyX, authorizedPublicKeyY), "Invalid signature");

        (bool success,) = to.call(data);
        require(success);
    }
}
