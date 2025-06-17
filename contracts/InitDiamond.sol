// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { LibDiamond } from "./libraries/LibDiamond.sol";
import { LibTokenStorage } from "./storage/TokenStorage.sol";
import { LibRolesStorage } from "./storage/RolesStorage.sol";
import { LibIdentityStorage } from "./storage/IdentityStorage.sol";
import { LibComplianceStorage } from "./storage/ComplianceStorage.sol";
import { LibClaimTopicsStorage } from "./storage/ClaimTopicsStorage.sol";
import { LibTrustedIssuersStorage } from "./storage/TrustedIssuersStorage.sol";

/// @title InitDiamonD - Initialization for new modular storage architecture
/// @dev Initializes all separated storage domains with consistent data
contract InitDiamond is Initializable {
    
    event DiamondInitialized(address indexed owner, string name, string symbol);
    
    /// @notice Initialize all storage domains with consistent initial state
    /// @param owner Initial owner address
    /// @param name Token name
    /// @param symbol Token symbol
    function init(
        address owner,
        string memory name,
        string memory symbol
    ) external initializer {
        require(owner != address(0), "InitDiamond: owner cannot be zero address");
        
        // Initialize Roles Storage
        _initializeRoles(owner);
        
        // Initialize Token Storage
        _initializeToken(name, symbol);
        
        // Initialize Identity Storage (no initial data needed)
        _initializeIdentity();
        
        // Initialize Compliance Storage (set default rules)
        _initializeCompliance();
        
        // Initialize ClaimTopics Storage (empty initially)
        _initializeClaimTopics();
        
        // Initialize TrustedIssuers Storage (empty initially)
        _initializeTrustedIssuers();
        
        emit DiamondInitialized(owner, name, symbol);
    }
    
    /// @dev Initialize roles storage with owner
    function _initializeRoles(address owner) private {
        LibRolesStorage.rolesStorage().owner = owner;
        // agents mapping starts empty
    }
    
    /// @dev Initialize token storage with metadata
    function _initializeToken(string memory name, string memory symbol) private {
        LibTokenStorage.tokenStorage().name = name;
        LibTokenStorage.tokenStorage().symbol = symbol;
        LibTokenStorage.tokenStorage().decimals = 18;
        LibTokenStorage.tokenStorage().totalSupply = 0;
        // balances and allowances mappings start empty
        // holders array starts empty
    }
    
    /// @dev Initialize identity storage (starts empty)
    function _initializeIdentity() private {
        // All mappings start empty - no initialization needed
        // investorIdentities, investorCountries, verificationStatus all start empty
    }
    
    /// @dev Initialize compliance storage with default rules (no limits)
    function _initializeCompliance() private {
        LibComplianceStorage.complianceStorage().maxBalance = 0; // 0 = no limit
        LibComplianceStorage.complianceStorage().minBalance = 0; // 0 = no minimum
        LibComplianceStorage.complianceStorage().maxInvestors = 0; // 0 = no limit
    }
    
    /// @dev Initialize claim topics storage (starts empty)
    function _initializeClaimTopics() private {
        // claimTopics array starts empty
        // requiredClaimTopics mapping starts empty
    }
    
    /// @dev Initialize trusted issuers storage (starts empty)
    function _initializeTrustedIssuers() private {
        // trustedIssuers mapping starts empty
    }
    
    /// @notice Get initialization status for all storage domains
    /// @return roles True if roles are initialized
    /// @return token True if token is initialized
    function getInitializationStatus() external view returns (
        bool roles,
        bool token
    ) {
        roles = LibRolesStorage.rolesStorage().owner != address(0);
        token = bytes(LibTokenStorage.tokenStorage().name).length > 0;
    }
}
