// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Lottery {
    address public admin;   // Address of the admin who deployed the contract
    address[] public players;    // List of players who entered the lottery
    uint256 public ticketPrice = 0.01 ether;    // Price of a lottery ticket
    address public winner;    // Address of the winner (set after picking the winner)
    address public feeCollector; // Address that stores fees from players

    uint256 public feePercent = 10; // 10%

    event LotteryReset();

    // Constructor: Initializes the admin as the deployer of the contract
    constructor(address _feeCollector) {
        admin = msg.sender;
        feeCollector = _feeCollector;
    }

    // Modyfikator sprawdzający, czy wywołujący funkcję jest adminem
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    // Modyfikator sprawdzający, czy wywołujący funkcję jest zwycięzcą
    modifier onlyWinner() {
        require(msg.sender == winner, "You are not the winner.");
        _;
    }

    // Function to enter the lottery by paying the ticket price
    function enter() public payable {
        // Ensure the sender has paid the ticket price
        require(msg.value == ticketPrice, "0.01 ETH required to enter lottery.");
        
        uint256 feeAmount = (msg.value * feePercent) / 100; // Obliczenie wysokosci fee

        // Send fee to feeCollector
        (bool sent,) = payable(feeCollector).call{value: feeAmount}("");
        require(sent, "Fee transfer failed.");

        // Add the sender to the list of players
        players.push(msg.sender);
    }

    // Function for the admin to pick a random winner
    function pickWinner() public onlyAdmin {
        // Ensure there are players in the lottery
        require(players.length > 0, "No players in the lottery.");

        // Generate a random index based on block data and players array
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;

        // Set the winner
        winner = players[randomIndex];
    }

    // Function for the winner to claim their prize
    function claimPrize() public onlyWinner {
        // Get the contract's balance to determine the prize
        uint256 balance = address(this).balance;

        // Ensure there are funds to claim
        require(balance > 0, "No funds to claim.");

        // Transfer the prize to the winner
        payable(msg.sender).transfer(balance);

        // Reset the Lottery to allow for a new round
        delete players;
        winner = address(0);
        emit LotteryReset();
    }

    // Function for resetting the Lottery. Unclaimed prize is included in the next draw
    function reset() public onlyAdmin {
        delete players;
        winner = address(0);

        emit LotteryReset();
    }

    // Function to get the list of all players in the lottery
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Function to get the current prizePool
    function getPrizePool() public view returns (uint256) {
        return address(this).balance;
    }
}
