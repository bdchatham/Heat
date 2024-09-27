// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./HeatLibrary.sol";

interface IUserRegistry {
    function isUserRegistered(address _userAddress) external view returns (bool);
}

interface ISelectionManager {
    function initiateSelectionEvent(bytes16 _groupName, address[] memory _members) external;
}

contract HeatGroupManager {

    struct MusicGroup {
        address creator;
        address[] members;
        bool isActive;
    }

    IUserRegistry private userRegistry; 
    ISelectionManager private selectionManager;
    uint8 private maxGroupSize;
    uint8 private minGroupSize;
    mapping(bytes16 => MusicGroup) private musicGroups;

    event GroupCreated(address indexed creator, bytes16 groupName);
    event InviteSent(bytes16 groupName, address indexed username);
    event InviteAccepted(address indexed username, bytes16 groupName);
    event GroupActivated(bytes16 groupName);

    modifier groupExistsCheck(bytes16 _groupName) {
        require(musicGroups[_groupName].creator != address(0), "Group does not exist");
        _;
    }

    modifier userNotInGroup(bytes16 _groupName) {
        require(!isUserInGroup(_groupName, msg.sender), "User is already in the group");
        _;
    }

    modifier groupIsNotFull(bytes16 _groupName) {
        require(musicGroups[_groupName].members.length <= maxGroupSize, "The group is already full.");
        _;
    }

    modifier callerIsRegisteredUser() {
        require(userRegistry.isUserRegistered(msg.sender), "User must be registered to be invited");
        _;
    }

    constructor(uint8 _minGroupSize, uint8 _maxGroupSize, address _userRegistryAddress, address _selectionEventManager) {
        minGroupSize = _minGroupSize;
        maxGroupSize = _maxGroupSize;
        userRegistry = IUserRegistry(_userRegistryAddress);
        selectionManager = ISelectionManager(_selectionEventManager);
    }


    function createGroup(string calldata _groupName) external callerIsRegisteredUser() {
        address[] memory members;
        bytes16 groupNameBytes = HeatLibrary.stringToBytes16(_groupName);
        MusicGroup memory musicGroup = MusicGroup({
            creator: msg.sender,
            members: members,
            isActive: false
        });

        musicGroups[groupNameBytes] = musicGroup;
        musicGroups[groupNameBytes].members.push(msg.sender);

        emit GroupCreated(msg.sender, groupNameBytes);
    }

    function inviteUser(bytes16 _groupName, address _user) 
        external 
        groupExistsCheck(_groupName)
        groupIsNotFull(_groupName)
    {
        require(!isUserInGroup(_groupName, _user), "User already in the group");

        emit InviteSent(_groupName, _user);
    }

    function acceptInvite(bytes16 _groupName, bytes memory signature) 
        external 
        groupExistsCheck(_groupName) 
        userNotInGroup(_groupName) 
        groupIsNotFull(_groupName)
        callerIsRegisteredUser()
    {
        bytes32 messageHash = getMessageHash(_groupName, msg.sender);
        address signer = HeatLibrary.recoverSigner(messageHash, signature);
        MusicGroup storage musicGroup = musicGroups[_groupName];
        require(signer == musicGroup.creator, "Invalid invite signature");

        address[] storage members = musicGroup.members;
        members.push(msg.sender);

        emit InviteAccepted(msg.sender, _groupName);

        if (!musicGroups[_groupName].isActive && members.length >= minGroupSize) {
            musicGroups[_groupName].isActive = true;
            emit GroupActivated(_groupName);
            selectionManager.initiateSelectionEvent(_groupName, members);
        }
    }

    function isUserInGroup(bytes16 _groupName, address _user) public view returns (bool) {
        MusicGroup memory group = musicGroups[_groupName];
        for (uint i = 0; i < group.members.length; i++) {
            if (group.members[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function getMessageHash(bytes16 _groupName, address _user) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_groupName, _user));
    }

}
