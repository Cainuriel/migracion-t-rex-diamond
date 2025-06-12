# AppStorage Documentation

## Overview

`AppStorage` defines the **complete data model** for the T-REX security token system within the Diamond Pattern architecture. This central storage structure contains all application state, providing a comprehensive foundation for token functionality, compliance management, identity verification, and governance operations.

## Architecture & Purpose

### Primary Responsibilities
- **Unified Data Model**: Single source of truth for all application state
- **Cross-Facet Coordination**: Shared data structure accessible by all facets
- **Type Safety**: Strongly typed data structures with compiler validation
- **Upgrade Compatibility**: Structured layout supporting safe storage evolution
- **Performance Optimization**: Efficient storage layout for gas optimization

### Design Principles
The AppStorage structure follows key design principles:
- **Modularity**: Logically grouped data components
- **Extensibility**: Layout supports future feature additions
- **Clarity**: Self-documenting structure with clear field purposes
- **Efficiency**: Optimized for common access patterns
- **Safety**: Type-safe operations with Solidity compiler validation

## Core Data Structures

### Investor Structure
```solidity
struct Investor {
    address identity;    // OnChain-ID identity contract address
    uint16 country;     // ISO 3166-1 numeric country code
    bool isFrozen;      // Account freeze status for compliance
}
```

**Field Details**:
- **`identity`**: Links to investor's OnChain-ID contract for KYC/AML verification
- **`country`**: Nationality/residency for regulatory compliance and restrictions
- **`isFrozen`**: Administrative freeze capability for compliance enforcement

**Usage Examples**:
- **Identity Verification**: `s.investors[user].identity != address(0)`
- **Geographic Restrictions**: `s.investors[user].country != restrictedCountry`
- **Compliance Enforcement**: `!s.investors[user].isFrozen`

### Compliance Structure
```solidity
struct Compliance {
    uint256 maxBalance;    // Maximum tokens per investor
    uint256 minBalance;    // Minimum investment threshold
    uint256 maxInvestors;  // Maximum number of token holders
}
```

**Field Details**:
- **`maxBalance`**: Prevents concentration risk and regulatory violations
- **`minBalance`**: Enforces minimum investment requirements
- **`maxInvestors`**: Supports regulatory limits (e.g., Rule 506(b) - 35 investors)

**Configuration Examples**:
- **Concentration Limit**: `maxBalance = totalSupply * 10 / 100` (10% max holding)
- **Qualified Investor**: `minBalance = 1000000 * 10**18` ($1M minimum)
- **Private Placement**: `maxInvestors = 35` (Rule 506(b) limit)

## Complete Storage Layout

### AppStorage Structure
```solidity
struct AppStorage {
    // Investor Management
    mapping(address => Investor) investors;              // Investor registry
    address[] holders;                                   // Active token holders list
    
    // Token Core Functionality  
    mapping(address => uint256) balances;                // ERC-20 token balances
    mapping(address => mapping(address => uint256)) allowances; // ERC-20 allowances
    uint256 totalSupply;                                 // Total token supply
    string name;                                         // Token name
    string symbol;                                       // Token symbol
    uint8 decimals;                                      // Token decimals (usually 18)
    
    // Governance & Access Control
    address owner;                                       // Contract owner
    mapping(address => bool) agents;                     // Authorized operational agents
    
    // Compliance Framework
    Compliance compliance;                               // Compliance rules and limits
    address[] complianceModules;                         // External compliance modules
    
    // Identity & Verification System
    uint256[] claimTopics;                              // Required identity claim topics
    mapping(uint256 => address[]) trustedIssuers;       // Trusted issuers per claim topic
}
```

## Data Relationships & Integration

### Token Economics
```
totalSupply = Σ(balances[holder]) for all holders
holders[] = {addresses where balances[address] > 0}
allowances[owner][spender] = approved spending amount
```

### Identity Verification Chain
```
claimTopics[] → defines required verification types
trustedIssuers[topic] → authorized verifiers for each topic
investors[address].identity → links to OnChain-ID contract
OnChain-ID contract → contains verified claims from trusted issuers
```

