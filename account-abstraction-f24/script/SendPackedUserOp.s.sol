// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
// import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SendPackedUserOp is Script {
  function run() public{}

  function generatedSignedUserOperation(bytes memory callData, address sender) public returns(PackedUserOperation memory) {
    uint256 nonce = vm.getNonce(sender);
    PackedUserOperation memory unsignedUserOp = _generateUnsignedUserOperation(callData, sender, nonce);
  }

  function _generateUnsignedUserOperation(bytes memory callData, address sender, uint256 nonce) internal pure returns (PackedUserOperation memory) {
    uint128 verificationGasLimit = 16777216;
    uint128 callGasLimit = verificationGasLimit;
    uint128 maxPriorityFeePerGas = 256;
    uint128 maxFeePerGas = maxPriorityFeePerGas;
    return PackedUserOperation({
        sender: sender,
        nonce: nonce,
        initCode: hex"",
        callData: callData,
        accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
        preVerificationGas: verificationGasLimit,
        gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
        paymasterAndData: hex"",
        signature: hex""
    });
  }
}
