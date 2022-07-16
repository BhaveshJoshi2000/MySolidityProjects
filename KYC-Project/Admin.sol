//SPDX-License-Identifier: MIT;
pragma solidity ^0.8.7;
import "./Bank.sol";

//Bank.sol will be used fetch and manipulate the data of banks, as it contains data of banks

contract Admin is Bank {
    address public i_owner; //owner is immutable

    constructor() {
        i_owner = msg.sender; //seeting owner for the address which is used to deploy the contract
    }

    //check if function is called by owner
    modifier onlyAdmin() {
        require(msg.sender == i_owner, "Not Authorised");
        _;
    }

    //adding the bank
    function addBank(
        string memory _name,
        address _address,
        string memory _regNumber
    ) public onlyAdmin {
        banks[_address].name = _name;
        banks[_address].ethAddress = _address;
        //complaints, Kyccount, will be 0 by default
        banks[_address].complaints = 0;
        banks[_address].kycCount = 0;
        banks[_address].isAllowedToVote = true; //will be true by default
        banks[_address].regNumber = _regNumber;

        bankCount++; //increments by 1 whenever the Bank is added
    }

    function removeBank(address _address) public onlyAdmin {
        delete banks[_address];
        //changes all values to 0 and false but
        //does not free space alloted to mapping element
    }

    function ModifyIsAllowedToVote(address _address) public onlyAdmin {
        require(
            banks[_address].complaints > (bankCount / 3), //will work only if no. of complaints > one third bankCount
            "Not Enough Complaints"
        );
        banks[_address].isAllowedToVote = false; //changing the value to false
    }
}
