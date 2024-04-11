// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import { VmSafe } from "forge-std/Vm.sol";
import {GasSponsorInvoker} from "../../src/eip3074/GasSponsorInvoker.sol";

contract MockContract {
    event Message(address sender, string message);

    function sendMessage(string calldata message) external {
        emit Message(msg.sender, message);
    }
}

contract GasSponsorInvokerTest is Test {
    GasSponsorInvoker public invoker;
    MockContract public mockContract;

    VmSafe.Wallet public authority;

    function setUp() public {
        authority = vm.createWallet("authority");

        invoker = new GasSponsorInvoker();
        mockContract = new MockContract();
    }

    event Message(address sender, string message);

    function testSponsorCall() public {
        bytes32 commit = keccak256("Some unique commit data");
        string memory message = "Hello, World!";
        bytes memory data = abi.encodeWithSelector(MockContract.sendMessage.selector, message);

        bytes32 digest = invoker.getDigest(commit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authority.privateKey, digest);

        vm.expectEmit(true, true, false, true);
        emit Message(address(mockContract), message);

        bool success = invoker.sponsorCall(authority.addr, commit, v, r, s, address(mockContract), data, 0, gasleft());
        assertTrue(success, "Call should be successful");
    }
}
