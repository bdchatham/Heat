// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

contract Owned {

    address internal owner;

    modifier isOwner() {
        require(msg.sender == owner, "This action is restricted to the owner of the contract.");
        _;
    }

    function changeOwner(address newOwner) internal isOwner {
        owner = newOwner;
    }

}