// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract CrowdFunding {
    address public admin;
    address[] public users;
}

constructor() {
    admin = msg.sender;
}

modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can perform this action");
}

modifier onlyGoalOwner() {
    require(msg.sender == onlyGoalOwner, "Only admin can perform this action");
}

function createGoal() public {
    // Complete details about the Goal

    // Mark msg.sender as GoalOwner
}

function contribute() public payable {
    // Send $ to contribute to particular Goal
}

function withdraw() public {
    // Allow GoalOwner to withdraw the $ if requirements are met
    // 1. 100% or more has been reached

    // 2. Contribution time window has ended
}

// Funkcja co automatycznie skonczy zbiorke jak sie nie udalo zebrac celu
// Odesle sama hajs albo bedzie mozna sclaimowac