### Compliance Enforcement
```
compliance.maxBalance → enforced in transfer validation
compliance.minBalance → enforced in transfer validation  
compliance.maxInvestors → enforced against holders.length
investors[address].isFrozen → prevents all transfers
```

### Access Control Hierarchy
```
owner → ultimate authority (compliance rules, agents, upgrades)
agents[address] → operational authority (identity, freezing, minting)
users → standard token operations (transfer, approve)
```

## Storage Usage Patterns

### Token Operations
```solidity
// Balance management
s.balances[from] -= amount;
s.balances[to] += amount;
s.totalSupply += mintedAmount;

// Allowance management
s.allowances[owner][spender] = allowedAmount;
uint256 remaining = s.allowances[owner][spender];
```

### Identity Management
```solidity
// Investor registration
s.investors[investorAddress] = Investor({
    identity: onChainIdAddress,
    country: countryCode,
    isFrozen: false
});

// Identity verification
address identityContract = s.investors[user].identity;
bool isRegistered = identityContract != address(0);
```

### Compliance Operations
```solidity
// Balance limit checking
uint256 newBalance = s.balances[to] + amount;
bool withinLimits = s.compliance.maxBalance == 0 || 
                   newBalance <= s.compliance.maxBalance;

// Investor count validation
bool belowLimit = s.compliance.maxInvestors == 0 || 
                 s.holders.length < s.compliance.maxInvestors;
```

### Claim Topic Management
```solidity
// Required verification topics
s.claimTopics.push(kycClaimTopic);
s.claimTopics.push(amlClaimTopic);

// Trusted issuer management
s.trustedIssuers[kycTopic].push(trustedKycProvider);
address[] memory kycIssuers = s.trustedIssuers[kycTopic];
```

## Storage Optimization Strategies

### Gas-Efficient Access
```solidity
// ✅ Good: Single storage access with caching
function optimizedFunction() external {
    AppStorage storage s = LibAppStorage.diamondStorage();
    uint256 userBalance = s.balances[msg.sender];
    Investor memory investor = s.investors[msg.sender];
    
    // Work with cached values
    require(userBalance >= amount, "Insufficient balance");
    require(!investor.isFrozen, "Account frozen");
}

// ❌ Bad: Multiple storage accesses
function inefficientFunction() external {
    require(LibAppStorage.diamondStorage().balances[msg.sender] >= amount, "Insufficient");
    require(!LibAppStorage.diamondStorage().investors[msg.sender].isFrozen, "Frozen");
}
```

### Batch Operations
```solidity
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
    AppStorage storage s = LibAppStorage.diamondStorage();
    uint256 senderBalance = s.balances[msg.sender];
    
    for (uint i = 0; i < recipients.length; i++) {
        require(senderBalance >= amounts[i], "Insufficient balance");
        s.balances[msg.sender] -= amounts[i];
        s.balances[recipients[i]] += amounts[i];
        senderBalance -= amounts[i];
    }
}
```

### Struct Memory Optimization
```solidity
// Load struct to memory for multiple field access
Investor memory investor = s.investors[userAddress];
if (investor.identity != address(0) && !investor.isFrozen) {
    // Process verification with investor data
}
```

## Storage Evolution & Upgrades

### Safe Storage Expansion
```solidity
struct AppStorage {
    // ✅ NEVER CHANGE: Existing fields in original order
    mapping(address => Investor) investors;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    Compliance compliance;
    address owner;
    mapping(address => bool) agents;
    address[] complianceModules;
    uint256[] claimTopics;
    mapping(uint256 => address[]) trustedIssuers;
    address[] holders;
    
    // ✅ SAFE: New fields added at end
    uint256 newFeatureFlag;
    mapping(address => NewStruct) newMapping;
    address[] newArray;
}
```

### Storage Layout Rules
1. **Never Reorder**: Existing fields must maintain their positions
2. **Never Change Types**: Field types must remain unchanged
3. **Never Remove**: Old fields should be deprecated, not removed
4. **Add at End**: New fields only added at structure end
5. **Document Changes**: Maintain version history of schema changes

### Upgrade Considerations
- **Default Values**: New fields start with Solidity default values
- **Initialization**: Use initialization functions for non-default setup
- **Migration Logic**: Handle data migration in initialization contracts
- **Backward Compatibility**: Ensure old versions can read new storage

