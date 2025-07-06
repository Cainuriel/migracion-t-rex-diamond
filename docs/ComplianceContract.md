# Compliance Contract - Regulatory Rules Engine

## Overview

The **Compliance Contract** implements the core **regulatory compliance engine** for our ERC-3643 security token. It enforces automated compliance rules that govern token transfers, ensuring all operations meet regulatory requirements before execution. This system provides the foundation for securities law compliance across multiple jurisdictions.

## What is Securities Token Compliance?

Securities token compliance involves enforcing regulatory rules at the smart contract level:

- **Transfer Restrictions**: Rules about who can hold tokens and in what amounts
- **Investment Limits**: Maximum/minimum investment amounts per investor
- **Investor Caps**: Maximum number of token holders
- **Jurisdiction Rules**: Country-specific restrictions and requirements
- **Time-Based Rules**: Lock-up periods, vesting schedules
- **Regulatory Reporting**: Data needed for compliance reporting

## Architecture

### Dual Facet Implementation

```
┌─────────────────┐    ┌─────────────────┐
│ ComplianceFacet │────│ComplianceInternalFacet│
│   (External)    │    │    (Internal)    │
├─────────────────┤    ├─────────────────┤
│ Rule Management │    │ Logic & Storage  │
│ Configuration   │    │ Validation Engine│
│ Queries         │    │ Cross-integration│
└─────────────────┘    └─────────────────┘
```

**ComplianceFacet** (External)
- **File**: `contracts/facets/ComplianceFacet.sol`
- **Purpose**: Public compliance management interface
- **Responsibilities**: Rule configuration, compliance queries, administrative functions
- **Users**: Administrators, agents, external systems

**ComplianceInternalFacet** (Internal)
- **File**: `contracts/facets/internal/ComplianceInternalFacet.sol`
- **Purpose**: Core compliance logic and storage management
- **Responsibilities**: Transfer validation, rule enforcement, integration with other facets
- **Users**: Other facets within the diamond system (especially TokenInternalFacet)

## Core Compliance Rules

### Investment Limits

#### `setMaxBalancePerInvestor(uint256 maxBalance)`
```solidity
function setMaxBalancePerInvestor(uint256 maxBalance) external onlyOwner
```
- **Purpose**: Set maximum token balance any single investor can hold
- **Access**: Owner only
- **Use Case**: Prevent concentration of ownership, comply with distribution requirements
- **Events**: Emits `MaxBalanceUpdated(maxBalance)`

#### `setMinInvestment(uint256 minInvestment)`
```solidity
function setMinInvestment(uint256 minInvestment) external onlyOwner
```
- **Purpose**: Set minimum initial investment amount
- **Access**: Owner only
- **Use Case**: Ensure investors meet minimum qualification thresholds
- **Events**: Emits `MinInvestmentUpdated(minInvestment)`

#### `getMaxBalancePerInvestor()` / `getMinInvestment()`
```solidity
function getMaxBalancePerInvestor() external view returns (uint256)
function getMinInvestment() external view returns (uint256)
```
- **Purpose**: Query current investment limits
- **Access**: Public view functions
- **Returns**: Current limit values

### Investor Management

#### `setMaxInvestors(uint256 maxInvestors)`
```solidity
function setMaxInvestors(uint256 maxInvestors) external onlyOwner
```
- **Purpose**: Set maximum number of token holders allowed
- **Access**: Owner only
- **Use Case**: Comply with exemption requirements (e.g., Reg D 506(b) - 35 investors)
- **Events**: Emits `MaxInvestorsUpdated(maxInvestors)`

#### `getCurrentInvestorCount()`
```solidity
function getCurrentInvestorCount() external view returns (uint256)
```
- **Purpose**: Get current number of token holders
- **Access**: Public view function
- **Integration**: Uses TokenInternalFacet holder tracking
- **Returns**: Number of addresses with non-zero balances

### Transfer Validation

#### `validateTransfer(address from, address to, uint256 amount)`
```solidity
function validateTransfer(address from, address to, uint256 amount) 
    external view returns (bool isValid, string memory reason)
```
- **Purpose**: Check if a proposed transfer would comply with all rules
- **Access**: Public view function
- **Usage**: Called by UI/wallets before attempting transfers
- **Returns**: Boolean validity and failure reason if invalid

