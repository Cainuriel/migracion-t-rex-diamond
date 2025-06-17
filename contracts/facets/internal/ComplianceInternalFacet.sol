// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibComplianceStorage, ComplianceStorage } from "../../storage/ComplianceStorage.sol";
import { LibTokenStorage } from "../../storage/TokenStorage.sol";
import { LibIdentityStorage } from "../../storage/IdentityStorage.sol";
import { LibRolesStorage } from "../../storage/RolesStorage.sol";

/// @title ComplianceInternalFacet - Internal business logic for Compliance domain
/// @dev Contains all the business logic for compliance rules and checks
/// @dev This facet is not directly exposed in the diamond interface
contract ComplianceInternalFacet {
    event MaxBalanceSet(uint256 max);
    event MinBalanceSet(uint256 min);
    event MaxInvestorsSet(uint256 max);

    // ================== INTERNAL COMPLIANCE OPERATIONS ==================

    /// @notice Internal function to set maximum balance limit
    /// @param max Maximum balance allowed per investor
    function _setMaxBalance(uint256 max) internal {
        ComplianceStorage storage cs = LibComplianceStorage.complianceStorage();
        cs.maxBalance = max;
        emit MaxBalanceSet(max);
    }

    /// @notice Internal function to set minimum balance limit
    /// @param min Minimum balance required per investor
    function _setMinBalance(uint256 min) internal {
        ComplianceStorage storage cs = LibComplianceStorage.complianceStorage();
        cs.minBalance = min;
        emit MinBalanceSet(min);
    }

    /// @notice Internal function to set maximum number of investors
    /// @param max Maximum number of investors allowed
    function _setMaxInvestors(uint256 max) internal {
        ComplianceStorage storage cs = LibComplianceStorage.complianceStorage();
        cs.maxInvestors = max;
        emit MaxInvestorsSet(max);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Internal function to check if transfer is compliant
    /// @param from Sender address
    /// @param to Recipient address
    /// @param amount Transfer amount
    /// @return True if transfer is compliant with all rules
    function _canTransfer(address from, address to, uint256 amount) internal view returns (bool) {
        // Check if accounts are frozen (using TokenStorage)
        if (LibTokenStorage.tokenStorage().frozenAccounts[from] || 
            LibTokenStorage.tokenStorage().frozenAccounts[to]) {
            return false;
        }

        // Check if recipient has valid identity
        if (LibIdentityStorage.identityStorage().investorIdentities[to] == address(0)) {
            return false;
        }

        ComplianceStorage storage cs = LibComplianceStorage.complianceStorage();
        uint256 currentBalance = LibTokenStorage.tokenStorage().balances[to];
        uint256 newBalance = currentBalance + amount;

        // Check maximum balance limit
        if (cs.maxBalance > 0 && newBalance > cs.maxBalance) {
            return false;
        }

        // Check minimum balance limit
        if (cs.minBalance > 0 && newBalance < cs.minBalance) {
            return false;
        }

        // Check maximum investors limit (only if recipient currently has zero balance)
        if (cs.maxInvestors > 0 && currentBalance == 0) {
            uint256 currentInvestorCount = _countActiveInvestors();
            if (currentInvestorCount >= cs.maxInvestors) {
                return false;
            }
        }

        return true;
    }

    /// @notice Get current compliance rules
    /// @return maxBalance Maximum balance limit
    /// @return minBalance Minimum balance limit
    /// @return maxInvestors Maximum investors limit
    function _getComplianceRules() internal view returns (uint256 maxBalance, uint256 minBalance, uint256 maxInvestors) {
        ComplianceStorage storage cs = LibComplianceStorage.complianceStorage();
        return (cs.maxBalance, cs.minBalance, cs.maxInvestors);
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @notice Count active investors (those with non-zero balance)
    /// @return Number of active investors
    function _countActiveInvestors() private view returns (uint256) {
        address[] memory holders = LibTokenStorage.tokenStorage().holders;
        uint256 count = 0;
        
        for (uint256 i = 0; i < holders.length; i++) {
            if (LibTokenStorage.tokenStorage().balances[holders[i]] > 0) {
                count++;
            }
        }
        
        return count;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == LibRolesStorage.rolesStorage().owner, "ComplianceInternal: Not owner");
    }
}
