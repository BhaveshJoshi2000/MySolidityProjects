//SPDX-License-Identifier: MIT;
pragma solidity ^0.8.7;
import "./KYC.sol";

//KYC.sol contains data and list of customers and it will be used by Bank.sol
contract Bank is KYC {
    uint requestId = 0;

    //Defining how details of Bank will be stored
    struct BankDetails {
        string name;
        address ethAddress; //address of Bank
        uint complaints; //will increment if complaint is raised
        uint kycCount; //kyc initiated by the bank
        bool isAllowedToVote;
        string regNumber; //reg.No
    }

    mapping(address => BankDetails) banks; //KEY: address of bank  VALUE:BankDetails

    //check if bank is allowed to vote
    modifier isVoteAllowed() {
        require(banks[msg.sender].isAllowedToVote == true, "Not allowed!");
        _;
    }

    //adding the customer and giving the values
    function addCustomer(string memory _userName, string memory _customerData)
        public
        isCustomerNotPresent(_userName) //can only be executed if customer is not present already
    {
        //initialise the data of the customer
        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
    }

    //get the details of the customer
    function viewCustomer(string memory _userName)
        public
        view
        isCustomerPresent(_userName) //check if customer is already present
        returns (
            string memory,
            string memory,
            address
        )
    {
        return (
            customers[_userName].userName,
            customers[_userName].data,
            customers[_userName].bank
        );
    }

    //modifying customer data
    function modifyCustomer(
        string memory _userName,
        string memory _newcustomerData
    ) public isCustomerPresent(_userName) isVoteAllowed {
        customers[_userName].data = _newcustomerData;
    }

    //upvote customer
    function upVoteCustomer(string memory _userName)
        public
        isVoteAllowed
        isRequested(_userName)
    {
        customers[_userName].upVote++;
    }

    //downVote customer
    //checks:
    //        is bank allowed to vote
    //        is customer's Kyc is requested or not
    function downVoteCustomer(string memory _userName)
        public
        isVoteAllowed
        isRequested(_userName)
    {
        customers[_userName].downVote++;
    }

    function reportBank(address _address) public isVoteAllowed {
        banks[_address].complaints++; //increments complaints by 1
    }

    function getBankComplaints(address _address) public view returns (uint) {
        return banks[_address].complaints;
    }

    function getBankDetails(address _address)
        public
        view
        returns (BankDetails memory)
    {
        return banks[_address];
    }

    //adds request element to request list
    function addRequest(string memory _userName)
        public
        isCustomerPresent(_userName)
        isVoteAllowed
        isNotRequested(_userName)
    {
        requestList[_userName].userName = _userName;
        requestList[_userName].data = customers[_userName].data;
        requestList[_userName].requestBank = msg.sender;
        requestList[_userName].isRequest = true;
    }

    function removeRequest(string memory _userName)
        public
        isRequested(_userName)
    {
        require(
            msg.sender == requestList[_userName].requestBank,
            "Only The Bank Which Initiated the Request Can Remove It"
        );

        delete requestList[_userName]; //change values of request elements to zero but does not free space
    }
}
