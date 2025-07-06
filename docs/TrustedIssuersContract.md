# TrustedIssuers Contract

The **TrustedIssuers Contract** manages the registry of trusted claim issuers within the T-REX protocol. It defines which entities are authorized to issue specific types of identity claims, enabling secure and verified identity verification for token holders.

## Overview

Trusted issuers are entities (organizations, certification authorities, government agencies) that are authorized to issue identity claims for specific claim topics. The TrustedIssuers contract maintains a mapping between claim topics and their authorized issuers, ensuring that only verified and trusted entities can provide claims for compliance verification.

## Architecture

### Contract Structure

```
TrustedIssuersFacet (External Interface)
├── TrustedIssuersInternalFacet (Business Logic)
├── ITrustedIssuersEvents (Events Interface)
├── ITrustedIssuersErrors (Errors Interface)
└── Storage (Diamond Storage Pattern)
```

### Key Components

1. **TrustedIssuersFacet**: External interface exposing trusted issuer management functions
2. **TrustedIssuersInternalFacet**: Internal business logic and storage management
3. **ITrustedIssuersEvents**: Centralized events interface
4. **ITrustedIssuersErrors**: Centralized errors interface
5. **Diamond Storage**: Isolated storage using unique storage slots

## Core Functionality

### Trusted Issuer Management

#### Adding Trusted Issuers
```solidity
function addTrustedIssuer(address issuer, uint256[] calldata topics) external onlyOwner
```
- Adds a trusted issuer for specific claim topics
- Only callable by contract owner
- Supports multiple topics per issuer
- Prevents duplicate assignments
- Emits `TrustedIssuerAdded` event

#### Removing Trusted Issuers
```solidity
function removeTrustedIssuer(address issuer, uint256 topic) external onlyOwner
```
- Removes trusted issuer for a specific topic
- Only callable by contract owner
- Validates issuer exists for topic
- Emits `TrustedIssuerRemoved` event

#### Querying Trusted Issuers
```solidity
function getTrustedIssuers(uint256 topic) external view returns (address[] memory)
```
- Returns array of trusted issuers for a specific topic
- Public read access for claim verification
- Used by compliance contracts to validate claim sources

## Storage Structure

### TrustedIssuersStorage
```solidity
struct TrustedIssuersStorage {
    mapping(uint256 => address[]) trustedIssuers;           // claimTopic => issuer addresses
    mapping(address => mapping(uint256 => bool)) issuerStatus; // issuer => claimTopic => trusted
    mapping(uint256 => uint256) issuerCount;                // claimTopic => count of trusted issuers
}
```

### Storage Access Pattern
```solidity
bytes32 private constant TRUSTED_ISSUERS_STORAGE_POSITION = 
    keccak256("t-rex.diamond.trusted-issuers.storage");
```

## Events

### TrustedIssuerAdded
```solidity
event TrustedIssuerAdded(address indexed issuer, uint256[] claimTopics);
```
Emitted when a trusted issuer is added for one or more claim topics.

### TrustedIssuerRemoved
```solidity
event TrustedIssuerRemoved(address indexed issuer);
```
Emitted when a trusted issuer is removed from a claim topic.

## Errors

### ZeroAddress
```solidity
error ZeroAddress();
```
Thrown when attempting to use zero address as an issuer.

### IssuerNotTrusted
```solidity
error IssuerNotTrusted(address issuer, uint256 topic);
```
Thrown when an issuer is not trusted for a specific claim topic.

## Security & Access Control

### Authorization
- **Owner Only**: Adding and removing trusted issuers requires owner privileges
- **Public Read**: Trusted issuer queries are publicly accessible
- **Internal Validation**: Business logic validates issuer existence and prevents duplicates

### Security Features
- Zero address validation for issuer addresses
- Duplicate prevention for issuer assignments
- Topic-specific issuer management
- Isolated storage prevents cross-contract interference
- Events provide full audit trail

## Integration Patterns

### With Identity Registry
```solidity
// Identity registry validates claim issuer during verification
function isClaimValid(address identity, uint256 topic, bytes memory signature) 
    external view returns (bool) 
{
    address[] memory trustedIssuers = trustedIssuersFacet.getTrustedIssuers(topic);
    address claimIssuer = recoverClaimIssuer(identity, topic, signature);
    
    // Check if claim issuer is trusted for this topic
    for (uint256 i = 0; i < trustedIssuers.length; i++) {
        if (trustedIssuers[i] == claimIssuer) {
            return validateClaimData(identity, topic, signature);
        }
    }
    return false;
}
```