## Data Integrity & Validation

### Invariant Checks
```solidity
// Total supply consistency
uint256 calculatedSupply = 0;
for (uint i = 0; i < s.holders.length; i++) {
    calculatedSupply += s.balances[s.holders[i]];
}
assert(calculatedSupply == s.totalSupply);

// Holder list accuracy
for (uint i = 0; i < s.holders.length; i++) {
    assert(s.balances[s.holders[i]] > 0);
}
```

### Cross-Field Validation
```solidity
// Compliance rule validation
if (s.compliance.maxBalance > 0) {
    assert(s.compliance.maxBalance <= s.totalSupply);
}

// Identity registration validation
for (uint i = 0; i < s.holders.length; i++) {
    address holder = s.holders[i];
    if (s.balances[holder] > 0) {
        assert(s.investors[holder].identity != address(0));
    }
}
```

## Security Considerations

### Access Control Validation
```solidity
// Owner verification
require(msg.sender == s.owner, "Not owner");

// Agent verification  
require(s.owner == msg.sender || s.agents[msg.sender], "Not authorized");

// Identity verification
require(s.investors[user].identity != address(0), "Not registered");
```

### State Consistency
- **Atomic Updates**: Related fields updated in same transaction
- **Validation Logic**: Ensure data consistency across operations
- **Error Recovery**: Failed operations don't leave inconsistent state
- **Access Patterns**: Controlled access through defined interfaces

### Data Privacy
- **Minimal Storage**: Only essential data stored on-chain
- **Identity References**: Store addresses, not personal data
- **Compliance Data**: Only regulatory-required information
- **External Storage**: Personal data in OnChain-ID contracts

## Testing & Debugging

### Storage State Inspection
```solidity
function getStorageSnapshot() external view returns (
    uint256 totalSupply,
    uint256 holderCount,
    uint256 claimTopicCount,
    address owner,
    Compliance memory compliance
) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    return (
        s.totalSupply,
        s.holders.length,
        s.claimTopics.length,
        s.owner,
        s.compliance
    );
}
```

### Validation Functions
```solidity
function validateInvariants() external view returns (bool) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    
    // Check supply consistency
    uint256 totalBalances = 0;
    for (uint i = 0; i < s.holders.length; i++) {
        totalBalances += s.balances[s.holders[i]];
    }
    
    return totalBalances == s.totalSupply;
}
```

## Best Practices

### 1. Storage Design
- **Plan for Growth**: Design storage schema for future expansion
- **Document Structure**: Maintain clear documentation of field purposes
- **Version Control**: Track all schema changes with version numbers
- **Test Thoroughly**: Validate storage operations across all scenarios

### 2. Data Management
- **Consistent Updates**: Keep related data fields synchronized
- **Validation Logic**: Implement data consistency checks
- **Error Handling**: Graceful handling of invalid data states
- **Performance Monitoring**: Track gas usage for storage operations

### 3. Upgrade Planning
- **Migration Strategy**: Plan data migration for storage updates
- **Backward Compatibility**: Ensure smooth upgrade transitions
- **Testing Protocol**: Comprehensive testing of storage changes
- **Rollback Capability**: Maintain ability to revert problematic changes

## Common Patterns & Anti-Patterns

### ✅ Recommended Patterns
```solidity
// Single storage access with struct caching
Investor memory investor = s.investors[user];
if (investor.identity != address(0) && !investor.isFrozen) {
    // Process with cached data
}

// Batch operations for efficiency
for (uint i = 0; i < users.length; i++) {
    s.balances[users[i]] += amounts[i];
}
```

### ❌ Anti-Patterns to Avoid
```solidity
// Multiple storage reads
if (s.investors[user].identity != address(0) && 
    !s.investors[user].isFrozen && 
    s.investors[user].country != restrictedCountry) {
    // Inefficient: multiple storage reads
}

// Storage layout modifications
struct AppStorage {
    uint256 newField;  // ❌ Never add fields at beginning
    string name;       // ❌ This breaks existing storage
}
```

AppStorage provides the comprehensive data foundation for the T-REX security token system, enabling sophisticated compliance, identity management, and governance features while maintaining upgrade safety and operational efficiency.