**Validation Process:**
1. **Identity Verification**: Both parties must have verified identities
2. **Balance Limits**: Recipient balance after transfer must not exceed maximum
3. **Minimum Investment**: First-time investors must meet minimum threshold
4. **Investor Cap**: Total number of holders must not exceed maximum
5. **Freeze Status**: Neither party can be frozen
6. **Jurisdiction Rules**: Country-specific restrictions
7. **Custom Rules**: Any additional compliance modules

## Compliance Storage Architecture

### ComplianceStorage Structure
```solidity
struct ComplianceStorage {
    // === INVESTMENT LIMITS ===
    uint256 maxBalancePerInvestor;
    uint256 minInvestment;
    uint256 maxInvestors;
    
    // === JURISDICTION RULES ===
    mapping(uint16 => bool) allowedCountries;
    mapping(uint16 => uint256) countrySpecificLimits;
    mapping(uint16 => bool) restrictedCountries;
    
    // === TIME-BASED RULES ===
    mapping(address => uint256) lockupPeriods;
    mapping(address => uint256) vestingSchedules;
    uint256 globalLockupEnd;
    
    // === CUSTOM COMPLIANCE MODULES ===
    mapping(bytes32 => bool) enabledModules;
    mapping(bytes32 => bytes) moduleConfigurations;
    
    // === EXEMPTION TRACKING ===
    mapping(address => bool) exemptInvestors;
    mapping(address => string) exemptionReasons;
    
    // === STATISTICS ===
    uint256 totalTransferAttempts;
    uint256 totalComplianceFailures;
    mapping(string => uint256) failureReasons;
}
```

**Storage Location**: `keccak256("compliance.storage.location")`

### Key Storage Features

#### Investment Limits
- **Max Balance**: Per-investor token holding limit
- **Min Investment**: Minimum first purchase amount
- **Max Investors**: Total holder cap for exemption compliance

#### Jurisdiction Management
- **Allowed Countries**: Whitelist of permitted jurisdictions
- **Country Limits**: Jurisdiction-specific investment limits
- **Restricted Countries**: Blacklist of prohibited jurisdictions

#### Time-Based Compliance
- **Individual Lockups**: Per-investor lock periods
- **Vesting Schedules**: Gradual token release schedules
- **Global Lockup**: System-wide lock periods (e.g., initial offering)

## Core Validation Logic

### Transfer Validation Engine
```solidity
function _validateTransfer(address from, address to, uint256 amount) 
    internal view returns (bool) {
    
    ComplianceStorage storage cs = _getComplianceStorage();
    
    // 1. Identity verification (delegate to IdentityInternalFacet)
    if (!_validateIdentities(from, to)) return false;
    
    // 2. Balance limit validation
    if (!_validateBalanceLimits(to, amount)) return false;
    
    // 3. Minimum investment validation (for new investors)
    if (!_validateMinimumInvestment(to, amount)) return false;
    
    // 4. Investor cap validation
    if (!_validateInvestorCap(to)) return false;
    
    // 5. Jurisdiction validation
    if (!_validateJurisdictions(from, to)) return false;
    
    // 6. Time-based restrictions
    if (!_validateTimeLocks(from, to, amount)) return false;
    
    // 7. Custom compliance modules
    if (!_validateCustomModules(from, to, amount)) return false;
    
    return true;
}
```

### Balance Limit Validation
```solidity
function _validateBalanceLimits(address to, uint256 amount) 
    internal view returns (bool) {
    
    ComplianceStorage storage cs = _getComplianceStorage();
    
    // Skip if no limit set
    if (cs.maxBalancePerInvestor == 0) return true;
    
    // Get current balance
    TokenInternalFacet token = TokenInternalFacet(address(this));
    uint256 currentBalance = token._getBalance(to);
    
    // Check if transfer would exceed limit
    if (currentBalance + amount > cs.maxBalancePerInvestor) {
        return false;
    }
    
    return true;
}
```

