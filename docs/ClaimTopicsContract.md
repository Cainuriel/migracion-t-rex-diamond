# ClaimTopics Contract

The **ClaimTopics Contract** manages the required claim topics within the T-REX protocol. It defines which types of claims are mandatory for token holders to possess, enabling compliance verification based on identity attributes and certifications.

## Overview

Claim topics are numerical identifiers that represent different types of identity claims (e.g., KYC verification, AML checks, accreditation status). The ClaimTopics contract maintains a registry of required topics that token holders must have valid claims for.

## Architecture

### Contract Structure

```
ClaimTopicsFacet (External Interface)
├── ClaimTopicsInternalFacet (Business Logic)
├── IClaimTopicsEvents (Events Interface)
└── Storage (Diamond Storage Pattern)
```

### Key Components

1. **ClaimTopicsFacet**: External interface exposing claim topics management functions
2. **ClaimTopicsInternalFacet**: Internal business logic and storage management
3. **IClaimTopicsEvents**: Centralized events interface
4. **Diamond Storage**: Isolated storage using unique storage slots

## Core Functionality

### Claim Topics Management

#### Adding Claim Topics
```solidity
function addClaimTopic(uint256 topic) external onlyOwner
```
- Adds a new required claim topic
- Only callable by contract owner
- Emits `ClaimTopicAdded` event
- Prevents duplicate additions

#### Removing Claim Topics
```solidity
function removeClaimTopic(uint256 topic) external onlyOwner
```
- Removes an existing claim topic requirement
- Only callable by contract owner
- Emits `ClaimTopicRemoved` event
- Validates topic exists before removal

#### Querying Claim Topics
```solidity
function getClaimTopics() external view returns (uint256[] memory)
```
- Returns array of all required claim topics
- Public read access for compliance verification
- Used by other contracts to validate requirements

## Storage Structure

### ClaimTopicsStorage
```solidity
struct ClaimTopicsStorage {
    uint256[] claimTopics;                    // Array of required topic IDs
    mapping(uint256 => bool) requiredClaimTopics; // Quick lookup for requirements
}
```

### Storage Access Pattern
```solidity
bytes32 private constant CLAIM_TOPICS_STORAGE_POSITION = 
    keccak256("t-rex.diamond.claim-topics.storage");
```

## Events

### ClaimTopicAdded
```solidity
event ClaimTopicAdded(uint256 indexed topic);
```
Emitted when a new claim topic requirement is added.

### ClaimTopicRemoved
```solidity
event ClaimTopicRemoved(uint256 indexed topic);
```
Emitted when a claim topic requirement is removed.

## Security & Access Control

### Authorization
- **Owner Only**: Adding and removing claim topics requires owner privileges
- **Public Read**: Claim topic queries are publicly accessible
- **Internal Validation**: Business logic validates topic existence and prevents duplicates

### Security Features
- Duplicate prevention for topic additions
- Existence validation for topic removals
- Isolated storage prevents cross-contract interference
- Events provide full audit trail

## Integration Patterns

### With Compliance Contract
```solidity
// Compliance contract queries required topics
uint256[] memory requiredTopics = claimTopicsFacet.getClaimTopics();

// Validates investor has all required claim topics
for (uint256 i = 0; i < requiredTopics.length; i++) {
    require(
        identityContract.claimIsValid(investor, requiredTopics[i]),
        "Missing required claim"
    );
}
```

### With Identity Registry
```solidity
// Identity registry checks topic requirements during verification
function verifyInvestor(address investor) external view returns (bool) {
    uint256[] memory topics = claimTopicsFacet.getClaimTopics();
    
    for (uint256 i = 0; i < topics.length; i++) {
        if (!hasValidClaim(investor, topics[i])) {
            return false;
        }
    }
    return true;
}
```

## Common Use Cases

### 1. Basic KYC/AML Setup
```solidity
// Add standard compliance topics
claimTopicsFacet.addClaimTopic(1); // KYC verification
claimTopicsFacet.addClaimTopic(2); // AML screening
claimTopicsFacet.addClaimTopic(3); // Sanctions check
```

### 2. Accredited Investor Requirements
```solidity
// Add investor accreditation topics
claimTopicsFacet.addClaimTopic(100); // Accredited investor status
claimTopicsFacet.addClaimTopic(101); // Income verification
claimTopicsFacet.addClaimTopic(102); // Net worth verification
```

### 3. Jurisdiction-Specific Requirements
```solidity
// Add jurisdiction-specific topics
claimTopicsFacet.addClaimTopic(200); // US person status
claimTopicsFacet.addClaimTopic(201); // FATCA compliance
claimTopicsFacet.addClaimTopic(202); // Tax residency
```

## Best Practices

### Topic ID Management
- Use consistent numbering schemes (e.g., 1-99 for basic KYC, 100-199 for accreditation)
- Document topic meanings in external registry
- Coordinate with OnChain-ID implementations
- Consider topic hierarchies and dependencies

### Configuration Management
- Plan topic requirements before deployment
- Use multisig for topic management in production
- Monitor topic usage across investor base
- Implement gradual rollout for new requirements

### Integration Considerations
- Cache topic lists in frequently-called functions
- Validate topic requirements in compliance checks
- Coordinate with identity issuers on topic support
- Plan for topic evolution and migration

## Error Handling

### Common Errors
- **"ClaimTopicsInternal: Not owner"**: Non-owner attempting restricted operation
- **"ClaimTopicsInternal: Topic already added"**: Attempting to add duplicate topic
- **"ClaimTopicsInternal: Topic not added"**: Attempting to remove non-existent topic

### Error Resolution
1. Verify caller permissions for restricted operations
2. Check current topic list before modifications
3. Ensure topic IDs are correctly specified
4. Validate contract initialization state

## Monitoring & Analytics

### Key Metrics
- Number of required claim topics
- Topic addition/removal frequency
- Compliance coverage per topic
- Investor verification success rates

### Event Monitoring
```javascript
// Monitor topic management events
contract.on('ClaimTopicAdded', (topic, event) => {
    console.log(`New claim topic required: ${topic}`);
    updateComplianceChecks(topic);
});

contract.on('ClaimTopicRemoved', (topic, event) => {
    console.log(`Claim topic no longer required: ${topic}`);
    reviewInvestorCompliance();
});
```

## Future Considerations

### Potential Enhancements
- Topic metadata and descriptions
- Topic categories and grouping
- Conditional topic requirements
- Time-based topic validity
- Cross-chain topic recognition

### Scalability
- Optimize topic storage for large topic sets
- Consider topic inheritance patterns
- Plan for dynamic topic management
- Implement topic versioning strategies

## Related Documentation
- [Identity Contract](./IdentityContract.md) - Identity management and claims
- [Compliance Contract](./ComplianceContract.md) - Compliance verification
- [Architecture Overview](./Architecture.md) - System architecture
- [Extending Protocol](./ExtendingProtocol.md) - Adding new functionality
