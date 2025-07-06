# T-REX Diamond Architecture - ERC-3643 Implementation

## Overview

This document explains the complete architecture of our **T-REX Diamond** implementation, which provides a modular, upgradeable version of the **ERC-3643** security token standard using the **Diamond Pattern (EIP-2535)**.

## What is ERC-3643?

**ERC-3643** (also known as **T-REX**) is a standard for **security tokens** that enforces regulatory compliance at the smart contract level. It extends ERC-20 with:

- **Identity Verification**: Integration with OnChain-ID for KYC/AML
- **Compliance Engine**: Automated regulatory rule enforcement
- **Transfer Restrictions**: Sophisticated pre-transfer validation
- **Trusted Issuers**: Certified identity verification providers
- **Claim Topics**: Configurable verification requirements

## Why Diamond Architecture?

Traditional ERC-3643 implementations face several limitations:

### ❌ **Traditional Problems**
- **24KB Contract Size Limit**: Complex compliance logic exceeds Ethereum's contract size limit
- **Monolithic Storage**: Difficult to upgrade without data migration
- **Rigid Structure**: Hard to add new compliance modules
- **Gas Inefficiency**: Large contracts with high deployment costs

### ✅ **Diamond Solution**
- **Unlimited Size**: Functionality split across multiple facets
- **Modular Upgrades**: Update individual components without affecting others
- **Storage Isolation**: Each domain manages its own data
- **Gas Optimization**: Deploy and upgrade only what's needed

## Core Architecture Principles

### 1. **Diamond Pattern (EIP-2535)**

```
┌─────────────────────────────────────────────────┐
│                 DIAMOND PROXY                   │
│            (Single Contract Address)            │
├─────────────────────────────────────────────────┤
│                FUNCTION ROUTING                 │
│         (Selector → Facet Mapping)              │
└─────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐       ┌─────▼─────┐      ┌────▼────┐
   │ Token   │       │   Roles   │      │Identity │
   │ Facet   │       │   Facet   │      │ Facet   │
   └─────────┘       └───────────┘      └─────────┘
        │                  │                  │
   ┌────▼────┐       ┌─────▼─────┐      ┌────▼────┐
   │Compliance│       │ClaimTopics│      │Trusted  │
   │ Facet   │       │  Facet    │      │Issuers  │
   └─────────┘       └───────────┘      └─────────┘
```

**Key Benefits:**
- **Single Address**: Users interact with one contract address
- **Function Routing**: Calls automatically routed to appropriate facet
- **Unlimited Functionality**: No size limits on total system
- **Selective Upgrades**: Update individual facets without affecting others

### 2. **Dual Facet Architecture**

We implement a **Internal/External** facet separation pattern:

#### **External Facets** (Public Interface)
- **Purpose**: Provide clean, user-facing APIs
- **Responsibility**: Input validation, access control, event emission
- **Audience**: End users, wallets, exchanges, dApps

#### **Internal Facets** (Business Logic)
- **Purpose**: Implement core business logic and storage management
- **Responsibility**: Complex logic, data manipulation, cross-domain operations
- **Audience**: Other facets within the system

```
┌─────────────────┐    ┌─────────────────┐
│   TokenFacet    │────│TokenInternalFacet│
│   (External)    │    │   (Internal)     │
├─────────────────┤    ├─────────────────┤
│ • mint()        │    │ • _mint()        │
│ • transfer()    │    │ • _transfer()    │
│ • approve()     │    │ • _updateBalance()│
│ • Input validation   │ • Storage logic  │
│ • Access control     │ • Business rules │
│ • Events        │    │ • Cross-facet calls│
└─────────────────┘    └─────────────────┘
```

### 3. **Encapsulated Storage**

Each domain manages its own storage using **Diamond Storage** pattern:

