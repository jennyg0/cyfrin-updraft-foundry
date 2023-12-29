// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract ManualToken {
    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 senderBalance = s_balances[msg.sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        s_balances[msg.sender] = senderBalance - amount;
        s_balances[recipient] += amount;
        return true;
    }
}