### Investor Cap Validation
```solidity
function _validateInvestorCap(address to) internal view returns (bool) {
    ComplianceStorage storage cs = _getComplianceStorage();
    
    // Skip if no cap set
    if (cs.maxInvestors == 0) return true;
    
    // Check if recipient already holds tokens
    TokenInternalFacet token = TokenInternalFacet(address(this));
    uint256 currentBalance = token._getBalance(to);
    
    // If already a holder, no cap issue
    if (currentBalance > 0) return true;
    
    // If new holder, check if we're at cap
    uint256 currentHolders = token._getHolderCount();
    if (currentHolders >= cs.maxInvestors) {
        return false;
    }
    
    return true;
}
```

## Integration with Token Operations

### Pre-Transfer Validation
Every token transfer calls compliance validation:

```solidity
// In TokenInternalFacet._transfer()
function _transfer(address from, address to, uint256 amount) internal {
    // Validate compliance before proceeding
    ComplianceInternalFacet compliance = ComplianceInternalFacet(address(this));
    
    if (!compliance._validateTransfer(from, to, amount)) {
        revert ComplianceViolation(from, to, amount);
    }
    
    // Continue with transfer logic...
    _updateBalances(from, to, amount);
}
```

### Mint Validation
Token minting also requires compliance validation:

```solidity
// In TokenInternalFacet._mint()
function _mint(address to, uint256 amount) internal {
    // Validate compliance for new token creation
    ComplianceInternalFacet compliance = ComplianceInternalFacet(address(this));
    
    if (!compliance._validateTransfer(address(0), to, amount)) {
        revert ComplianceViolation(address(0), to, amount);
    }
    
    // Continue with mint logic...
}
```

## Jurisdiction-Based Compliance

### Country Management
```solidity
function setCountryAllowed(uint16 country, bool allowed) external onlyOwner {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.allowedCountries[country] = allowed;
    emit CountryAllowanceUpdated(country, allowed);
}

function setCountrySpecificLimit(uint16 country, uint256 limit) external onlyOwner {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.countrySpecificLimits[country] = limit;
    emit CountryLimitUpdated(country, limit);
}
```

### Jurisdiction Validation
```solidity
function _validateJurisdictions(address from, address to) 
    internal view returns (bool) {
    
    ComplianceStorage storage cs = _getComplianceStorage();
    IdentityInternalFacet identity = IdentityInternalFacet(address(this));
    
    // Check sender country (if not mint)
    if (from != address(0)) {
        uint16 fromCountry = identity._getCountry(from);
        if (cs.restrictedCountries[fromCountry]) return false;
    }
    
    // Check recipient country
    uint16 toCountry = identity._getCountry(to);
    if (cs.restrictedCountries[toCountry]) return false;
    
    // Check if recipient country is explicitly allowed
    if (cs.allowedCountries[toCountry] == false) return false;
    
    return true;
}
```

## Time-Based Compliance

### Lockup Periods
```solidity
function setGlobalLockup(uint256 endTime) external onlyOwner {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.globalLockupEnd = endTime;
    emit GlobalLockupUpdated(endTime);
}

function setInvestorLockup(address investor, uint256 endTime) external onlyAgent {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.lockupPeriods[investor] = endTime;
    emit InvestorLockupUpdated(investor, endTime);
}
```

### Time Lock Validation
```solidity
function _validateTimeLocks(address from, address to, uint256 amount) 
    internal view returns (bool) {
    
    ComplianceStorage storage cs = _getComplianceStorage();
    
    // Check global lockup
    if (block.timestamp < cs.globalLockupEnd) return false;
    
    // Check sender individual lockup
    if (from != address(0)) {
        if (block.timestamp < cs.lockupPeriods[from]) return false;
    }
    
    // Check recipient individual lockup (for some use cases)
    if (block.timestamp < cs.lockupPeriods[to]) return false;
    
    return true;
}
```

## Events

### Rule Configuration Events
```solidity
event MaxBalanceUpdated(uint256 newMaxBalance);
event MinInvestmentUpdated(uint256 newMinInvestment);
event MaxInvestorsUpdated(uint256 newMaxInvestors);

event CountryAllowanceUpdated(uint16 indexed country, bool allowed);
event CountryLimitUpdated(uint16 indexed country, uint256 limit);

event GlobalLockupUpdated(uint256 endTime);
event InvestorLockupUpdated(address indexed investor, uint256 endTime);
```

