// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
}

contract Faucet {

    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function claim() public {
        token.transfer(msg.sender, 10 * 10**18);
    }
}