// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IAccount, ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {Transaction, MemoryTransactionHelper} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT, BOOTLOADER_FORMAL_ADDRESS, DEPLOYER_SYSTEM_CONTRACT} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {INonceHolder} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
import {Utils} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/Utils.sol";

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ZKMinimalAccount is IAccount, Ownable {
    using MemoryTransactionHelper for Transaction;

    error ZkMinimalAccount__NotEnoughBalance();
    error ZkMinimalAccount__NotFromBootLoader();
    error ZkMinimalAccount__NotFromBootLoaderOrOwner();
    error ZkMinimalAccount__ExecutionFailed();
    error ZKMinimalAccount__FailedToPay();

    modifier requireFromBootloader() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS)
            revert ZkMinimalAccount__NotFromBootLoader();
        _;
    }

    modifier requireFromBootloaderOrOwner() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner())
            revert ZkMinimalAccount__NotFromBootLoaderOrOwner();
        _;
    }

    constructor() Ownable(msg.sender) {}

    function validateTransaction(
        bytes32,
        /*_txHash*/ bytes32,
        /*_suggestedSignedHash*/ Transaction memory _transaction
    ) external payable requireFromBootloader returns (bytes4 magic) {
        SystemContractsCaller.systemCallWithPropagatedRevert(
            (uint32(gasleft())),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(
                INonceHolder.incrementMinNonceIfEquals,
                (_transaction.nonce)
            )
        );

        uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
        if (totalRequiredBalance > address(this).balance) {
            revert ZkMinimalAccount__NotEnoughBalance();
        }

        bytes32 txHash = _transaction.encodeHash();
        address signer = ECDSA.recover(txHash, _transaction.signature);
        bool isValidSigner = signer == owner();
        if (isValidSigner) {
            magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
        } else {
            magic = bytes4(0);
        }
        return magic;
    }

    function executeTransaction(
        bytes32,
        /*_txHash*/ bytes32,
        /*_suggestedSignedHash*/ Transaction memory _transaction
    ) external payable requireFromBootloaderOrOwner {
        address to = address(uint160(_transaction.to));
        uint128 value = Utils.safeCastToU128(_transaction.value);
        bytes memory data = _transaction.data;

        if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
            uint32 gas = Utils.safeCastToU32(gasleft());
            SystemContractsCaller.systemCallWithPropagatedRevert(
                gas,
                to,
                value,
                data
            );
        } else {
            bool success;
            assembly {
                success := call(
                    gas(),
                    to,
                    value,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
            }
            if (!success) {
                revert ZkMinimalAccount__ExecutionFailed();
            }
        }
    }

    function executeTransactionFromOutside(
        Transaction memory _transaction
    ) external payable {}

    function payForTransaction(
        bytes32,
        /*_txHash*/ bytes32,
        /*_suggestedSignedHash*/ Transaction memory _transaction
    ) external payable {
        bool success = _transaction.payToTheBootloader();
        if (!success) revert ZKMinimalAccount__FailedToPay();
    }

    function prepareForPaymaster(
        bytes32 _txHash,
        bytes32 _possibleSignedHash,
        Transaction memory _transaction
    ) external payable {}
}