```solidity
// Each Internal Facet defines its own storage
contract TokenInternalFacet {
    struct TokenStorage {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
        mapping(address => bool) frozenAccounts;
        address[] holders;
    }
    
    // Unique storage slot per domain
    bytes32 constant TOKEN_STORAGE_POSITION = keccak256("token.storage.location");
    
    function _getTokenStorage() internal pure returns (TokenStorage storage) {
        bytes32 position = TOKEN_STORAGE_POSITION;
        assembly { ts.slot := position }
        return ts;
    }
}
```

**Benefits:**
- **Isolation**: Each domain's data is completely separate
- **Upgradeability**: Storage layout preserved across upgrades
- **Extensibility**: Easy to add new fields without affecting other domains
- **Gas Efficiency**: Direct storage access without complex mappings

## System Components

### Core ERC-3643 Facets

#### 1. **Token System** (ERC-20 + ERC-3643 Core)
- **TokenFacet**: Public ERC-20 interface
- **TokenInternalFacet**: Balance management, transfer logic, compliance integration

#### 2. **Identity System** (OnChain-ID Integration)
- **IdentityFacet**: Identity registration and verification
- **IdentityInternalFacet**: Identity storage, claim validation

#### 3. **Compliance Engine** (Regulatory Rules)
- **ComplianceFacet**: Rule configuration and queries
- **ComplianceInternalFacet**: Transfer validation, rule enforcement

#### 4. **Roles & Permissions**
- **RolesFacet**: Agent management, permission queries
- **RolesInternalFacet**: Access control logic, role storage

#### 5. **Claim Topics** (KYC/AML Types)
- **ClaimTopicsFacet**: Required verification types management
- **ClaimTopicsInternalFacet**: Topic storage and validation

#### 6. **Trusted Issuers** (Certification Providers)
- **TrustedIssuersFacet**: Issuer management
- **TrustedIssuersInternalFacet**: Issuer validation and storage

### Diamond Infrastructure

#### 7. **Diamond Core**
- **Diamond**: Main proxy contract
- **DiamondCutFacet**: Upgrade mechanism
- **InitDiamond**: Initialization logic
- **LibDiamond**: Core diamond utilities

## Data Flow Architecture

### Token Transfer Flow
```
User calls transfer()
        │
        ▼
1. TokenFacet.transfer()
   • Input validation
   • Access control
   • Event emission
        │
        ▼
2. TokenInternalFacet._transfer()
   • Balance checks
   • Compliance validation
   • Storage updates
        │
        ▼
3. ComplianceInternalFacet.validateTransfer()
   • Regulatory rules
   • Identity verification
   • Restrictions check
        │
        ▼
4. IdentityInternalFacet.isVerified()
   • KYC/AML validation
   • Claim verification
   • Issuer trust check
        │
        ▼
5. Transfer completed or reverted
```

### Storage Isolation
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Token     │  │ Compliance  │  │  Identity   │
│  Storage    │  │  Storage    │  │  Storage    │
│             │  │             │  │             │
│ • balances  │  │ • maxBalance│  │ • identities│
│ • supply    │  │ • minBalance│  │ • countries │
│ • holders   │  │ • maxInvest │  │ • frozen    │
└─────────────┘  └─────────────┘  └─────────────┘
       │                │                │
       └────────────────┼────────────────┘
                        │
                ┌─────────────┐
                │   Diamond   │
                │   Storage   │
                │             │
                │ • facets    │
                │ • selectors │
                │ • owner     │
                └─────────────┘
```

## Implementation Details

### Custom Error System
We've migrated from `require` statements to custom errors for better UX and gas efficiency:

```solidity
// Instead of: require(amount > 0, "Amount must be greater than zero");
if (amount == 0) revert ZeroAmount();

// Instead of: require(to != address(0), "Cannot transfer to zero address");
if (to == address(0)) revert ZeroAddress();
```

### Access Control Pattern
```solidity
// Role-based access control across all facets
modifier onlyAgent() {
    RolesStorage.Layout storage rs = _getRolesStorage();
    if (!rs.agents[msg.sender]) revert Unauthorized(msg.sender);
    _;
}

