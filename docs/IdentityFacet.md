# IdentityFacet Documentation

## Overview

The `IdentityFacet` manages the **investor identity and verification system** for the T-REX security token. It implements KYC/AML compliance through integration with **OnChain-ID** infrastructure, managing investor registrations, identity verification, and claim validation to ensure regulatory compliance.

## Architecture & Purpose

### Primary Responsibilities
- **Identity Registration**: Links investors to their OnChain-ID identity contracts
- **KYC/AML Verification**: Validates investor identity through trusted claim issuers
- **Country Tracking**: Maintains investor nationality for regulatory compliance
- **Claim Validation**: Verifies required identity claims from trusted sources
- **Administrative Management**: Provides identity lifecycle management

### OnChain-ID Integration
The facet integrates with the **OnChain-ID ecosystem**:
- **IIdentity**: Interface for accessing identity claims
- **IClaimIssuer**: Interface for validating claim signatures
- **Decentralized Identity**: Supports self-sovereign identity principles
- **Trusted Issuers**: Works with authorized claim validation sources

## Storage Integration

Uses `AppStorage.investors` mapping:
```solidity
struct Investor {
    address identity;    // OnChain-ID identity contract address
    uint16 country;     // Country code (ISO 3166-1 numeric)
    bool isFrozen;      // Account freeze status
}
```

Also integrates with:
- `claimTopics[]`: Required claim types for verification
- `trustedIssuers[]`: Authorized claim issuer addresses

## Key Functions

### Administrative Functions (onlyAgentOrOwner)

#### Identity Registration
```solidity
function registerIdentity(address investor, address identity, uint16 country) external onlyAgentOrOwner
```
- **Purpose**: Register a new investor with their OnChain-ID
- **Parameters**:
  - `investor`: Ethereum address of the investor
  - `identity`: OnChain-ID identity contract address
  - `country`: ISO 3166-1 numeric country code
- **Validation**: Prevents duplicate registration
- **Event**: Emits `IdentityRegistered`

#### Identity Management
```solidity
function updateIdentity(address investor, address newIdentity) external onlyAgentOrOwner
function updateCountry(address investor, uint16 newCountry) external onlyAgentOrOwner
function deleteIdentity(address investor) external onlyAgentOrOwner
```
- **Update Identity**: Change investor's OnChain-ID contract
- **Update Country**: Modify nationality for regulatory requirements
- **Delete Identity**: Remove investor from registry (compliance action)

### Verification Functions

#### Identity Verification
```solidity
function isVerified(address user) public view returns (bool)
```

**Comprehensive Verification Process**:
1. **Identity Existence**: Checks if investor has registered identity
2. **Claim Topic Validation**: Iterates through required claim topics
3. **Trusted Issuer Verification**: Validates claims from authorized issuers
4. **Signature Validation**: Verifies claim authenticity through issuer
5. **Completeness Check**: Ensures all required topics have valid claims

**Verification Logic Flow**:
```solidity
// 1. Check identity registration
if (investor.identity == address(0)) return false;

// 2. For each required claim topic
for (uint i = 0; i < s.claimTopics.length; i++) {
    uint256 topic = s.claimTopics[i];
    
    // 3. Check trusted issuers for this topic
    address[] memory issuers = s.trustedIssuers[topic];
    
    // 4. Validate claims from trusted issuers
    // 5. Verify signature through claim issuer
    // 6. All topics must have valid claims
}
```

#### Information Retrieval
```solidity
function getInvestorCountry(address investor) external view returns (uint16)
function getIdentity(address investor) external view returns (address)
```
- **Country Lookup**: Returns investor's registered country code
- **Identity Lookup**: Returns OnChain-ID contract address

## Claim Validation Process

### 1. Claim Topic Iteration
The system checks each required claim topic (e.g., KYC, AML, accreditation):
```solidity
for (uint i = 0; i < s.claimTopics.length; i++) {
    uint256 topic = s.claimTopics[i];
    // Validation logic for each topic
}
```

### 2. Trusted Issuer Verification
For each topic, checks claims from authorized issuers:
```solidity
address[] memory issuers = s.trustedIssuers[topic];
for (uint j = 0; j < issuers.length; j++) {
    // Check claims from this issuer
}
```

### 3. Claim Retrieval and Validation
```solidity
try identity.getClaimIdsByTopic(topic) returns (bytes32[] memory claimIds) {
    for (uint k = 0; k < claimIds.length; k++) {
        try identity.getClaim(claimIds[k]) returns (
            uint256 /* claimTopic */,
            uint256 /* scheme */,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory /* uri */
        ) {
            // Validate claim signature
            if (issuer == issuers[j]) {
                try IClaimIssuer(issuer).isClaimValid(identity, topic, signature, data) returns (bool valid) {
                    if (valid) {
                        validClaim = true;
                        break;
                    }
                } catch {}
            }
        } catch {}
    }
} catch {}
```

