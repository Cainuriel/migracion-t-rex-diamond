# Identity Contract - OnChain-ID Integration System

## Overview

The **Identity Contract** implements the **OnChain-ID** integration system for our ERC-3643 implementation, providing decentralized identity verification and **Know Your Customer (KYC)** functionality. It manages the relationship between investor addresses and their verified identities, enabling regulatory compliance through cryptographic proof of identity claims.

## What is OnChain-ID?

**OnChain-ID** is a decentralized identity framework based on **ERC-735** that enables:

- **Self-Sovereign Identity**: Users control their own identity data
- **Claim-Based Verification**: Identity attributes are verified through cryptographic claims
- **Trusted Issuer Network**: Certified entities issue and validate identity claims
- **Privacy-Preserving**: Only necessary claims are revealed for specific operations
- **Interoperability**: Works across different platforms and jurisdictions

## Architecture

### Dual Facet Implementation

```
┌─────────────────┐    ┌─────────────────┐
│  IdentityFacet  │────│IdentityInternalFacet│
│   (External)    │    │    (Internal)    │
├─────────────────┤    ├─────────────────┤
│ Registration    │    │ Storage & Logic  │
│ Verification    │    │ Claim Validation │
│ Queries         │    │ Cross-integration│
└─────────────────┘    └─────────────────┘
```

**IdentityFacet** (External)
- **File**: `contracts/facets/IdentityFacet.sol`
- **Purpose**: Public identity management interface
- **Responsibilities**: Identity registration, verification queries, administrative functions
- **Users**: Investors, agents, external systems

**IdentityInternalFacet** (Internal)
- **File**: `contracts/facets/internal/IdentityInternalFacet.sol`
- **Purpose**: Core identity logic and storage management
- **Responsibilities**: Claim validation, storage operations, compliance integration
- **Users**: Other facets within the diamond system

## Core Functions

### Identity Registration

#### `registerIdentity(address investor, address identity)`
```solidity
function registerIdentity(address investor, address identity) external onlyAgent
```
- **Purpose**: Link an investor address to their OnChain-ID identity contract
- **Access**: Agents only (KYC providers, administrators)
- **Validation**: Validates identity contract exists and is properly formatted
- **Events**: Emits `IdentityRegistered(investor, identity)`

**Pre-conditions:**
- Caller must be authorized agent
- Investor address must not be zero
- Identity contract must exist and be valid
- Investor must not already have registered identity

#### `updateIdentity(address investor, address newIdentity)`
```solidity
function updateIdentity(address investor, address newIdentity) external onlyAgent
```
- **Purpose**: Update an investor's identity contract (e.g., after identity renewal)
- **Access**: Agents only
- **Validation**: New identity must be valid, old identity must exist
- **Events**: Emits `IdentityUpdated(investor, oldIdentity, newIdentity)`

### Identity Verification

#### `isVerified(address investor)`
```solidity
function isVerified(address investor) external view returns (bool)
```
- **Purpose**: Check if an investor has completed identity verification
- **Access**: Public view function
- **Logic**: Validates all required claim topics against trusted issuers
- **Returns**: True if investor passes all identity checks

**Verification Process:**
1. Check if investor has registered identity
2. Retrieve required claim topics from ClaimTopicsFacet
3. For each topic, validate claims exist and are signed by trusted issuers
4. Verify claims are not expired
5. Check claim data integrity

#### `getIdentity(address investor)`
```solidity
function getIdentity(address investor) external view returns (address)
```
- **Purpose**: Get the OnChain-ID contract address for an investor
- **Access**: Public view function
- **Returns**: Identity contract address, or zero address if not registered

#### `getInvestorInfo(address investor)`
```solidity
function getInvestorInfo(address investor) external view returns (InvestorInfo memory)
```
- **Purpose**: Get comprehensive investor information
- **Access**: Public view function
- **Returns**: Struct with identity, country, verification status, registration time

```solidity
struct InvestorInfo {
    address identity;          // OnChain-ID contract
    uint16 country;           // ISO country code  
    bool isVerified;          // Current verification status
    uint256 registrationTime; // When identity was registered
    bool frozen;              // Account freeze status
}
```

### Administrative Functions

#### `setCountry(address investor, uint16 country)`
```solidity
function setCountry(address investor, uint16 country) external onlyAgent
```
- **Purpose**: Set or update investor's country of residence
- **Access**: Agents only
- **Validation**: Country code must be valid ISO-3166 code
- **Events**: Emits `CountryUpdated(investor, country)`

