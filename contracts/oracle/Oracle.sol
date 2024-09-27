// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Oracle {

    address internal oracle;

    modifier isOracle() {
        require(msg.sender == oracle, "This action is restricted to the associated off-chain Oracle.");
        _;
    }

}