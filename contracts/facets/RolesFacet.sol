// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title RolesFacet - Owner and Agent role management
contract RolesFacet is Initializable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AgentSet(address indexed agent, bool status);

    modifier onlyOwner() {
        require(msg.sender == LibAppStorage.diamondStorage().owner, "RolesFacet: Not owner");
        _;
    }

    function initializeRoles(address _owner) external initializer {
        LibAppStorage.diamondStorage().owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "RolesFacet: new owner is the zero address");
        AppStorage storage s = LibAppStorage.diamondStorage();
        emit OwnershipTransferred(s.owner, _newOwner);
        s.owner = _newOwner;
    }

    function owner() external view returns (address) {
        return LibAppStorage.diamondStorage().owner;
    }

    function setAgent(address _agent, bool _status) external onlyOwner {
        LibAppStorage.diamondStorage().agents[_agent] = _status;
        emit AgentSet(_agent, _status);
    }

    function isAgent(address _addr) external view returns (bool) {
        return LibAppStorage.diamondStorage().agents[_addr];
    }

    modifier onlyAgentOrOwner() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(msg.sender == s.owner || s.agents[msg.sender], "RolesFacet: Not authorized");
        _;
    }
}
