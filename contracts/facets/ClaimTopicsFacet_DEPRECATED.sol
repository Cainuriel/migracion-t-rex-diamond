// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

contract ClaimTopicsFacet is IEIP2535Introspection {
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

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 3;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.addClaimTopic.selector;
        selectors_[--selectorsLength] = this.removeClaimTopic.selector;
        selectors_[--selectorsLength] = this.getClaimTopics.selector;
    }
}