#### `batchRegisterIdentities(address[] investors, address[] identities)`
```solidity
function batchRegisterIdentities(
    address[] calldata investors, 
    address[] calldata identities
) external onlyAgent
```
- **Purpose**: Register multiple identities in a single transaction
- **Access**: Agents only
- **Validation**: Arrays must be same length, all individual validations apply
- **Gas Optimization**: Reduces transaction costs for bulk operations

## Identity Storage Architecture

### IdentityStorage Structure
```solidity
struct IdentityStorage {
    // === CORE IDENTITY MAPPING ===
    mapping(address => address) investorIdentities;
    mapping(address => address) identityToInvestor; // Reverse mapping
    
    // === INVESTOR DETAILS ===
    mapping(address => uint16) investorCountries;
    mapping(address => uint256) investorRegistrationTime;
    mapping(address => bool) investorFrozenStatus;
    
    // === VERIFICATION CACHE ===
    mapping(address => bool) verificationCache;
    mapping(address => uint256) lastVerificationTime;
    
    // === STATISTICS ===
    uint256 totalRegisteredInvestors;
    mapping(uint16 => uint256) investorsByCountry;
}
```

**Storage Location**: `keccak256("identity.storage.location")`

### Key Storage Features

#### Bidirectional Mapping
- **Investor → Identity**: `mapping(address => address) investorIdentities`
- **Identity → Investor**: `mapping(address => address) identityToInvestor`
- **Purpose**: Efficient lookups in both directions
- **Use Cases**: Validation, reverse lookups, claim verification

#### Country Tracking
- **Country Mapping**: `mapping(address => uint16) investorCountries`
- **Statistics**: `mapping(uint16 => uint256) investorsByCountry`
- **Standards**: ISO-3166-1 numeric country codes
- **Compliance**: Enables jurisdiction-specific rules

#### Verification Caching
- **Cache Results**: `mapping(address => bool) verificationCache`
- **Timestamp Tracking**: `mapping(address => uint256) lastVerificationTime`
- **Performance**: Reduces gas costs for repeated checks
- **Invalidation**: Cache cleared when claims change

## Integration with Claim System

### Required Claims Validation

The identity system validates claims based on requirements from ClaimTopicsFacet:

```solidity
function _validateClaims(address investor) internal view returns (bool) {
    IdentityStorage storage ids = _getIdentityStorage();
    address identity = ids.investorIdentities[investor];
    
    if (identity == address(0)) return false;
    
    // Get required claim topics
    ClaimTopicsInternalFacet claimTopics = ClaimTopicsInternalFacet(address(this));
    uint256[] memory requiredTopics = claimTopics._getClaimTopics();
    
    // Validate each required topic
    for (uint i = 0; i < requiredTopics.length; i++) {
        if (!_validateClaimTopic(identity, requiredTopics[i])) {
            return false;
        }
    }
    
    return true;
}
```

### Claim Validation Process

For each required claim topic:

1. **Retrieve Claims**: Get all claims for the topic from the identity contract
2. **Issuer Validation**: Verify claims are signed by trusted issuers
3. **Signature Verification**: Validate cryptographic signatures
4. **Expiration Check**: Ensure claims haven't expired
5. **Data Integrity**: Verify claim data hasn't been tampered with

```solidity
function _validateClaimTopic(address identity, uint256 topic) internal view returns (bool) {
    // Get trusted issuers for this topic
    TrustedIssuersInternalFacet trustedIssuers = TrustedIssuersInternalFacet(address(this));
    address[] memory issuers = trustedIssuers._getTrustedIssuersForTopic(topic);
    
    if (issuers.length == 0) return false;
    
    // Check if identity has valid claim from any trusted issuer
    for (uint i = 0; i < issuers.length; i++) {
        if (_hasValidClaim(identity, topic, issuers[i])) {
            return true;
        }
    }
    
    return false;
}
```

## Integration with Token Operations

### Transfer Validation
Every token transfer checks identity verification:

```solidity
// In TokenInternalFacet._transfer()
function _transfer(address from, address to, uint256 amount) internal {
    // Validate sender identity (if not initial mint)
    if (from != address(0)) {
        IdentityInternalFacet identity = IdentityInternalFacet(address(this));
        if (!identity._isVerified(from)) {
            revert IdentityNotVerified(from);
        }
    }
    
    // Validate recipient identity
    IdentityInternalFacet identity = IdentityInternalFacet(address(this));
    if (!identity._isVerified(to)) {
        revert IdentityNotVerified(to);
    }
    
    // Continue with transfer...
}
```

### Compliance Integration
Identity verification is a prerequisite for compliance validation:

