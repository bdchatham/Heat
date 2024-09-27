// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./Oracle.sol";

contract VoteResultOracle is Oracle {

    mapping(bytes32 => address[]) public groupWinners;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function setWinner(bytes32 _eventHash, address _winner) external isOracle {
        groupWinners[_eventHash].push(_winner);
    }

    function getWinner(bytes32 _eventHash) external view returns (address) {
        address[] memory winners = groupWinners[_eventHash];
        return winners[winners.length - 1];
    }
}
