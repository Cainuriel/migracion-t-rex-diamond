// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IComplianceEvents } from "../../interfaces/events/IComplianceEvents.sol";

/// @title ComplianceInternalFacet - Internal business logic for Compliance domain
/// @dev Contains all the business logic for compliance checks and rules
/// @dev This facet is not directly exposed in the diamond interface
contract ComplianceInternalFacet is IComplianceEvents {

    // ================== STORAGE STRUCTURES ==================

    /// @title ComplianceStorage - Unstructured storage for Compliance domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct ComplianceStorage {
        // === COMPLIANCE LIMITS ===
        uint256 maxBalance;
        uint256 minBalance;
        uint256 maxInvestors;
        
        // === COMPLIANCE MODULES ===
        address[] complianceModules;
        mapping(address => bool) moduleStatus;
        
        // === INVESTOR COUNT ===
        uint256 currentInvestorCount;
    }

    /// @title TokenStorage - Unstructured storage for Token domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct TokenStorage {
        // === TOKEN CORE ERC20 ===
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
        
        // === TOKEN ERC-3643 EXTENSIONS ===
        mapping(address => bool) frozenAccounts;
        address[] holders; // Track all token holders for compliance
    }

    /// @title IdentityStorage - Unstructured storage for Identity domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct IdentityStorage {
        // === IDENTITY DATA ===
        mapping(address => address) investorIdentities;
        mapping(address => uint16) investorCountries;
        mapping(address => bool) verificationStatus;
    }

    /// @title RolesStorage - Unstructured storage for Roles domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }

    // ================== STORAGE ACCESS ==================

    /// @dev Storage slot for Compliance domain
    bytes32 private constant COMPLIANCE_STORAGE_POSITION = keccak256("t-rex.diamond.compliance.storage");
    
    /// @dev Storage slot for Token domain
    bytes32 private constant TOKEN_STORAGE_POSITION = keccak256("t-rex.diamond.token.storage");
    
    /// @dev Storage slot for Identity domain
    bytes32 private constant IDENTITY_STORAGE_POSITION = keccak256("t-rex.diamond.identity.storage");
    
    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get Compliance storage reference
    /// @return cs Compliance storage struct
    function _getComplianceStorage() private pure returns (ComplianceStorage storage cs) {
        bytes32 position = COMPLIANCE_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    /// @notice Get Token storage reference
    /// @return ts Token storage struct
    function _getTokenStorage() private pure returns (TokenStorage storage ts) {
        bytes32 position = TOKEN_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    /// @notice Get Identity storage reference
    /// @return ids Identity storage struct
    function _getIdentityStorage() private pure returns (IdentityStorage storage ids) {
        bytes32 position = IDENTITY_STORAGE_POSITION;
        assembly {
            ids.slot := position
        }
    }

    /// @notice Get Roles storage reference
    /// @return rs Roles storage struct
    function _getRolesStorage() private pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }

    // ================== INTERNAL COMPLIANCE OPERATIONS ==================

    /// @notice Internal function to set maximum balance limit
    /// @param max Maximum balance allowed per investor
    function _setMaxBalance(uint256 max) internal {
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.maxBalance = max;
        emit MaxBalanceSet(max);
    }

    /// @notice Internal function to set minimum balance limit
    /// @param min Minimum balance required per investor
    function _setMinBalance(uint256 min) internal {
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.minBalance = min;
        emit MinBalanceSet(min);
    }

    /// @notice Internal function to set maximum number of investors
    /// @param max Maximum number of investors allowed
    function _setMaxInvestors(uint256 max) internal {
        ComplianceStorage storage cs = _getComplianceStorage();
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
        TokenStorage storage ts = _getTokenStorage();
        if (ts.frozenAccounts[from] || ts.frozenAccounts[to]) {
            return false;
        }

        // Check if recipient has valid identity
        IdentityStorage storage ids = _getIdentityStorage();
        if (ids.investorIdentities[to] == address(0)) {
            return false;
        }

        ComplianceStorage storage cs = _getComplianceStorage();
        uint256 currentBalance = ts.balances[to];
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
        ComplianceStorage storage cs = _getComplianceStorage();
        return (cs.maxBalance, cs.minBalance, cs.maxInvestors);
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @notice Count active investors (those with non-zero balance)
    /// @return Number of active investors
    function _countActiveInvestors() private view returns (uint256) {
        TokenStorage storage ts = _getTokenStorage();
        address[] memory holders = ts.holders;
        uint256 count = 0;
        
        for (uint256 i = 0; i < holders.length; i++) {
            if (ts.balances[holders[i]] > 0) {
                count++;
            }
        }
        
        return count;
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == _getRolesStorage().owner, "ComplianceInternal: Not owner");
    }

    /// @notice Internal check for agent or owner authorization
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        RolesStorage storage rs = _getRolesStorage();
        require(caller == rs.owner || rs.agents[caller], "ComplianceInternal: Not authorized");
    }
}
