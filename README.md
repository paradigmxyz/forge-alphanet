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

**NOTE** These invokers temporarily only work with the docker image from
[eip3074-tools] which contains patched versions of solc and forge compatible with
[EIP-3074] instructions.

### Gas Sponsor Invoker

The GasSponsorInvoker is a smart contract designed to utilize [EIP-3074] auth and
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
Imagine a simple contract Greeter that stores `msg.sender` in a variable:
```solidity
contract Greeter {
    address public greeter;

    function setGreeter() public {
        greeter = msg.sender;
    }
}
```
2. Authorizing a transaction
To authorize a transaction, the authorizer signs a digest of the transaction
details. This process is streamlined by our invoker interface:
* Create the authorizer account and note its private key and address:
```shell
$ cast wallet new
```
* Deploy `Greeter` and note its address.
* Get the `setGreeter` method calldata:
```shell
$ cast calldata "setGreeter()"
```
* Generate the digest:
```shell
$ cast call <GasSponsorInvoker-address> "getDigest(address,bytes)" <Greeter-address> <setGreeter-calldata> --rpc-url <alphanet-rpc-url>
```
* Sign the digest
```shell
$ cast sign <digest> --private-key <authorizer-private-key>
```
This gives the `v`, `r` and `s` values of the signature.

3. Interacting with `GasSponsorInvoker`

Now you can send a transaction to be executed as if by the authorizer account
with the gas paid by a different account:

* Send the transaction to `GasSponsorInvoker` from an gas sponsor account (
different from the authorizer and with funds in AlphaNet):
```shelll
$ cast send <GasSponsorInvoker-address> \
    "sponsorCall(address,bytes32,uint8,bytes32,bytes32,address,bytes,uint256,uint256)" \
    <authorizer-address> \
    <signature-v> \
    <signature-r> \
    <signature-v> \
    <Greeter-address> \
    <Greeter-calldata> \
    0 \
    0 \
    --rpc-url <alphanet-rpc-url> \
    --private-key <sponsor-private-key>
```
* Now you can check that the Greeter smart contract register as `msg.sender` the
authorizer account:
```shell
$ cast call <Greeter-address> "greeter()" --rpc-url <alphanet-rpc-url>
```

[AlphaNet]: https://github.com/paradigmxyz/alphanet
[EIP-2537]: https://eips.ethereum.org/EIPS/eip-2537
[EIP-7212]: https://eips.ethereum.org/EIPS/eip-7212
[EIP-3074]: https://eips.ethereum.org/EIPS/eip-3074
[eip3074-tools]: https://github.com/fgimenez/eip-3074-tools
