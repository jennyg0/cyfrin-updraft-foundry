// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { BagelToken } from "../src/BagelToken.sol";
import { MerkleAirdrop, IERC20 } from "../src/MerkleAirdrop.sol";
import { Script } from "forge-std/Script.sol";

contract DeployMerkleAirdrop is Script {
  bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
  uint256 private AMOUNT = 4 * 25 * 1e18;

  function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
    vm.startBroadcast();
    BagelToken token = new BagelToken();
    MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
    token.mint(token.owner(), AMOUNT);
    token.transfer(address(airdrop), AMOUNT);
    vm.stopBroadcast();
    
    return(airdrop, token);
  }

  function run() external returns (MerkleAirdrop, BagelToken) {
    return deployMerkleAirdrop();
  }
}