### With Compliance Contract
```solidity
// Compliance contract uses trusted issuers for claim validation
function verifyInvestorClaims(address investor) external view returns (bool) {
    uint256[] memory requiredTopics = claimTopicsFacet.getClaimTopics();
    
    for (uint256 i = 0; i < requiredTopics.length; i++) {
        uint256 topic = requiredTopics[i];
        address[] memory trustedIssuers = trustedIssuersFacet.getTrustedIssuers(topic);
        
        bool hasValidClaim = false;
        for (uint256 j = 0; j < trustedIssuers.length; j++) {
            if (hasValidClaimFromIssuer(investor, topic, trustedIssuers[j])) {
                hasValidClaim = true;
                break;
            }
        }
        
        if (!hasValidClaim) {
            return false;
        }
    }
    return true;
}
```

## Common Use Cases

### 1. Setting Up KYC Providers
```solidity
// Add certified KYC providers
address[] memory kycProviders = [
    0x123..., // Jumio
    0x456..., // Onfido
    0x789...  // Civic
];

for (uint256 i = 0; i < kycProviders.length; i++) {
    uint256[] memory kycTopics = [1, 2, 3]; // KYC, AML, Sanctions
    trustedIssuersFacet.addTrustedIssuer(kycProviders[i], kycTopics);
}
```

### 2. Jurisdiction-Specific Issuers
```solidity
// Add government agencies as trusted issuers
uint256[] memory govTopics = [200, 201, 202]; // Tax, Residency, Citizenship

trustedIssuersFacet.addTrustedIssuer(
    0xUSGov123..., // US Treasury/IRS
    govTopics
);

trustedIssuersFacet.addTrustedIssuer(
    0xEUGov456..., // EU Authority
    govTopics
);
```

### 3. Accreditation Authorities
```solidity
// Add accreditation verification services
uint256[] memory accredTopics = [100, 101, 102]; // Accredited investor topics

trustedIssuersFacet.addTrustedIssuer(
    0xSEC789..., // SEC-approved verifier
    accredTopics
);
```

## Best Practices

### Issuer Onboarding
- Verify issuer credentials before adding to registry
- Implement multi-signature approval for critical issuers
- Document issuer capabilities and limitations
- Establish service level agreements with issuers

### Topic Management
- Assign issuers to specific topics they're qualified for
- Avoid overly broad topic assignments
- Regular review of issuer authorizations
- Plan for issuer rotation and backup providers

### Security Considerations
- Use hardware wallets for issuer key management
- Implement time-bounded authorizations where appropriate
- Monitor issuer activity and claim quality
- Establish revocation procedures for compromised issuers

## Monitoring & Analytics

### Key Metrics
- Number of trusted issuers per topic
- Issuer utilization rates
- Claim verification success rates
- Geographic distribution of issuers

### Event Monitoring
```javascript
// Monitor issuer management events
contract.on('TrustedIssuerAdded', (issuer, topics, event) => {
    console.log(`New trusted issuer: ${issuer} for topics: ${topics}`);
    updateIssuerRegistry(issuer, topics);
});

contract.on('TrustedIssuerRemoved', (issuer, event) => {
    console.log(`Trusted issuer removed: ${issuer}`);
    reviewClaimValidations(issuer);
});
```

### Issuer Performance Tracking
```javascript
// Track issuer claim validation rates
function trackIssuerPerformance() {
    const topics = claimTopicsContract.getClaimTopics();
    
    topics.forEach(topic => {
        const issuers = trustedIssuersContract.getTrustedIssuers(topic);
        issuers.forEach(issuer => {
            // Analyze claim quality, response times, etc.
            analyzeIssuerMetrics(issuer, topic);
        });
    });
}
```

## Error Handling

### Common Errors
- **ZeroAddress**: Using zero address as issuer address
- **IssuerNotTrusted**: Attempting to validate claim from non-trusted issuer
- **"TrustedIssuersInternal: Not owner"**: Non-owner attempting restricted operation

### Error Resolution
1. Validate issuer addresses before operations
2. Check trusted status before claim validation
3. Verify caller permissions for restricted operations
4. Ensure proper initialization of issuer registry

## Advanced Features

### Issuer Capabilities
- Topic-specific authorization
- Bulk issuer management
- Issuer status tracking
- Performance monitoring integration

### Scalability Considerations
- Efficient storage for large issuer sets
- Gas optimization for issuer queries
- Pagination for issuer lists
- Caching strategies for frequent queries

## Future Enhancements

### Potential Improvements
- Time-bounded issuer authorizations
- Issuer reputation scoring
- Automatic issuer rotation
- Cross-chain issuer recognition
- Delegated issuer management

### Integration Possibilities
- Real-time issuer monitoring
- Automated compliance reporting
- Integration with external issuer registries
- Multi-jurisdiction issuer coordination

## Related Documentation
- [ClaimTopics Contract](./ClaimTopicsContract.md) - Claim topic management
- [Identity Contract](./IdentityContract.md) - Identity management and claims
- [Compliance Contract](./ComplianceContract.md) - Compliance verification
- [Architecture Overview](./Architecture.md) - System architecture
- [Extending Protocol](./ExtendingProtocol.md) - Adding new functionality
