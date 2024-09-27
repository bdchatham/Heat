// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./Oracle.sol";

contract ReputationOracle is Oracle {

    mapping(bytes32 => uint32) public eventReputation;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function setEventReputation(bytes32 _eventHash, uint32 _reputation) external isOracle {
        eventReputation[_eventHash] = _reputation;
    }

    function getReputation(bytes32 _eventHash) external view returns (uint32) {
        return eventReputation[_eventHash];
    }

}