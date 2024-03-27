// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.14;

interface PaymentInterface {
    function sendFunds(address recipient, uint256 amount) external ;
    function deposit() external payable ;
}