modifier onlyOwner() {
    if (msg.sender != LibDiamond.contractOwner()) revert Unauthorized(msg.sender);
    _;
}
```

### Cross-Facet Communication
```solidity
// Internal facets can call each other directly
contract TokenInternalFacet {
    function _transfer(address from, address to, uint256 amount) internal {
        // Validate compliance before transfer
        ComplianceInternalFacet compliance = ComplianceInternalFacet(address(this));
        if (!compliance._validateTransfer(from, to, amount)) {
            revert ComplianceViolation(from, to, amount);
        }
        
        // Update balances
        _updateBalances(from, to, amount);
    }
}
```

## Security Considerations

### 1. **Storage Collision Prevention**
- Each facet uses unique storage slots
- Diamond storage pattern prevents conflicts
- Deterministic slot calculation

### 2. **Access Control**
- Owner-only administrative functions
- Agent-based operational permissions
- Function-level access restrictions

### 3. **Upgrade Safety**
- Storage layout preservation
- Function selector management
- Initialization protection

### 4. **Custom Error Validation**
- Input validation with custom errors
- Business rule enforcement
- Regulatory compliance checks

## Gas Optimization

### 1. **Storage Efficiency**
- Direct storage access
- Minimal cross-facet calls
- Optimized data structures

### 2. **Deployment Optimization**
- Modular deployment
- Selective upgrades
- Incremental functionality

### 3. **Runtime Efficiency**
- Custom errors (vs require strings)
- Efficient routing
- Minimal external calls

## Current Implementation Status

### ✅ **Completed Features**
- **ERC-20 Core**: Complete token functionality
- **Basic Compliance**: Balance limits, investor caps
- **Role Management**: Owner/agent system
- **Identity Framework**: Basic OnChain-ID integration
- **Diamond Infrastructure**: Full EIP-2535 compliance
- **Custom Errors**: Migration from require statements

### 🔄 **Partial Implementation**
- **Claim Verification**: Basic claim topics (KYC, AML)
- **Trusted Issuers**: Basic issuer management
- **Transfer Restrictions**: Simple compliance rules

### ❌ **Future Roadmap**
- **Advanced Compliance**: Complex regulatory modules
- **Full OnChain-ID**: Complete claim verification system
- **Multi-Jurisdiction**: Country-specific rules
- **Advanced Claims**: Sophisticated verification flows

## Comparison with Standard ERC-3643

| Feature | Standard ERC-3643 | Our Implementation | Status |
|---------|------------------|-------------------|---------|
| ERC-20 Base | ✅ | ✅ | Complete |
| Identity Integration | ✅ | ⚠️ | Basic |
| Compliance Engine | ✅ | ⚠️ | Simplified |
| Transfer Restrictions | ✅ | ⚠️ | Basic |
| Upgradeability | ❌ | ✅ | Enhanced |
| Modularity | ⚠️ | ✅ | Greatly Improved |
| Gas Efficiency | ⚠️ | ✅ | Optimized |

## Benefits of Our Architecture

### For Developers
- **Modular Development**: Work on individual components
- **Easy Testing**: Test facets in isolation
- **Clear Separation**: Understand boundaries between components
- **Upgrade Flexibility**: Update parts without affecting the whole

### For Users
- **Single Interface**: Interact through one contract address
- **Better Error Messages**: Custom errors provide clear feedback
- **Gas Efficiency**: Optimized operations reduce costs
- **Future-Proof**: Upgradeable without losing state

### For Regulators
- **Transparency**: Clear compliance rules and enforcement
- **Auditability**: Separate components for easier review
- **Flexibility**: Adapt to changing regulations
- **Traceability**: Complete audit trail of operations

## Next Steps

This architecture provides a solid foundation for:

1. **Completing ERC-3643**: Adding remaining compliance features
2. **Advanced Identity**: Full OnChain-ID integration
3. **Regulatory Modules**: Jurisdiction-specific compliance
4. **Performance Optimization**: Further gas improvements
5. **Security Audits**: Professional security review

The Diamond architecture ensures that all future enhancements can be added without disrupting existing functionality or requiring data migrations.
