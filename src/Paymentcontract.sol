// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.14;

import "openzeppelin-contracts/contracts/access/Ownable.sol";


contract PaymentContract is Ownable {

    address public expectedAddress = 0x0000000000000000000000000000000000000000;

    event FundsSent(address recipient,uint256 amount);

    function setExpectedAddress(address _address) public onlyOwner {
        expectedAddress = _address;
    }

        // Withdraw function allows the contract owner to withdraw funds
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient funds");
        payable(owner()).transfer(amount);
    }

    // Deposit function allows external users or contracts to deposit native currency
    function deposit() external payable {
      
    }

    // Get balance function retrieves the current balance of the payment contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }


    // Send funds function allows the "ZEUS" contract to trigger transfers
    function sendFunds(address recipient, uint256 amount) public {
        require(msg.sender == expectedAddress, "Sender is not the expected contract address");
        require(address(this).balance >= amount, "Insufficient funds");

        payable(recipient).transfer(amount);
        emit FundsSent(recipient, amount);
    }

}
