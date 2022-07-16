//SPDX-License-Identifier: MIT;
pragma solidity ^0.8.7;
import "./KYC.sol";

//KYC.sol contains data and list of customers and it will be used by Bank.sol
contract Bank is KYC {
    uint public bankCount = 0; //will increment whenever the bank is added

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

        addRequest(_userName); //addRequest will be automatically called after adding new customer
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

        customers[_userName].kycStatus = false; //status of modified Kyc will be false and will be true after verified

        addRequest(_userName); //addRequest will be automatically called after modifying new data
    }

    //upvote customer
    function upVoteCustomer(string memory _userName)
        public
        isVoteAllowed
        isRequested(_userName)
    {
        customers[_userName].upVote++;

        if (
            customers[_userName].upVote + customers[_userName].downVote ==
            bankCount
        ) {
            verifyCustomer(_userName); //if all the votes are done verifyCustomer function is called
            removeRequest(_userName); //remove request from request list
        }
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

        if (
            customers[_userName].upVote + customers[_userName].downVote ==
            bankCount
        ) {
            verifyCustomer(_userName); //if all the votes are done verifyCustomer function is called
            removeRequest(_userName); //remove request from request list
        }
    }

    function reportBank(address _address) public isVoteAllowed {
        banks[_address].complaints++; //increments complaints by 1
        if (banks[_address].complaints > bankCount / 3) {
            banks[_address].isAllowedToVote = false;
        }
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

    function verifyCustomer(string memory _userName) private {
        require(
            customers[_userName].upVote > customers[_userName].downVote &&
                customers[_userName].downVote < bankCount / 3,
            "Customer does not meet the conditions to verify hence request rejected"
        );

        //if upvotes>downvotes and downvote< bankcount/3 then verify else rejected

        customers[_userName].upVote = 0; //again set upVote and downvote to 0 for future modification
        customers[_userName].downVote = 0;
        customers[_userName].kycStatus = true; //set kycStatus to true after verifying
    }
}