```solidity
// In ComplianceInternalFacet._validateTransfer()
function _validateTransfer(address from, address to, uint256 amount) internal view returns (bool) {
    // First check identity verification
    IdentityInternalFacet identity = IdentityInternalFacet(address(this));
    
    if (from != address(0) && !identity._isVerified(from)) return false;
    if (!identity._isVerified(to)) return false;
    
    // Then check other compliance rules...
    return _validateComplianceRules(from, to, amount);
}
```

## Country-Based Compliance

### Country Code Management
Uses **ISO-3166-1 numeric** country codes:

```solidity
// Common country codes
uint16 constant COUNTRY_US = 840;   // United States
uint16 constant COUNTRY_GB = 826;   // United Kingdom  
uint16 constant COUNTRY_DE = 276;   // Germany
uint16 constant COUNTRY_JP = 392;   // Japan
uint16 constant COUNTRY_SG = 702;   // Singapore
uint16 constant COUNTRY_CH = 756;   // Switzerland
```

### Jurisdiction-Specific Rules
Enables different compliance rules per country:

```solidity
function _validateCountryCompliance(address investor, uint256 amount) internal view returns (bool) {
    IdentityStorage storage ids = _getIdentityStorage();
    uint16 country = ids.investorCountries[investor];
    
    // US-specific rules
    if (country == COUNTRY_US) {
        return _validateUSCompliance(investor, amount);
    }
    
    // EU-specific rules  
    if (_isEUCountry(country)) {
        return _validateEUCompliance(investor, amount);
    }
    
    // Default rules
    return _validateDefaultCompliance(investor, amount);
}
```

## Events

### Registration Events
```solidity
event IdentityRegistered(
    address indexed investor, 
    address indexed identity, 
    uint16 country
);

event IdentityUpdated(
    address indexed investor, 
    address indexed oldIdentity, 
    address indexed newIdentity
);

event CountryUpdated(
    address indexed investor, 
    uint16 oldCountry, 
    uint16 newCountry
);
```

### Verification Events
```solidity
event VerificationStatusChanged(
    address indexed investor, 
    bool isVerified, 
    string reason
);

event ClaimValidated(
    address indexed investor, 
    uint256 indexed topic, 
    address indexed issuer
);

event ClaimExpired(
    address indexed investor, 
    uint256 indexed topic, 
    address indexed issuer
);
```

### Batch Events
```solidity
event BatchIdentityRegistered(
    address[] investors, 
    address[] identities, 
    uint256 successCount
);
```

## Error Handling

### Custom Errors
```solidity
// Registration errors
error IdentityAlreadyRegistered(address investor, address existingIdentity);
error IdentityNotRegistered(address investor);
error InvalidIdentityContract(address identity);

// Verification errors
error IdentityNotVerified(address investor);
error RequiredClaimMissing(address investor, uint256 topic);
error ClaimExpired(address investor, uint256 topic, address issuer);
error UntrustedIssuer(address issuer, uint256 topic);

// Country errors
error InvalidCountryCode(uint16 country);
error CountryRestricted(uint16 country);

// Access control
error Unauthorized(address caller);
```

### Detailed Error Context
```solidity
// Provide specific information about verification failures
function _revertWithVerificationDetails(address investor) internal view {
    uint256[] memory requiredTopics = _getRequiredTopics();
    
    for (uint i = 0; i < requiredTopics.length; i++) {
        if (!_hasValidClaimForTopic(investor, requiredTopics[i])) {
            revert RequiredClaimMissing(investor, requiredTopics[i]);
        }
    }
}
```

## Gas Optimization

### Verification Caching
```solidity
function _isVerified(address investor) internal view returns (bool) {
    IdentityStorage storage ids = _getIdentityStorage();
    
    // Check cache first
    if (ids.lastVerificationTime[investor] + CACHE_DURATION > block.timestamp) {
        return ids.verificationCache[investor];
    }
    
    // Perform full verification
    bool isVerified = _performFullVerification(investor);
    
    // Update cache
    ids.verificationCache[investor] = isVerified;
    ids.lastVerificationTime[investor] = block.timestamp;
    
    return isVerified;
}
```

### Batch Operations
```solidity
function _batchRegisterIdentities(
    address[] calldata investors,
    address[] calldata identities
) internal {
    require(investors.length == identities.length, "Array length mismatch");
    
    IdentityStorage storage ids = _getIdentityStorage();
    
    for (uint i = 0; i < investors.length; i++) {
        if (_isValidRegistration(investors[i], identities[i])) {
            ids.investorIdentities[investors[i]] = identities[i];
            ids.identityToInvestor[identities[i]] = investors[i];
            ids.investorRegistrationTime[investors[i]] = block.timestamp;
            ids.totalRegisteredInvestors++;
        }
    }
}
```

