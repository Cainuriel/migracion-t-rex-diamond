// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ComplianceInternalFacet } from "./internal/ComplianceInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title ComplianceFacetExternal - External interface for Compliance operations
/// @dev Exposes only public/external functions, inherits business logic from ComplianceInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract ComplianceFacetExternal is ComplianceInternalFacet, IEIP2535Introspection {

    modifier onlyOwner() {
        _onlyOwner(msg.sender);
        _;
    }

    // ================== EXTERNAL COMPLIANCE FUNCTIONS ==================

    /// @notice Set maximum balance limit per investor
    /// @param max Maximum balance allowed
    function setMaxBalance(uint256 max) external onlyOwner {
        _setMaxBalance(max);
    }

    /// @notice Set minimum balance limit per investor
    /// @param min Minimum balance required
    function setMinBalance(uint256 min) external onlyOwner {
        _setMinBalance(min);
    }

    /// @notice Set maximum number of investors allowed
    /// @param max Maximum number of investors
    function setMaxInvestors(uint256 max) external onlyOwner {
        _setMaxInvestors(max);
    }

    /// @notice Check if a transfer is compliant with all rules
    /// @param from Sender address
    /// @param to Recipient address
    /// @param amount Transfer amount
    /// @return True if transfer is compliant
    function canTransfer(address from, address to, uint256 amount) external view returns (bool) {
        return _canTransfer(from, to, amount);
    }

    /// @notice Get current compliance rules
    /// @return maxBalance Maximum balance limit
    /// @return minBalance Minimum balance limit
    /// @return maxInvestors Maximum investors limit
    function complianceRules() external view returns (uint256 maxBalance, uint256 minBalance, uint256 maxInvestors) {
        return _getComplianceRules();
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
        selectors_[--selectorsLength] = this.setMaxBalance.selector;
        selectors_[--selectorsLength] = this.setMinBalance.selector;
        selectors_[--selectorsLength] = this.setMaxInvestors.selector;
        selectors_[--selectorsLength] = this.canTransfer.selector;
        selectors_[--selectorsLength] = this.complianceRules.selector;
    }
}
