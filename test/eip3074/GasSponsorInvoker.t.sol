// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, stdStorage, StdStorage} from "forge-std/Test.sol";
import {GasSponsorInvoker} from "../../src/eip3074/GasSponsorInvoker.sol";
import "./MockContract.sol";

contract GasSponsorInvokerTest is Test {
    GasSponsorInvoker public invoker;
    MockContract public mockContract;

    address private authorizer;
    uint256 private authorizerPrivateKey = 0xabc123;

    function setUp() public {
        authorizer = vm.addr(authorizerPrivateKey);

        invoker = new GasSponsorInvoker();
        mockContract = new MockContract();
        vm.deal(authorizer, 1 ether);
    }

    event Message(address sender, string message);

    function testSponsorCall() public {
        bytes32 commit = keccak256(abi.encodePacked("Some unique commit data"));
        string memory message = "Hello, World!";
        bytes memory data = abi.encodeWithSelector(MockContract.sendMessage.selector, message);

        bytes32 digest = invoker.getDigest(commit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorizerPrivateKey, digest);

        vm.expectEmit(true, true, false, true);
        emit Message(address(mockContract), message);

        bool success = invoker.sponsorCall(authorizer, commit, v, r, s, address(mockContract), data, 0, gasleft());
        assertTrue(success, "Call should be successful");
    }
}
