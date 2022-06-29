// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address private manager;
    address payable[] public players;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value >= 1 ether, "Minimum 1-ether required");

        players.push(payable(msg.sender));
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == manager, "Not Authorised!");
        return address(this).balance;
    }

    function getRandom() public view returns (uint256) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    function selectWinner() public payable returns (address) {
        require(msg.sender == manager, "Not Authorised");
        require(players.length >= 3, "Not Enough Participents");

        uint randomIndex = getRandom() % players.length;

        address payable Winner = players[randomIndex];

        Winner.transfer(getBalance());

        players = new address payable[](0);

        return Winner;
    }
}
