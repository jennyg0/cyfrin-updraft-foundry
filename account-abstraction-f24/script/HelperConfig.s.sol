// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
  error HelperConfig__InvalidChainId();

  struct NetworkConfig {
    address entryPoint;
    address account;
  }

    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
     uint256 constant ZKSYNC_MAINNET_CHAIN_ID = 324;

    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address constant BURNER_WALLET = 0x643315C9Be056cDEA171F4e7b2222a4ddaB9F88D;

  NetworkConfig public localNetworkConfig;
  mapping(uint256 chainId => NetworkConfig) public networkConfigs;

   constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
        networkConfigs[ETH_MAINNET_CHAIN_ID] = getEthMainnetConfig();
     networkConfigs[ZKSYNC_MAINNET_CHAIN_ID] = getZkSyncConfig();
    }

        function getConfig() public view returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032,
            account: BURNER_WALLET
        });
    }

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            account: BURNER_WALLET
        });
    }

    function getArbMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032,
            account: BURNER_WALLET
        });
    }

    function getZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0), 
            account: BURNER_WALLET
        });
    }

    function getZkSyncConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0), 
            account: BURNER_WALLET
        });
    }

    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }
        return localNetworkConfig;
    }
}
