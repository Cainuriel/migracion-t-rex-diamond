// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { RolesInternalFacet } from "./internal/RolesInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title RolesFacet - External interface for Roles operations
/// @dev Exposes only public/external functions, inherits business logic from RolesInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract RolesFacet is RolesInternalFacet, Initializable, IEIP2535Introspection {

    modifier onlyOwner() {
        _onlyOwner(msg.sender);
        _;
    }

    // ================== EXTERNAL ROLES FUNCTIONS ==================

    /// @notice Initialize roles with initial owner
    /// @param initialOwner Initial owner address
    function initializeRoles(address initialOwner) external initializer {
        _setInitialOwner(initialOwner);
    }

    /// @notice Transfer ownership to a new owner
    /// @param newOwner New owner address
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /// @notice Get current owner address
    /// @return Current owner address
    function owner() external view returns (address) {
        return _owner();
    }

    /// @notice Set agent status for an address
    /// @param agent Agent address
    /// @param status True to grant agent role, false to revoke
    function setAgent(address agent, bool status) external onlyOwner {
        _setAgent(agent, status);
    }

    /// @notice Check if address is an agent
    /// @param addr Address to check
    /// @return True if address is an agent
    function isAgent(address addr) external view returns (bool) {
        return _isAgent(addr);
    }

    // ================== IEIP2535INTROSPECTION ==================

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 5;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.initializeRoles.selector;
        selectors_[--selectorsLength] = this.transferOwnership.selector;
        selectors_[--selectorsLength] = this.owner.selector;
        selectors_[--selectorsLength] = this.setAgent.selector;
        selectors_[--selectorsLength] = this.isAgent.selector;
    }
}
