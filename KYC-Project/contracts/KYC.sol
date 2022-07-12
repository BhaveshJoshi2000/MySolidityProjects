//SPDX-License-Identifier: MIT;
pragma solidity ^0.8.7;

contract KYC {
    //Defining how data of customer will be saved
    struct Customer {
        string userName;
        string data; //hash of the data provided by the customer
        bool kycStatus; //true if verified
        uint downVote; //number of downvotes
        uint upVote; //number of upvotes
        address bank; //Bank associated with customer
    }

    //Defining the KycRequest
    struct KycRequest {
        string userName;
        string data;
        address requestBank; //Bank which requested the KYC
        bool isRequest; //will be used to check the valid request
    }

    mapping(string => KycRequest) public requestList;

    mapping(string => Customer) customers; //key:username of customer value:customer details

    //checking if customer is present
    modifier isCustomerPresent(string memory _name) {
        require(
            customers[_name].bank != address(0), //if bank of customer is not empty then customer is present
            "customer is not present in database"
        );
        _;
    }

    //checking if customer is not present
    modifier isCustomerNotPresent(string memory _name) {
        require(
            customers[_name].bank == address(0), //if bank of customer is empty then customer is not present
            "customer is present in database"
        );
        _;
    }
    //checking if Kyc is requested or Not
    modifier isRequested(string memory _userName) {
        require(
            requestList[_userName].isRequest == true,
            "Request Not Found!!!"
        );
        _;
    }
    //checking if Kyc is not requested
    modifier isNotRequested(string memory _userName) {
        require(
            requestList[_userName].isRequest == false,
            "Request Already Exists!!!"
        );
        _;
    }
}
