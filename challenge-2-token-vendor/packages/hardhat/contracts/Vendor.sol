pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        uint256 tokensToBuy = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= tokensToBuy, "Vendor does not have enough tokens");
        require(yourToken.transfer(msg.sender, tokensToBuy), "Transfer failed");
        emit BuyTokens(msg.sender, msg.value, tokensToBuy);
    }
    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        require(yourToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(yourToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        payable(msg.sender).transfer(_amount / tokensPerEth);
    }
}
