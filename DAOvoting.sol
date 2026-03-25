// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
}

contract DAOVoting {

    IERC20 public token;

    struct Proposal {
        string description;
        uint yesVotes;
        uint noVotes;
        uint deadline;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    Proposal[] public proposals;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function createProposal(string memory _description, uint duration) public {

        Proposal storage p = proposals.push();

        p.description = _description;
        p.deadline = block.timestamp + duration;
    }

    function vote(uint proposalId, bool support) public {

        Proposal storage p = proposals[proposalId];

        require(block.timestamp < p.deadline, "Voting ended");
        require(!p.hasVoted[msg.sender], "Already voted");

        uint votingPower = token.balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");

        if(support){
            p.yesVotes += votingPower;
        } else {
            p.noVotes += votingPower;
        }

        p.hasVoted[msg.sender] = true;
    }

    function getResult(uint proposalId) public view returns(string memory){

        Proposal storage p = proposals[proposalId];

        require(block.timestamp >= p.deadline, "Voting not ended");

        if(p.yesVotes > p.noVotes){
            return "Approved";
        } else {
            return "Rejected";
        }
    }
}