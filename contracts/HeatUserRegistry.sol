// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./HeatLibrary.sol";

contract HeatUserRegistry {
    
    struct HeatUser {
        address userAddress;
        bytes16 username;
        bytes16 phoneNumber;
    }
    
    mapping(address => HeatUser) private users;
    
    event HeatUserCreated(address indexed userAddress, string indexed username);
    
    modifier userExists() {
        require(users[msg.sender].username != 0, "User does not exist.");
        _;
    }
    
    modifier userDoesNotExist() {
        require(users[msg.sender].username == 0, "User already exists.");
        _;
    }
    
    function createUser(string calldata _username, string calldata _phoneNumber) external userDoesNotExist() {
        bytes16 usernameBytes = HeatLibrary.stringToBytes16(_username);
        bytes16 phoneNumberBytes = HeatLibrary.stringToBytes16(_phoneNumber);
        
        users[msg.sender] = HeatUser({
            userAddress: msg.sender,
            username: usernameBytes,
            phoneNumber: phoneNumberBytes
        });
        
        emit HeatUserCreated(msg.sender, _username);
    }
    
    function getUser(address _userAddress) external view userExists() returns (bytes16) {
        return users[_userAddress].username;
    }

    function isUserRegistered(address _userAddress) external view returns (bool) {
        return users[_userAddress].username != 0;
    }

}
