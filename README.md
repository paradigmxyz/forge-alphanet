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

[AlphaNet]: https://github.com/paradigmxyz/alphanet
[EOF]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3540.md
[forge-eof]: https://github.com/paradigmxyz/forge-eof
[Docker]: https://docs.docker.com/
[EIP-2537]: https://eips.ethereum.org/EIPS/eip-2537
[EIP-7212]: https://eips.ethereum.org/EIPS/eip-7212
[EIP-3074]: https://eips.ethereum.org/EIPS/eip-3074
[foundry-alphanet]: https://github.com/paradigmxyz/foundry-alphanet
