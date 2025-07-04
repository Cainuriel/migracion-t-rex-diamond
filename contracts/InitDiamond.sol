// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { LibDiamond } from "./libraries/LibDiamond.sol";

/// @title InitDiamond - Initialization for new modular storage architecture
/// @dev Initializes all separated storage domains with consistent data
contract InitDiamond is Initializable {
    
    event DiamondInitialized(address indexed owner, string name, string symbol);

    // ================== STORAGE STRUCTURES ==================

    /// @title TokenStorage - Unstructured storage for Token domain
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

    /// @title RolesStorage - Unstructured storage for Roles domain
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }

    /// @title IdentityStorage - Unstructured storage for Identity domain
    struct IdentityStorage {
        // === IDENTITY MAPPING ===
        mapping(address => address) investorIdentities; // investor => identity contract
        mapping(address => uint16) investorCountries; // investor => country code
        mapping(address => bool) verificationStatus; // investor => verified
    }

    /// @title ComplianceStorage - Unstructured storage for Compliance domain
    struct ComplianceStorage {
        // === COMPLIANCE RULES ===
        uint256 maxBalance; // 0 = no limit
        uint256 minBalance; // minimum balance required
        uint256 maxInvestors; // 0 = no limit
        uint256 currentInvestorCount;
        
        // === TRANSFER VALIDATION ===
        mapping(address => uint256) lastTransferTime;
        mapping(address => bool) frozenInvestors;
    }

    /// @title ClaimTopicsStorage - Unstructured storage for ClaimTopics domain
    struct ClaimTopicsStorage {
        // === CLAIM TOPICS ===
        uint256[] claimTopics; // array of required claim topics
        mapping(uint256 => bool) requiredClaimTopics; // topic => required
    }

    /// @title TrustedIssuersStorage - Unstructured storage for TrustedIssuers domain
    struct TrustedIssuersStorage {
        // === TRUSTED ISSUERS ===
        mapping(uint256 => address[]) trustedIssuers; // claimTopic => issuer addresses
        mapping(address => mapping(uint256 => bool)) issuerStatus; // issuer => claimTopic => trusted
        mapping(uint256 => uint256) issuerCount; // claimTopic => count of trusted issuers
    }

    // ================== STORAGE ACCESS ==================

    /// @dev Storage slots for different domains
    bytes32 private constant TOKEN_STORAGE_POSITION = keccak256("t-rex.diamond.token.storage");
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");
    bytes32 private constant IDENTITY_STORAGE_POSITION = keccak256("t-rex.diamond.identity.storage");
    bytes32 private constant COMPLIANCE_STORAGE_POSITION = keccak256("t-rex.diamond.compliance.storage");
    bytes32 private constant CLAIM_TOPICS_STORAGE_POSITION = keccak256("t-rex.diamond.claim-topics.storage");
    bytes32 private constant TRUSTED_ISSUERS_STORAGE_POSITION = keccak256("t-rex.diamond.trusted-issuers.storage");

    /// @notice Get Token storage reference
    function _getTokenStorage() private pure returns (TokenStorage storage ts) {
        bytes32 position = TOKEN_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    /// @notice Get Roles storage reference
    function _getRolesStorage() private pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }

    /// @notice Get Identity storage reference
    function _getIdentityStorage() private pure returns (IdentityStorage storage ids) {
        bytes32 position = IDENTITY_STORAGE_POSITION;
        assembly {
            ids.slot := position
        }
    }

    /// @notice Get Compliance storage reference
    function _getComplianceStorage() private pure returns (ComplianceStorage storage cs) {
        bytes32 position = COMPLIANCE_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    /// @notice Get ClaimTopics storage reference
    function _getClaimTopicsStorage() private pure returns (ClaimTopicsStorage storage cts) {
        bytes32 position = CLAIM_TOPICS_STORAGE_POSITION;
        assembly {
            cts.slot := position
        }
    }

    /// @notice Get TrustedIssuers storage reference
    function _getTrustedIssuersStorage() private pure returns (TrustedIssuersStorage storage tis) {
        bytes32 position = TRUSTED_ISSUERS_STORAGE_POSITION;
        assembly {
            tis.slot := position
        }
    }
    
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
        _getRolesStorage().owner = owner;
        // agents mapping starts empty
    }
    
    /// @dev Initialize token storage with metadata
    function _initializeToken(string memory name, string memory symbol) private {
        TokenStorage storage ts = _getTokenStorage();
        ts.name = name;
        ts.symbol = symbol;
        ts.decimals = 18;
        ts.totalSupply = 0;
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
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.maxBalance = 0; // 0 = no limit
        cs.minBalance = 0; // 0 = no minimum
        cs.maxInvestors = 0; // 0 = no limit
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
        roles = _getRolesStorage().owner != address(0);
        token = bytes(_getTokenStorage().name).length > 0;
    }
}
