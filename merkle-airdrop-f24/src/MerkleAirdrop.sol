// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error  MerkleAirdrop__InvalidProof();

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    event Claim(address account, uint256 amount);

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        emit Claim(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }
}