## Security Considerations

### Identity Contract Validation
```solidity
function _isValidIdentityContract(address identity) internal view returns (bool) {
    // Check if contract exists
    if (identity.code.length == 0) return false;
    
    // Check if it implements required interfaces
    try IERC165(identity).supportsInterface(type(IIdentity).interfaceId) returns (bool supported) {
        return supported;
    } catch {
        return false;
    }
}
```

### Replay Attack Prevention
```solidity
function _validateClaimSignature(
    address identity,
    uint256 topic,
    bytes memory data,
    bytes memory signature,
    address issuer
) internal pure returns (bool) {
    // Include identity address and topic in signature validation
    bytes32 hash = keccak256(abi.encodePacked(
        identity,
        topic,
        data,
        block.chainid  // Prevent cross-chain replay
    ));
    
    return _verifySignature(hash, signature, issuer);
}
```

## Current Implementation Status

### ✅ **Completed Features**
- **Basic Registration**: Link investor addresses to identity contracts
- **Country Management**: Track investor jurisdictions  
- **Simple Verification**: Basic claim validation
- **Storage Architecture**: Efficient data structures
- **Access Control**: Role-based permissions
- **Event System**: Comprehensive event emission

### 🔄 **Partial Implementation**
- **Claim Validation**: Basic claim checking (could be enhanced)
- **Caching System**: Simple verification caching
- **Batch Operations**: Basic batch registration

### ❌ **Future Enhancements**
- **Advanced Claim Verification**: Full cryptographic validation
- **Claim Expiration Management**: Automatic invalidation
- **Multi-Signature Claims**: Support for multi-issuer claims
- **Privacy Features**: Zero-knowledge claim verification
- **Cross-Chain Identity**: Support for cross-chain identities

## Integration Examples

### Basic Identity Operations
```javascript
// Register investor identity (as agent)
await identity.connect(agent).registerIdentity(
    investorAddress, 
    identityContractAddress
);

// Set investor country (as agent)
await identity.connect(agent).setCountry(investorAddress, 840); // US

// Check verification status
const isVerified = await identity.isVerified(investorAddress);

// Get investor information
const info = await identity.getInvestorInfo(investorAddress);
console.log(`Country: ${info.country}, Verified: ${info.isVerified}`);
```

### Batch Operations
```javascript
// Batch register multiple investors (as agent)
const investors = [addr1, addr2, addr3];
const identities = [id1, id2, id3];

await identity.connect(agent).batchRegisterIdentities(investors, identities);
```

### Compliance Integration
```javascript
// Check if transfer would pass identity verification
const fromVerified = await identity.isVerified(fromAddress);
const toVerified = await identity.isVerified(toAddress);

if (!fromVerified || !toVerified) {
    console.log("Transfer would fail identity verification");
}
```

## Best Practices

### For Identity Providers
1. **Use Standard Formats**: Follow ERC-735 and OnChain-ID standards
2. **Secure Key Management**: Protect issuer private keys
3. **Claim Expiration**: Set appropriate expiration times
4. **Data Minimization**: Only include necessary claim data
5. **Regular Updates**: Keep claim information current

### For Developers
1. **Validate Before Operations**: Always check verification status
2. **Handle Failures Gracefully**: Provide clear error messages
3. **Cache Appropriately**: Balance performance vs freshness
4. **Monitor Events**: Track registration and verification changes
5. **Test Edge Cases**: Handle expired claims, invalid identities

### For Administrators
1. **Manage Trusted Issuers**: Carefully vet identity providers
2. **Monitor Compliance**: Track verification rates and failures
3. **Handle Disputes**: Establish procedures for identity issues
4. **Regular Audits**: Review identity verification processes
5. **Backup Procedures**: Plan for identity provider failures

The Identity Contract provides the foundation for regulatory compliance in our ERC-3643 implementation, enabling secure and verifiable identity management while maintaining privacy and user control over personal data.

## Related Documentation
- [Token Contract](./TokenContract.md) - Token operations with identity verification
- [Compliance Contract](./ComplianceContract.md) - Compliance rules integration
- [ClaimTopics Contract](./ClaimTopicsContract.md) - Required verification types
- [TrustedIssuers Contract](./TrustedIssuersContract.md) - Authorized identity issuers
- [Roles Contract](./RolesContract.md) - Access control and agent management
- [Architecture Overview](./Architecture.md) - System architecture
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Diamond pattern implementation
