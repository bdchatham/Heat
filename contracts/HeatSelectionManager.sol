// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.27;

import "./HeatLibrary.sol";
import "./Owned.sol";

interface IVoteResultOracle {
    function getResult(bytes32 _eventId) external returns (address);
}

interface IReputationOracle {
    function getReputation(bytes32 _eventId) external returns (uint32);
}

contract HeatSelectionManager is Owned {

    enum Status {
        CREATED,
        PENDING_VOTES,
        COMPLETE
    }

    struct SelectionEvent {
        bytes32 id;
        Status status;
        uint256 blockTimestampSeconds;
        address winner;
        uint32 reputation;
        address[] participants;
        mapping(address => bytes32) userSelections;
    }

    uint32 private sixDaysInSeconds = 518400;
    IVoteResultOracle private voteResultOracle;
    IReputationOracle private reputationOracle;
    mapping(bytes16 => SelectionEvent[]) private musicGroupSelectionEvents;

    event SelectionGroupStateChanged(bytes16 indexed groupName, Status status);
    event UserSelectionMade(bytes16 indexed groupName, address indexed userAddress);
    event UserSelectionDenied(bytes16 indexed groupName, address indexed userAddress, string reason);

    modifier initializationPending(bytes16 _groupName) {
        require(musicGroupSelectionEvents[_groupName][0].reputation == 0, "Selection events already initialized for group.");
        _;
    }

    modifier isInitialized(bytes16 _groupName) {
        require(musicGroupSelectionEvents[_groupName][0].reputation != 0, "Selection events not initialized for group.");
        _;
    }

    constructor(address _owner, address _voteResultOracle, address _reputationOracle) {
        owner = _owner;
        voteResultOracle = IVoteResultOracle(_voteResultOracle);
        reputationOracle = IReputationOracle(_reputationOracle);
    }

    function initiateSelectionEvent(bytes16 _groupName) external initializationPending(_groupName) isOwner {
        SelectionEvent[] storage groupSelectionEvents = musicGroupSelectionEvents[_groupName];
        groupSelectionEvents.push();
        SelectionEvent storage selectionEvent = groupSelectionEvents[groupSelectionEvents.length - 1];
        selectionEvent.blockTimestampSeconds = block.timestamp;
        selectionEvent.id = getEventId(_groupName, block.timestamp);
        selectionEvent.status = Status.CREATED;

        emit SelectionGroupStateChanged(_groupName, selectionEvent.status);
    }

    function startSelectionEventVoting(bytes16 _groupName) external isInitialized(_groupName) isOwner {
        SelectionEvent storage selectionEvent = getSelectionEvent(_groupName);
        require(selectionEvent.status == Status.CREATED, "Invalid status to proceed to voting.");
        require(selectionEvent.blockTimestampSeconds + sixDaysInSeconds <= block.timestamp, "Insufficient time for song selection.");

        selectionEvent.status = Status.PENDING_VOTES;
        emit SelectionGroupStateChanged(_groupName, selectionEvent.status);
    }

    function completeSelectionEvent(bytes16 _groupName) external isInitialized(_groupName) isOwner {
        SelectionEvent storage selectionEvent = getSelectionEvent(_groupName);
        require(selectionEvent.status == Status.PENDING_VOTES, "Invalid status to proceed to voting.");

        selectionEvent.status = Status.COMPLETE;
        emit SelectionGroupStateChanged(_groupName, selectionEvent.status);

        selectionEvent.winner = voteResultOracle.getResult(selectionEvent.id);
        selectionEvent.reputation = reputationOracle.getReputation(selectionEvent.id);
    }

    function makeSongSelection(bytes16 _groupName, bytes32 _userSelection) external {
        SelectionEvent storage selectionEvent = getSelectionEvent(_groupName);
        require(selectionEvent.status == Status.CREATED, "Too late for song selection.");
        address userAddress = msg.sender;

        if (selectionEvent.userSelections[userAddress] == 0) {
            selectionEvent.participants.push(userAddress);
            selectionEvent.userSelections[userAddress] = _userSelection;
            emit UserSelectionMade(_groupName, userAddress);

        } else {
            emit UserSelectionDenied(_groupName, userAddress, "Selection has already been made.");
        }
    }

    function getUserSelections(bytes16 _groupName) external view returns (HeatLibrary.HeatUserSelection[] memory) {
        SelectionEvent storage selectionEvent = getSelectionEvent(_groupName);
        mapping(address => bytes32) storage userSelections = selectionEvent.userSelections;
        address[] memory participants = selectionEvent.participants;
        return HeatLibrary.getUserSelections(participants, userSelections);
    }

    function getSelectionEvent(bytes16 _groupName) private view returns (SelectionEvent storage) {
        SelectionEvent[] storage groupSelectionEvents = musicGroupSelectionEvents[_groupName];
        return groupSelectionEvents[groupSelectionEvents.length - 1];
    }

    function getEventId(bytes16 _groupName, uint256 _eventTimestampSeconds) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_groupName, _eventTimestampSeconds));
    }
    
}