### Compliance Events
```solidity
event TransferValidated(
    address indexed from, 
    address indexed to, 
    uint256 amount, 
    bool isValid
);

event ComplianceViolation(
    address indexed from,
    address indexed to,
    uint256 amount,
    string reason
);

event ExemptionGranted(
    address indexed investor,
    string reason
);
```

### Statistics Events
```solidity
event ComplianceStatsUpdated(
    uint256 totalAttempts,
    uint256 totalFailures,
    uint256 successRate
);
```

## Error Handling

### Custom Errors
```solidity
// Investment limit errors
error MaxBalanceExceeded(address investor, uint256 currentBalance, uint256 attemptedAmount, uint256 limit);
error MinInvestmentNotMet(address investor, uint256 attemptedAmount, uint256 minimum);
error MaxInvestorsReached(uint256 current, uint256 maximum);

// Jurisdiction errors
error CountryNotAllowed(uint16 country);
error CountryRestricted(uint16 country);
error CountryLimitExceeded(uint16 country, uint256 currentAmount, uint256 limit);

// Time-based errors
error GlobalLockupActive(uint256 endTime);
error InvestorLockupActive(address investor, uint256 endTime);

// General compliance
error ComplianceViolation(address from, address to, uint256 amount);
error IdentityNotVerified(address investor);
```

### Detailed Error Context
```solidity
function _validateWithDetailedErrors(address from, address to, uint256 amount) 
    internal view {
    
    // Identity check with specific error
    IdentityInternalFacet identity = IdentityInternalFacet(address(this));
    if (!identity._isVerified(to)) {
        revert IdentityNotVerified(to);
    }
    
    // Balance limit check with specific error
    TokenInternalFacet token = TokenInternalFacet(address(this));
    uint256 currentBalance = token._getBalance(to);
    ComplianceStorage storage cs = _getComplianceStorage();
    
    if (currentBalance + amount > cs.maxBalancePerInvestor) {
        revert MaxBalanceExceeded(to, currentBalance, amount, cs.maxBalancePerInvestor);
    }
    
    // Continue with other specific validations...
}
```

## Advanced Compliance Features

### Exemption System
```solidity
function grantExemption(address investor, string calldata reason) external onlyOwner {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.exemptInvestors[investor] = true;
    cs.exemptionReasons[investor] = reason;
    emit ExemptionGranted(investor, reason);
}

function _isExempt(address investor) internal view returns (bool) {
    ComplianceStorage storage cs = _getComplianceStorage();
    return cs.exemptInvestors[investor];
}
```

### Compliance Statistics
```solidity
function _recordComplianceAttempt(bool success, string memory reason) internal {
    ComplianceStorage storage cs = _getComplianceStorage();
    cs.totalTransferAttempts++;
    
    if (!success) {
        cs.totalComplianceFailures++;
        cs.failureReasons[reason]++;
    }
}

function getComplianceStats() external view returns (
    uint256 totalAttempts,
    uint256 totalFailures,
    uint256 successRate
) {
    ComplianceStorage storage cs = _getComplianceStorage();
    totalAttempts = cs.totalTransferAttempts;
    totalFailures = cs.totalComplianceFailures;
    
    if (totalAttempts > 0) {
        successRate = ((totalAttempts - totalFailures) * 10000) / totalAttempts;
    }
}
```

## Gas Optimization

### Validation Short-Circuiting
```solidity
function _validateTransfer(address from, address to, uint256 amount) 
    internal view returns (bool) {
    
    // Most likely to fail first - check exemptions
    if (_isExempt(to)) return true;
    
    // Quick identity check before expensive validations
    if (!_quickIdentityCheck(from, to)) return false;
    
    // Order validations by likelihood of failure and cost
    if (!_validateBalanceLimits(to, amount)) return false;
    if (!_validateInvestorCap(to)) return false;
    if (!_validateJurisdictions(from, to)) return false;
    
    // Most expensive validations last
    if (!_validateComplexRules(from, to, amount)) return false;
    
    return true;
}
```

