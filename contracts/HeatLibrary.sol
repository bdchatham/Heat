// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library HeatLibrary {

    struct HeatUserSelection {
        address user;
        bytes32 selection;
    }

    function stringToBytes16(string memory _toConvert) internal pure returns (bytes16 result) {
        bytes memory byteToVerify = bytes(_toConvert);
        require(byteToVerify.length <= 16, "Username too long.");
        require(byteToVerify.length > 0, "Username cannot be empty.");

        assembly {
            result := mload(add(_toConvert, 16))
        }
    }

    function recoverSigner(bytes32 messageHash, bytes memory signature) internal pure returns (address) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function getEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (r, s, v);
    }

    function getUserSelections(address[] memory _participants, mapping(address => bytes32) storage mappedUserSelections) 
        internal view returns (HeatUserSelection[] memory) 
    {
        HeatUserSelection[] memory selections = new HeatUserSelection[](_participants.length);

        for (uint8 index = 0; index < _participants.length; index++) {
            address user = _participants[index];
            selections[index] = HeatUserSelection({
                user: user,
                selection: mappedUserSelections[user]
            });
        }

        return selections;
    }

}