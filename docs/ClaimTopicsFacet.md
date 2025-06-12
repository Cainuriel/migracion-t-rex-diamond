# ClaimTopicsFacet Documentation

## Overview

The `ClaimTopicsFacet` manages the **required identity claim topics** for the T-REX security token system. This facet defines which types of identity claims investors must possess to participate in the token ecosystem, providing the foundation for configurable KYC/AML compliance requirements.

## Architecture & Purpose

### Primary Responsibilities
- **Claim Topic Management**: Add, remove, and query required claim types
- **Compliance Configuration**: Define identity verification requirements
- **Regulatory Flexibility**: Support various regulatory frameworks through configurable topics
- **Integration Foundation**: Provide claim topics for IdentityFacet verification
- **Administrative Control**: Owner-only management of compliance requirements

### Claim Topic System
Claim topics are **numeric identifiers** that represent different types of identity verification:
- **Standard Topics**: Based on ERC-735 and OnChain-ID specifications
- **Regulatory Alignment**: Support jurisdiction-specific requirements
- **Extensible Design**: New claim types can be added as regulations evolve
- **Multi-Topic Support**: Multiple claims can be required simultaneously

## Storage Integration

Uses `AppStorage.claimTopics` array:
```solidity
struct AppStorage {
    uint256[] claimTopics;  // Array of required claim topic IDs
    // ... other storage fields
}
```

The claim topics integrate with:
- **IdentityFacet**: Uses topics for verification logic
- **TrustedIssuersFacet**: Associates issuers with specific topics
- **Investor Verification**: Determines what claims are required

## Key Functions

### Administrative Functions (Owner Only)

#### Add Claim Topic
```solidity
function addClaimTopic(uint256 topic) external onlyOwner
```
- **Purpose**: Add a new required claim topic
- **Validation**: Prevents duplicate topic addition
- **Process**: Iterates through existing topics to check for duplicates
- **Event**: Emits `ClaimTopicAdded(topic)`
- **Usage**: Configure new compliance requirements

#### Remove Claim Topic
```solidity
function removeClaimTopic(uint256 topic) external onlyOwner
```
- **Purpose**: Remove a claim topic requirement
- **Process**: 
  1. Locates topic in array
  2. Replaces with last element (gas optimization)
  3. Removes last element with `pop()`
- **Event**: Emits `ClaimTopicRemoved(topic)`
- **Usage**: Update compliance requirements as regulations change

### Query Functions

#### Get All Topics
```solidity
function getClaimTopics() external view returns (uint256[] memory)
```
- **Purpose**: Return all currently required claim topics
- **Usage**: Used by IdentityFacet for verification logic
- **Integration**: Enables external systems to query requirements
- **Transparency**: Public visibility of compliance requirements

## Standard Claim Topics

### Common OnChain-ID Topics
Based on ERC-735 and industry standards:

```solidity
// Identity Verification
uint256 constant KYC_CLAIM = 1;           // Know Your Customer
uint256 constant AML_CLAIM = 2;           // Anti-Money Laundering
uint256 constant ACCREDITATION_CLAIM = 3; // Accredited Investor Status

// Geographic & Regulatory
uint256 constant RESIDENCY_CLAIM = 10;    // Residency Verification
uint256 constant NATIONALITY_CLAIM = 11;  // Nationality Verification
uint256 constant TAX_RESIDENCY_CLAIM = 12; // Tax Residency Status

// Investment Qualifications
uint256 constant SOPHISTICATED_INVESTOR = 20; // Sophisticated Investor
uint256 constant PROFESSIONAL_INVESTOR = 21;  // Professional Investor
uint256 constant QUALIFIED_INVESTOR = 22;     // Qualified Investor

// Regulatory Compliance
uint256 constant FATCA_CLAIM = 30;        // FATCA Compliance
uint256 constant CRS_CLAIM = 31;          // Common Reporting Standard
uint256 constant MIFID_CLAIM = 32;        // MiFID II Compliance
```

### Custom Topics
Organizations can define custom claim topics:
```solidity
uint256 constant COMPANY_KYC = 1000;      // Corporate KYC
uint256 constant SANCTIONS_CHECK = 1001;  // Sanctions Screening
uint256 constant PEP_CHECK = 1002;        // Politically Exposed Person
```

## Events

```solidity
event ClaimTopicAdded(uint256 indexed topic);
event ClaimTopicRemoved(uint256 indexed topic);
```

### Event Usage
- **Compliance Tracking**: Monitor changes to verification requirements
- **System Integration**: Trigger updates in external systems
- **Audit Trail**: Provide regulatory audit trail of requirement changes
- **Notification**: Alert stakeholders to compliance changes

## Access Control

### Owner-Only Administration
- All modification functions restricted to contract owner
- Prevents unauthorized changes to compliance requirements
- Ensures only authorized parties can modify verification criteria
- Maintains regulatory compliance integrity

### Public Query Access
- `getClaimTopics()` is publicly accessible
- Enables transparency in compliance requirements
- Supports external system integration
- Allows investors to understand requirements

## Integration with T-REX System