### Caching Expensive Operations
```solidity
mapping(address => uint256) private _lastValidationBlock;
mapping(address => bool) private _lastValidationResult;

function _getCachedValidation(address investor) internal view returns (bool found, bool result) {
    if (_lastValidationBlock[investor] == block.number) {
        return (true, _lastValidationResult[investor]);
    }
    return (false, false);
}
```

## Current Implementation Status

### ✅ **Completed Features**
- **Investment Limits**: Max balance per investor, minimum investment
- **Investor Caps**: Maximum number of token holders
- **Basic Validation**: Transfer validation engine
- **Access Control**: Owner/agent permissions
- **Event System**: Comprehensive event emission
- **Custom Errors**: Detailed error reporting

### 🔄 **Partial Implementation**
- **Country Rules**: Basic country allow/restrict lists
- **Time Locks**: Simple lockup period support
- **Statistics**: Basic compliance tracking

### ❌ **Future Enhancements**
- **Advanced Compliance Modules**: Pluggable compliance rules
- **Sophisticated Time Locks**: Complex vesting schedules
- **Multi-Jurisdiction Rules**: Advanced country-specific logic
- **Compliance Reporting**: Automated regulatory reports
- **Dynamic Rules**: Rules that change based on conditions

## Integration Examples

### Basic Compliance Setup
```javascript
// Set investment limits (as owner)
await compliance.connect(owner).setMaxBalancePerInvestor(
    ethers.utils.parseEther("1000000") // 1M tokens max per investor
);

await compliance.connect(owner).setMinInvestment(
    ethers.utils.parseEther("1000") // 1K tokens minimum investment
);

await compliance.connect(owner).setMaxInvestors(100); // Max 100 holders

// Check current rules
const maxBalance = await compliance.getMaxBalancePerInvestor();
const minInvestment = await compliance.getMinInvestment();
const currentInvestors = await compliance.getCurrentInvestorCount();
```

### Country Management
```javascript
// Allow specific countries (as owner)
await compliance.connect(owner).setCountryAllowed(840, true); // US
await compliance.connect(owner).setCountryAllowed(276, true); // Germany

// Restrict problematic jurisdictions
await compliance.connect(owner).setCountryAllowed(408, false); // North Korea
```

### Validation Checks
```javascript
// Check if transfer would be valid before attempting
const [isValid, reason] = await compliance.validateTransfer(
    fromAddress,
    toAddress,
    ethers.utils.parseEther("5000")
);

if (!isValid) {
    console.log(`Transfer would fail: ${reason}`);
}
```

## Best Practices

### For Administrators
1. **Set Conservative Limits**: Start with stricter rules and relax as needed
2. **Monitor Compliance Rates**: Track validation failures and adjust rules
3. **Regular Rule Reviews**: Update rules as regulations change
4. **Document Exemptions**: Keep clear records of why exemptions were granted
5. **Test Rule Changes**: Validate new rules before deployment

### For Developers
1. **Validate Before Transactions**: Always check compliance before attempting transfers
2. **Handle Errors Gracefully**: Provide clear feedback on compliance failures
3. **Cache When Possible**: Cache validation results for better performance
4. **Monitor Events**: Track compliance events for debugging and reporting
5. **Plan for Updates**: Design systems that can adapt to rule changes

### for Compliance Officers
1. **Understand Jurisdictions**: Know the regulatory requirements for each target market
2. **Regular Audits**: Review compliance settings and effectiveness
3. **Stakeholder Communication**: Keep investors informed of compliance requirements
4. **Emergency Procedures**: Have plans for handling compliance violations
5. **Documentation**: Maintain detailed records for regulatory reporting

The Compliance Contract provides the regulatory backbone for our ERC-3643 implementation, ensuring that all token operations meet securities law requirements while remaining flexible enough to adapt to changing regulatory landscapes.

## Related Documentation
- [Token Contract](./TokenContract.md) - Token operations and compliance integration
- [Identity Contract](./IdentityContract.md) - Investor identity verification
- [ClaimTopics Contract](./ClaimTopicsContract.md) - Required verification types
- [TrustedIssuers Contract](./TrustedIssuersContract.md) - Authorized claim issuers
- [Roles Contract](./RolesContract.md) - Access control and permissions
- [Architecture Overview](./Architecture.md) - System architecture
- [Extending Protocol](./ExtendingProtocol.md) - Adding new compliance rules