### 4. Error Handling
- Uses `try/catch` blocks for robust error handling
- Gracefully handles missing claims or invalid issuers
- Prevents reverting on individual claim validation failures

## Events

```solidity
event IdentityRegistered(address indexed investor, address identity, uint16 country);
event IdentityUpdated(address indexed investor, address newIdentity);
event IdentityRemoved(address indexed investor);
event CountryUpdated(address indexed investor, uint16 country);
```

These events provide comprehensive audit trails for identity management operations.

## Access Control

### onlyAgentOrOwner Modifier
```solidity
modifier onlyAgentOrOwner() {
    AppStorage storage s = LibAppStorage.diamondStorage();
    require(msg.sender == s.owner || s.agents[msg.sender], "Not authorized");
    _;
}
```
- Restricts administrative functions to owner or authorized agents
- Enables delegation of identity management operations
- Maintains security while allowing operational flexibility

## Integration with T-REX System

### ComplianceFacet Integration
- `canTransfer` checks for identity registration
- Prevents transfers to unverified investors
- Supports KYC/AML compliance requirements

### TokenFacet Coordination
- Transfer validation includes identity verification
- Minting requires verified investor status
- Administrative transfers respect identity constraints

### TrustedIssuersFacet Coordination
- Uses trusted issuer registry for claim validation
- Dynamic issuer management affects verification
- Supports multi-issuer ecosystems

### ClaimTopicsFacet Integration
- Required claim topics define verification criteria
- Topic management affects investor eligibility
- Flexible compliance requirement configuration

## Country Code Management

### ISO 3166-1 Numeric Codes
The system uses standard country codes:
- **840**: United States
- **276**: Germany  
- **250**: France
- **826**: United Kingdom
- **etc.**

### Regulatory Use Cases
- **FATCA Compliance**: US person identification
- **GDPR Requirements**: EU resident data protection
- **Sanctions Screening**: Restricted country validation
- **Tax Reporting**: Jurisdiction-based obligations

## Security Considerations

### Access Control
- Identity management restricted to authorized parties
- Agent system allows operational delegation
- Owner maintains ultimate administrative control

### Claim Validation Security
- Multiple try/catch blocks prevent DOS attacks
- Signature validation through trusted issuers
- Graceful handling of malformed claims

### Privacy Protection
- On-chain storage minimized to essential data
- Identity details stored in OnChain-ID contracts
- Country information for regulatory compliance only

## Common Use Cases

### 1. Investor Onboarding
```solidity
// 1. Investor completes KYC with trusted issuer
// 2. Issuer creates OnChain-ID with required claims
// 3. Agent registers identity in T-REX system
identityFacet.registerIdentity(investorAddress, onchainIdAddress, countryCode);

// 4. System verifies all required claims
bool verified = identityFacet.isVerified(investorAddress);
```

### 2. Compliance Verification
```solidity
// Before token transfer
require(identityFacet.isVerified(recipient), "Recipient not verified");

// Check country restrictions
uint16 country = identityFacet.getInvestorCountry(recipient);
require(!isRestrictedCountry(country), "Country not allowed");
```

### 3. Identity Updates
```solidity
// Update OnChain-ID contract (e.g., after renewal)
identityFacet.updateIdentity(investor, newOnChainIdAddress);

// Update nationality (e.g., after naturalization)
identityFacet.updateCountry(investor, newCountryCode);
```

## Best Practices

1. **Comprehensive KYC**: Ensure all required claim topics are properly configured
2. **Trusted Issuer Management**: Regularly review and update trusted issuer list
3. **Country Code Accuracy**: Use standard ISO 3166-1 numeric codes
4. **Error Monitoring**: Monitor failed verification attempts
5. **Privacy Compliance**: Minimize on-chain personal data storage
6. **Regular Audits**: Periodically verify investor identity status

## Upgradeability & Maintenance

### OnChain-ID Evolution
- System compatible with OnChain-ID standard upgrades
- New claim types can be added through ClaimTopicsFacet
- Trusted issuer network can evolve dynamically

### Regulatory Updates
- Country restrictions can be updated as regulations change
- New compliance requirements addressable through claim topics
- Flexible verification criteria support regulatory evolution

The IdentityFacet provides robust, flexible identity management that supports complex regulatory requirements while maintaining privacy and security through the OnChain-ID infrastructure.