### IdentityFacet Integration
The `isVerified()` function in IdentityFacet uses claim topics:
```solidity
function isVerified(address user) public view returns (bool) {
    AppStorage storage s = LibAppStorage.diamondStorage();
    
    // Check each required claim topic
    for (uint i = 0; i < s.claimTopics.length; i++) {
        uint256 topic = s.claimTopics[i];
        // Validate claim for this topic...
        if (!validClaim) return false;
    }
    return true;
}
```

### TrustedIssuersFacet Coordination
- Claim topics define what issuers are needed
- Each topic can have multiple trusted issuers
- Dynamic topic management affects issuer requirements
- Supports multi-issuer verification ecosystems

### ComplianceFacet Interaction
- Compliance rules may depend on specific claim types
- Identity verification is prerequisite for transfers
- Topic configuration affects overall compliance flow
- Regulatory requirements drive topic selection

## Operational Patterns

### 1. Initial Setup
```solidity
// Configure basic compliance requirements
claimTopicsFacet.addClaimTopic(1);  // KYC
claimTopicsFacet.addClaimTopic(2);  // AML
claimTopicsFacet.addClaimTopic(10); // Residency
```

### 2. Regulatory Updates
```solidity
// Add new regulatory requirement
claimTopicsFacet.addClaimTopic(32); // MiFID II compliance

// Remove outdated requirement
claimTopicsFacet.removeClaimTopic(99); // Deprecated claim type
```

### 3. Multi-Jurisdiction Support
```solidity
// US-specific requirements
claimTopicsFacet.addClaimTopic(30); // FATCA

// EU-specific requirements  
claimTopicsFacet.addClaimTopic(32); // MiFID II

// Global requirements
claimTopicsFacet.addClaimTopic(1);  // KYC
claimTopicsFacet.addClaimTopic(2);  // AML
```

## Regulatory Use Cases

### 1. Private Placement (Reg D)
```solidity
// US accredited investor requirements
claimTopicsFacet.addClaimTopic(1);  // KYC
claimTopicsFacet.addClaimTopic(3);  // Accreditation
claimTopicsFacet.addClaimTopic(30); // FATCA (if applicable)
```

### 2. EU MiFID II Compliance
```solidity
// European regulatory requirements
claimTopicsFacet.addClaimTopic(1);  // KYC
claimTopicsFacet.addClaimTopic(2);  // AML
claimTopicsFacet.addClaimTopic(32); // MiFID II
claimTopicsFacet.addClaimTopic(10); // EU Residency
```

### 3. Global Security Token
```solidity
// Multi-jurisdiction token requirements
claimTopicsFacet.addClaimTopic(1);  // Universal KYC
claimTopicsFacet.addClaimTopic(2);  // Universal AML
claimTopicsFacet.addClaimTopic(11); // Nationality verification
claimTopicsFacet.addClaimTopic(12); // Tax residency
```

## Gas Optimization Considerations

### Array Management
- **Duplicate Check**: O(n) iteration for duplicate prevention
- **Removal Optimization**: Swap-and-pop pattern for gas efficiency
- **Query Efficiency**: Single storage read for all topics

### Scaling Considerations
- Performance degradation with large topic arrays
- Consider max topic limits for gas management
- Monitor gas usage as topic count grows
- Alternative data structures for very large deployments

## Security Considerations

### Access Control
- Only owner can modify claim topics
- Prevents unauthorized compliance changes
- Maintains regulatory requirement integrity
- Clear audit trail through events

### Data Integrity
- Duplicate prevention ensures clean topic list
- Proper array management prevents storage corruption
- Event emission provides external verification
- Public queries enable transparency

### Upgrade Safety
- Topic storage compatible with diamond upgrades
- Existing topics preserved during facet updates
- New versions can add functionality while preserving data
- Event schemas should remain consistent

## Best Practices

### 1. Topic Management
- **Standard Topics**: Use established OnChain-ID topic IDs when possible
- **Documentation**: Maintain clear mapping of topic IDs to requirements
- **Coordination**: Align with trusted issuer ecosystem
- **Testing**: Verify all required topics before deployment

### 2. Regulatory Compliance
- **Legal Review**: Have legal counsel approve topic requirements
- **Jurisdiction Analysis**: Understand applicable regulatory frameworks
- **Update Procedures**: Establish clear processes for requirement changes
- **Stakeholder Communication**: Notify participants of compliance changes

### 3. System Integration
- **Issuer Coordination**: Ensure trusted issuers support required topics
- **Verification Testing**: Test full verification flow with all topics
- **Performance Monitoring**: Monitor gas usage and verification times
- **External Systems**: Consider impact on wallets and exchanges

## Future Enhancements

### 1. Advanced Topic Management
- Topic categories and hierarchies
- Conditional requirements based on investment amount
- Time-based topic requirements (e.g., periodic renewal)
- Geographic-specific topic sets

### 2. Integration Improvements
- Batch topic operations for gas efficiency
- Topic metadata and descriptions
- Standardized topic registry integration
- Cross-chain topic synchronization

The ClaimTopicsFacet provides essential flexibility for managing evolving compliance requirements while maintaining system security and regulatory alignment.
