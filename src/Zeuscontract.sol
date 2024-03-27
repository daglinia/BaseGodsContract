// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.14;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import { PaymentInterface } from "./InterfacePC.sol";

contract ZeusContract is Ownable {

    address public paymentContractAddress = 0x0000000000000000000000000000000000000000;
    address public olympusClash = 0x0000000000000000000000000000000000000000;
    PaymentInterface payment_interface = PaymentInterface(paymentContractAddress);

    event LoseDraw(address indexed _owner);

    function olympusClashAddress(address _address) public onlyOwner {
        olympusClash = _address;    }



    function luckyDraw(address _owner) external {
        require(msg.sender == olympusClash, "Caller is not allowed");
        uint256 calcAmaount = generate4DigitNumber();
        
        if (calcAmaount >= 4907 && calcAmaount<=9999) {
            emit LoseDraw(_owner);
        } else if (calcAmaount >= 1000 && calcAmaount<=2373) {
            uint256 amount= 0.1 ether;
            send_payment(_owner, amount);
        } else if (calcAmaount >= 2374 && calcAmaount<=3791) {
            uint256 amount= 0.2 ether;
            send_payment(_owner, amount);
        } else if (calcAmaount >= 3792 && calcAmaount<=4352) {
            uint256 amount= 0.4 ether;
            send_payment(_owner, amount);
        } else if (calcAmaount >= 4353 && calcAmaount<=4758) {
            uint256 amount= 0.8 ether;
            send_payment(_owner, amount);
        } else if (calcAmaount >= 4759 && calcAmaount<=4850) {
            uint256 amount= 1.6 ether;
            send_payment(_owner, amount);
        } else if (calcAmaount >= 4851 && calcAmaount<=4906) {
            uint256 amount= 3.2 ether;
            send_payment(_owner, amount);
        }
    }


    function send_payment(address _owner, uint256 amount) internal {
        payment_interface.sendFunds(_owner, amount);
    }


    function generate4DigitNumber() internal view returns (uint256) {
        // Pseudo-random function using block variables
        uint256 random = getRandom(block.number);

        // Construct a 4-digit number
        uint256 fourDigitNumber = (random % 9000) + 1000;

        return fourDigitNumber;
    }

    function getRandom(uint256 input) internal pure returns (uint256) {
        // Pseudo-random function using block variables
        uint256 random = uint256(keccak256(abi.encodePacked(input))) % 9000 + 1000;

        return random;
    }

       function setPaymentAddress(address _address) public onlyOwner {
        paymentContractAddress = _address;
        payment_interface = PaymentInterface(paymentContractAddress);
    }

}
