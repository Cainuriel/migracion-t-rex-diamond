
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
contract TrustedIssuersFacet {
    event TrustedIssuerAdded(address indexed issuer, uint256[] claimTopics);
    event TrustedIssuerRemoved(address indexed issuer);

    modifier onlyOwner() {
        require(msg.sender == LibAppStorage.diamondStorage().owner, "Not owner");
        _;
    }

    function addTrustedIssuer(address issuer, uint256[] calldata topics) external onlyOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.trustedIssuers[topics[0]].push(issuer); // simplificado para un topic:issuer
        emit TrustedIssuerAdded(issuer, topics);
    }

    function removeTrustedIssuer(address issuer, uint256 topic) external onlyOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address[] storage list = s.trustedIssuers[topic];
        for (uint i = 0; i < list.length; i++) {
            if (list[i] == issuer) {
                list[i] = list[list.length - 1];
                list.pop();
                emit TrustedIssuerRemoved(issuer);
                break;
            }
        }
    }

    function getTrustedIssuers(uint256 topic) external view returns (address[] memory) {
        return LibAppStorage.diamondStorage().trustedIssuers[topic];
    }
}
