// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

contract TrustedIssuersFacet is IEIP2535Introspection {
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
        selectors_[--selectorsLength] = this.addTrustedIssuer.selector;
        selectors_[--selectorsLength] = this.removeTrustedIssuer.selector;
        selectors_[--selectorsLength] = this.getTrustedIssuers.selector;
    }
}
