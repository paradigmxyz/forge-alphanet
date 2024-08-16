# forge-alphanet

Set of solidity utilities to ease deployment and usage of applications on
[AlphaNet].

## EOF support

This repository is configured to compile contracts for [EOF]. This is done by using solc binary from [forge-eof] repository distrbuted as a docker image. To be able to compile contracts you will need to have [Docker] installed.

To make sure that everything is working properly you can run the following command:
```shell
$ ./eof-solc --version
```

It will pull the docker image on a first run and should print the version of the solc binary.

After that, make sure that your forge version is up to data (run `foundryup` if needed), and then you should be able to use all usual forge commands —— all contracts will get compiled for EOF.

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

## Account controlled by a P256 key

With EIP-7702 and EIP-7212 it is possible to delegate control over an EOA to a P256 key. This has large potential for UX improvement as P256 keys are adopted by commonly used protocols like [Apple Secure Enclave] and [WebAuthn].

We are demonstrating a simple implementation of an account that can be controlled by a P256 key. EOAs can delegate to this contract and configure an authorized P256 key, which can then be used to perform actions on behalf of the EOA.

To run the commands below, you will need to have [Python] and `openssl` CLI tool installed.

1. Run anvil in Alphanet mode to enable support for EIP-7702 and P256 precompile:
```shell
$ anvil --alphanet
```
We will be using dev account with address `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` and private key `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`.

2. Generate a P256 private and public key pair:
```shell
$ python examples/p256.py gen
```

This command will generate a private and public key pair, save them to `private.pem` and `public.pem` respectively, and print the public key in hex format.

3. Deploy [P256Delegation](src/P256Delegation.sol) contract which we will be delegating to:
```shell
$ forge create P256Delegation --private-key "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" --rpc-url "http://127.0.0.1:8545"
```

4. Configure delegation contract:
Send EIP-7702 transaction, delegating to our newly deployed contract.
This transaction will both authorize the delegation and set it to use our P256 public key:
```shell
$ cast send 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 'authorize(uint256,uint256)' '<public key X>' '<public key Y>' --auth "<address of P256Delegation>" --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
Note that we are transacting with our EOA account which already includes the updated code.

Verify that new code at our EOA account contains the [delegation designation]:
```shell
$ cast code 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
0xef0100...
```

5. After that, you should be able to transact on behalf of the EOA account by using the `transact` function of the delegation contract.
Let's generate a signature for sending 1 ether to zero address by using our P256 private key:
```shell
python examples/p256.py sign $(cast abi-encode 'f(uint256,address,bytes,uint256)' $(cast call 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 'nonce()(uint256)') '0x0000000000000000000000000000000000000000' '0x' '1000000000000000000')
```

Note that it uses `cast call` to get internal nonce of our EOA used to protect against replay attacks.
It also abi-encodes the payload expected by the `P256Delegation` contract, and passes it to our Python script to sign with openssl.

Command output will contain the signature r and s values, which we then should pass to the `transact` function of the delegation contract:
```shell
cast send 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 'transact(address to,bytes data,uint256 value,bytes32 r,bytes32 s)' '0x0000000000000000000000000000000000000000' '0x' '1000000000000000000' '<r value>' '<s value>' --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

Note that we are using a different private key here, this transaction can be sent by anyone as it was authorized by our P256 key.


[AlphaNet]: https://github.com/paradigmxyz/alphanet
[EOF]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3540.md
[forge-eof]: https://github.com/paradigmxyz/forge-eof
[Docker]: https://docs.docker.com/
[EIP-2537]: https://eips.ethereum.org/EIPS/eip-2537
[EIP-7212]: https://eips.ethereum.org/EIPS/eip-7212
[EIP-3074]: https://eips.ethereum.org/EIPS/eip-3074
[foundry-alphanet]: https://github.com/paradigmxyz/foundry-alphanet
[Apple Secure Enclave]: https://support.apple.com/guide/security/secure-enclave-sec59b0b31ff/web
[WebAuthn]: https://webauthn.io/
[Python]: https://www.python.org/
[delegation designation]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-7702.md#delegation-designation