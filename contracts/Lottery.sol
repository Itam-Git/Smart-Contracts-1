// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Lottery {
    // Address of the admin who deployed the contract
    address public admin;

    // List of players who entered the lottery
    address[] public players;

    // Price of a lottery ticket
    uint256 public ticketPrice = 0.01 ether;

    // Address of the winner (set after picking the winner)
    address public winner;

    // Constructor: Initializes the admin as the deployer of the contract
    constructor() {
        admin = msg.sender;
    }

    // Function to enter the lottery by paying the ticket price
    function enter() public payable {
        // Ensure the sender has paid at least the ticket price
        require(msg.value >= ticketPrice, "Minimum 0.01 ETH required to enter lottery.");
        
        // Add the sender to the list of players
        players.push(msg.sender);
    }

    // Function for the admin to pick a random winner
    function pickWinner() public {
        // Ensure that only the admin can call this function
        require(msg.sender == admin, "Only admin can pick a winner.");

        // Ensure there are players in the lottery
        require(players.length > 0, "No players in the lottery.");

        // Generate a random index based on block data and players array
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;

        // Set the winner
        winner = players[randomIndex];
    }

    // Function for the winner to claim their prize
    function claimPrize() public {
        // Ensure the sender is the winner
        require(msg.sender == winner, "You are not the winner.");

        // Get the contract's balance to determine the prize
        uint256 balance = address(this).balance;

        // Ensure there are funds to claim
        require(balance > 0, "No funds to claim.");

        // Reset the winner to allow for a new lottery round
        winner = address(0);

        // Transfer the prize to the winner
        payable(msg.sender).transfer(balance);
    }

    // Function to get the list of all players in the lottery
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}
