# ComplianceFacet Documentation

## Overview

The `ComplianceFacet` implements the **compliance and regulatory validation layer** for the T-REX security token system. This facet enforces business rules, investor limits, and regulatory constraints to ensure that token transfers comply with applicable securities regulations and token-specific requirements.

## Architecture & Purpose

### Primary Responsibilities
- **Regulatory Compliance**: Enforces balance limits, investor caps, and transfer restrictions
- **Business Rule Validation**: Implements configurable compliance parameters
- **Transfer Validation**: Provides pre-transfer compliance checking
- **Investor Limits**: Manages maximum investor count restrictions
- **Balance Constraints**: Enforces minimum and maximum balance requirements

### Regulatory Framework
The ComplianceFacet is designed to support various regulatory requirements:
- **Securities Laws**: Investor count limitations (e.g., Rule 506(b) - max 35 non-accredited)
- **AML/KYC**: Identity verification requirements
- **Concentration Limits**: Maximum balance per investor
- **Minimum Investment**: Threshold requirements for participation

## Storage Integration

Uses `AppStorage.compliance` struct containing:
```solidity
struct Compliance {
    uint256 maxBalance;      // Maximum tokens per investor
    uint256 minBalance;      // Minimum tokens per investor  
    uint256 maxInvestors;    // Maximum number of token holders
}
```

## Key Functions

### Configuration Functions (Owner Only)

#### Balance Limits
```solidity
function setMaxBalance(uint256 max) external onlyOwner
function setMinBalance(uint256 min) external onlyOwner
```
- **Purpose**: Set balance limits per investor
- **Use Cases**: 
  - Prevent concentration risk (maxBalance)
  - Enforce minimum investment thresholds (minBalance)
  - Regulatory compliance for distribution limits

#### Investor Limits
```solidity
function setMaxInvestors(uint256 max) external onlyOwner
```
- **Purpose**: Set maximum number of token holders
- **Use Cases**:
  - SEC Rule 506(b) compliance (35 non-accredited investors)
  - Private placement restrictions
  - Operational scalability limits

### Validation Functions

#### Transfer Compliance Check
```solidity
function canTransfer(address from, address to, uint256 amount) external view returns (bool)
```

**Validation Logic**:
1. **Freeze Check**: Ensures neither sender nor receiver is frozen
2. **Identity Verification**: Validates recipient has registered identity
3. **Balance Limits**: Checks resulting balance against min/max constraints
4. **Investor Count**: Verifies investor cap not exceeded for new holders

#### Compliance Rules Query
```solidity
function complianceRules() external view returns (uint256 maxBalance, uint256 minBalance, uint256 maxInvestors)
```
- Returns current compliance parameters
- Used by front-ends and other contracts for validation

## Validation Logic Details

### 1. Account Freeze Validation
```solidity
if (s.investors[from].isFrozen || s.investors[to].isFrozen) return false;
```
- Prevents transfers involving frozen accounts
- Integrates with TokenFacet freezing mechanism

### 2. Identity Verification
```solidity
if (s.investors[to].identity == address(0)) return false;
```
- Ensures recipient has registered identity contract
- Links to IdentityFacet for KYC/AML compliance

### 3. Balance Limit Enforcement
```solidity
uint256 newBalance = s.balances[to] + amount;
if (s.compliance.maxBalance > 0 && newBalance > s.compliance.maxBalance) return false;
if (s.compliance.minBalance > 0 && newBalance < s.compliance.minBalance) return false;
```
- **Max Balance**: Prevents concentration beyond regulatory limits
- **Min Balance**: Enforces minimum investment thresholds
- Zero values disable respective limits

### 4. Investor Count Management
```solidity
if (s.compliance.maxInvestors > 0 && s.balances[to] == 0) {
    uint256 count = 0;
    for (uint i = 0; i < s.holders.length; i++) {
        if (s.balances[s.holders[i]] > 0) count++;
    }
    if (count >= s.compliance.maxInvestors) return false;
}
```
- Counts current holders with non-zero balances
- Prevents new investors when limit reached
- Only applies to first-time recipients (balance == 0)

