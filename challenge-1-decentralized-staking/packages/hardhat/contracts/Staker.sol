// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    event Stake(address indexed user, uint256 amount);

    mapping(address => uint256) public balances;

    uint256 deadline = block.timestamp + 72 hours;

    uint256 public constant threshold = 1 ether;

    bool openForWithdraw = false;

    bool executed = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() public {
        require(block.timestamp > deadline, "Deadline not met");
        require(!executed, "Already executed");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{ value: address(this).balance }();
            executed = true;
        } else {
            openForWithdraw = true;
        }
    }
    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public {
        require(openForWithdraw, "Withdraw not open");
        (bool s, ) = msg.sender.call{ value: balances[msg.sender] }("");
        require(s, "Withdraw failed");
        balances[msg.sender] = 0;
    }
    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp > deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }
    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
