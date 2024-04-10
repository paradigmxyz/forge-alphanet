# forge-alphanet

Set of solidity utilities to ease deployment and usage of applications on
[AlphaNet].

## BLS library

Functions to allow calling each of the BLS precompiles defined in [EIP-2537]
without the low level details.

For example, this is how the library can be used from a solidity smart contract:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BLS} from "/path/to/forge-alphanet/src/sign/BLS.sol";

contract BLSExample {
    event OperationResult(bool success, bytes result);

    // Function to perform a BLS12-381 G1 addition with error handling
    function performG1Add(bytes memory input) public {
        (bool success, bytes memory output) = BLS.G1Add(input);

        if (!success) {
            emit OperationResult(false, "");
        } else {
            emit OperationResult(true, output);
        }
    }
}
```
## Secp256r1 library

Provides functionality to call the `P256VERIFY` precompile defined in [EIP-7212]
to verify Secp256r1 signatures.

It can be used in a solidity smart contract like this:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Secp256r1} from "/path/to/forge-alphanet/src/sign/Secp256r1.sol";

contract Secp256r1Example {
    event OperationResult(bool success);

    // Function to perform a Secp256r1 signature verification with error handling
    function performP256Verify(bytes memory input) public {
        bool result = Secp256r1.verify(input);
        emit OperationResult(result);
    }
}
```

## EIP-3074 invokers

### Gas Sponsor Invoker

The GasSponsorInvoker is a smart contract designed to utilize EIP-3074 auth and
authcall operations, allowing transactions to be sponsored in terms of gas fees.
This contract enables an external account (EOA) to authorize the invoker to
execute specific actions on its behalf without requiring the EOA to provide gas
for these transactions.

#### Deployment
1. Compile the Contract: you can use the following command:
```shell
$ make build
```
2. Deploy the contract to AlphaNet:
```shell
$ forge create GasSponsorInvoker --private-key <your-private-key> --rpc-url <alphanet-rpc-url>
```
Take note of GasSponsorInvoker address.

#### How to use

1. Define target contract
Imagine a simple contract Greeter that stores a greeting message:
```solidity
contract Greeter {
    string public greeting;

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }
}
```
2. Authorizing a transaction
To authorize a transaction, the authorizer signs a digest of the transaction
details. This process is streamlined by our invoker interface:

* Deploy `Greeter` and note its address.
* Generate the digest:
```shell
$ cast call <GasSponsorInvoker-address> "getDigest(bytes32)" <commit> --rpc-url <alphanet-rpc-url>
```
* Sign the digest
```shell
$ cast sign <digest> --private-key <private-key>
```
This gives the `v`, `r` and `s` values of the signature.

3. Interacting with `GasSponsorInvoker` from a smart contract: TODO


[AlphaNet]: https://github.com/paradigmxyz/alphanet
[EIP-2537]: https://eips.ethereum.org/EIPS/eip-2537
[EIP-7212]: https://eips.ethereum.org/EIPS/eip-7212