## Events

```solidity
event MaxBalanceSet(uint256 max);
event MinBalanceSet(uint256 min);
event MaxInvestorsSet(uint256 max);
```

These events provide audit trails for compliance parameter changes.

## Access Control

### Owner-Only Functions
- All configuration functions restricted to contract owner
- Uses `onlyOwner` modifier with storage-based ownership check
- Ensures only authorized parties can modify compliance rules

### View Functions
- `canTransfer` and `complianceRules` are public view functions
- Allow external validation without state modification
- Enable integration with other contracts and front-ends

## Integration with T-REX System

### TokenFacet Integration
- TokenFacet calls `canTransfer` before executing transfers
- Compliance validation happens at the protocol level
- Prevents non-compliant transfers from occurring

### IdentityFacet Coordination
- Relies on identity registration for recipient validation
- Ensures only verified investors can receive tokens
- Supports KYC/AML requirements

### RolesFacet Interaction
- Owner role management through shared storage
- Administrative privileges for compliance configuration
- Role-based access to configuration functions

## Regulatory Use Cases

### 1. Private Placement (Rule 506)
```solidity
// Limit to 35 non-accredited investors
complianceFacet.setMaxInvestors(35);

// Minimum investment threshold
complianceFacet.setMinBalance(25000 * 10**18); // $25k minimum
```

### 2. Concentration Risk Management
```solidity
// Prevent any single investor from holding >10%
uint256 maxHolding = totalSupply * 10 / 100;
complianceFacet.setMaxBalance(maxHolding);
```

### 3. Qualified Investor Requirements
```solidity
// $1M minimum for qualified investors
complianceFacet.setMinBalance(1000000 * 10**18);
```

## Security Considerations

### Access Control
- Only owner can modify compliance parameters
- Prevents unauthorized rule changes
- Maintains regulatory compliance integrity

### Validation Integrity
- All checks performed in `canTransfer` function
- Atomic validation prevents race conditions
- Consistent enforcement across all transfers

### Gas Optimization
- Investor count calculation could be expensive for large holder sets
- Consider implementing holder count tracking for gas efficiency
- Current implementation suitable for typical security token scales

## Upgradeability & Maintenance

### Rule Updates
- Compliance rules can be updated as regulations change
- Events provide audit trail of parameter modifications
- Zero values can disable specific constraints

### Storage Efficiency
- Compliance struct minimizes storage usage
- Shared storage pattern ensures consistency
- Future rule additions possible through storage expansion

### Monitoring & Reporting
- Events enable off-chain compliance monitoring
- `complianceRules` function supports compliance reporting
- Integration with external compliance systems possible

## Best Practices

1. **Regular Review**: Periodically review compliance parameters against current regulations
2. **Event Monitoring**: Track compliance events for audit purposes
3. **Testing**: Thoroughly test compliance rules before deployment
4. **Documentation**: Maintain clear documentation of regulatory requirements
5. **Legal Coordination**: Work with legal counsel when setting compliance parameters

## Common Compliance Scenarios

### Scenario 1: New Investor Onboarding
```solidity
// 1. Verify identity through IdentityFacet
// 2. Check investor count limits
// 3. Validate minimum investment amount
// 4. Execute compliant transfer
```

### Scenario 2: Secondary Market Transfer
```solidity
// 1. Verify both parties have valid identities
// 2. Check balance limits for recipient
// 3. Ensure neither party is frozen
// 4. Allow transfer if all checks pass
```

### Scenario 3: Regulatory Update
```solidity
// 1. Owner updates compliance parameters
// 2. Events logged for audit trail
// 3. New rules apply to future transfers
// 4. Existing holdings remain valid
```

The ComplianceFacet provides essential regulatory compliance functionality, ensuring that the T-REX token system meets securities regulations while maintaining operational flexibility for legitimate business needs.
