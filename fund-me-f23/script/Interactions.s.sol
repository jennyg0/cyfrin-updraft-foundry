// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address _mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentContractAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        fundFundMe(mostRecentContractAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address _mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("FundMe balance withdrawn");
    }

    function run() external {
        address mostRecentContractAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentContractAddress);
    }
}
