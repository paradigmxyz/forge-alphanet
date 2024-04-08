## forge-alphanet

Set of solidity utilities to ease deployment and usage of applications on
[AlphaNet].

### BLS library

Functions to allow calling each of the BLS precompiles defined in [EIP-2537]
without the low level details.

For example, this is how the library can be used from a solidity smart contract:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "/path/to/forge-alphanet/src/sign/BLS.sol";

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

[AlphaNet]: https://github.com/paradigmxyz/alphanet
[EIP-2537]: https://eips.ethereum.org/EIPS/eip-2537
