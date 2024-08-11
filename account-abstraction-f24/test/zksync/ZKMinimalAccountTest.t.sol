// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ZKMinimalAccount} from "src/zksync/ZKMinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {Transaction, MemoryTransactionHelper} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";

contract ZKMinimalAccountTest is Test {
    ZKMinimalAccount minimalAccount;
    ERC20Mock usdc;

    uint256 constant AMOUNT = 1e18;
    bytes32 constant EMPTY_BYTES32 = bytes32(0);

    function setUp() public {
        minimalAccount = new ZKMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testZKOwnerCanExecuteCommands() public {
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );

        Transaction memory transaction = _createUnsignedTransaction(
            minimalAccount.owner(),
            113,
            dest,
            value,
            functionData
        );
        vm.prank(minimalAccount.owner());
        minimalAccount.executeTransaction(
            EMPTY_BYTES32,
            EMPTY_BYTES32,
            transaction
        );
    }

    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal view returns (Transaction memory) {
        uint256 nonce = vm.getNonce(address(minimalAccount));
        bytes32[] memory factoryDeps = new bytes32[](0);

        return
            Transaction({
                txType: transactionType, // type 113 (0x71).
                from: uint256(uint160(from)),
                to: uint256(uint160(to)),
                gasLimit: 16777216,
                gasPerPubdataByteLimit: 16777216,
                maxFeePerGas: 16777216,
                maxPriorityFeePerGas: 16777216,
                paymaster: 0,
                nonce: nonce,
                value: value,
                reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
                data: data,
                signature: hex"",
                factoryDeps: factoryDeps,
                paymasterInput: hex"",
                reservedDynamic: hex""
            });
    }
}
