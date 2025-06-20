// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract CrowdFunding {
    address public admin;
    address[] public users;

    mapping(uint => address) public goalOwners; // map of goal owners
    mapping(uint => Goal) public goals; // map of goals
    uint public goalCount; // number of created goals

    struct Goal {
        string title;
        string description;
        uint targetAmount;
        uint deadline;
        uint collectedAmount;
        address owner;
        bool isCollected;
    }

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyGoalOwner(uint _goalId) {
        require(
            msg.sender == goalOwners[_goalId],
            "Only goal owner can perform this action"
        );
        _;
    }

    function createGoal(
        string memory _title,
        string memory _description,
        uint _targetAmount,
        uint _durationInDays
    ) public {
        // Set requirements for params
        require(bytes(_title).length > 0, "Title can't be empty!");
        require(_targetAmount > 0, "Target must be > 0");
        require(_durationInDays > 0, "Duration must be > 0");
        // Complete details about the Goal
        goals[goalCount] = Goal({
            title: _title,
            description: _description,
            targetAmount: _targetAmount,
            deadline: block.timestamp + (_durationInDays * 1 days),
            collectedAmount: 0,
            owner: msg.sender,
            isCollected: false
        });

        goalOwners[goalCount] = msg.sender;
        // Inscrease number of created goals
        goalCount++;
    }

    function contribute(uint _goalId) public payable {
        // Send $ to contribute to particular Goal
        Goal storage goal = goals[_goalId];
        // Set requirements for donating
        require(block.timestamp < goal.deadline, "Goal has ended");
        require(msg.value > 0, "Contribution must be greater than 0");

        goal.collectedAmount += msg.value;
    }

    function withdraw(uint _goalId) public onlyGoalOwner(_goalId) {
        // Get the contract's balance for particular goal
        Goal storage goal = goals[_goalId];

        require(
            goal.deadline < block.timestamp,
            "You can't claim the tokens yet."
        );
        require(goal.isCollected == false, "You already claimed the tokens!");

        uint256 goalBalance = goal.collectedAmount;

        // Transfer the donations to goal's owner
        payable(msg.sender).transfer(goalBalance);
        goal.isCollected = true;
    }

    // Funkcja co automatycznie skonczy zbiorke jak sie nie udalo zebrac celu
    // Odesle sama hajs albo bedzie mozna sclaimowac
}
