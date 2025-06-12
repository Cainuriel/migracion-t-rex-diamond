// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";

contract ClaimTopicsFacet {
    event ClaimTopicAdded(uint256 indexed topic);
    event ClaimTopicRemoved(uint256 indexed topic);

    modifier onlyOwner() {
        require(msg.sender == LibAppStorage.diamondStorage().owner, "Not owner");
        _;
    }

    function addClaimTopic(uint256 topic) external onlyOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint i = 0; i < s.claimTopics.length; i++) {
            require(s.claimTopics[i] != topic, "Already added");
        }
        s.claimTopics.push(topic);
        emit ClaimTopicAdded(topic);
    }

    function removeClaimTopic(uint256 topic) external onlyOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint i = 0; i < s.claimTopics.length; i++) {
            if (s.claimTopics[i] == topic) {
                s.claimTopics[i] = s.claimTopics[s.claimTopics.length - 1];
                s.claimTopics.pop();
                emit ClaimTopicRemoved(topic);
                break;
            }
        }
    }

    function getClaimTopics() external view returns (uint256[] memory) {
        return LibAppStorage.diamondStorage().claimTopics;
    }
}