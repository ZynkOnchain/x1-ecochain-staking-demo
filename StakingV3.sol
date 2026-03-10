// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
}

contract StakingV3 {

    IERC20 public token;

    struct StakeInfo {
        uint amount;
        uint startTime;
        uint lockPeriod;
        uint apy;
    }

    mapping(address => StakeInfo) public stakes;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function stake(uint amount, uint pool) public {

        require(amount > 0, "Invalid amount");

        uint lockPeriod;
        uint apy;

        if(pool == 0){ lockPeriod = 0; apy = 25; }         // 2.5%
        if(pool == 1){ lockPeriod = 30 days; apy = 3; }
        if(pool == 2){ lockPeriod = 90 days; apy = 10; }
        if(pool == 3){ lockPeriod = 180 days; apy = 25; }
        if(pool == 4){ lockPeriod = 365 days; apy = 80; }

        token.transferFrom(msg.sender, address(this), amount);

        stakes[msg.sender] = StakeInfo({
            amount: amount,
            startTime: block.timestamp,
            lockPeriod: lockPeriod,
            apy: apy
        });
    }

    function calculateReward(address user) public view returns(uint){

        StakeInfo memory s = stakes[user];

        uint timeStaked = block.timestamp - s.startTime;

        uint reward = s.amount * s.apy * timeStaked / (365 days * 100);

        return reward;
    }

    function withdraw() public {

        StakeInfo memory s = stakes[msg.sender];

        require(s.amount > 0, "No stake");

        uint timeStaked = block.timestamp - s.startTime;

        uint reward = calculateReward(msg.sender);

        uint penalty = 0;

        if(s.lockPeriod > 0){

            if(timeStaked < s.lockPeriod / 3){
                penalty = s.amount * 25 / 100;
            }

            else if(timeStaked < (s.lockPeriod * 2) / 3){
                penalty = s.amount * 10 / 100;
            }

        }

        uint payout = s.amount + reward - penalty;

        delete stakes[msg.sender];

        token.transfer(msg.sender, payout);
    }
}