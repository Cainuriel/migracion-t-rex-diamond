# TokenFacet Documentation

## Overview

The `TokenFacet` is the core token functionality facet of the T-REX Diamond implementation, providing **ERC-20** standard compliance with enhanced **ERC-3643** (T-REX) features for security token management. This facet handles all token operations including transfers, minting, burning, and account freezing capabilities.

## Architecture & Purpose

### Primary Responsibilities
- **ERC-20 Compliance**: Implements standard token functions (transfer, approve, etc.)
- **Security Token Features**: Adds freezing, forced transfers, and compliance checks
- **Administrative Controls**: Provides mint/burn capabilities for authorized agents
- **Investor Management**: Integrates with investor registry for compliance validation

### Storage Integration
- Uses `LibAppStorage.diamondStorage()` for accessing shared state
- Manages token balances, allowances, and investor status
- Maintains total supply and metadata (name, symbol, decimals)

## Key Functions

### Standard ERC-20 Functions

#### View Functions
```solidity
function name() external view returns (string memory)
function symbol() external view returns (string memory) 
function decimals() external pure returns (uint8)
function totalSupply() external view returns (uint256)
function balanceOf(address account) public view returns (uint256)
function allowance(address owner_, address spender) external view returns (uint256)
```

#### Transfer Functions
```solidity
function transfer(address to, uint256 amount) external returns (bool)
function transferFrom(address from, address to, uint256 amount) external returns (bool)
function approve(address spender, uint256 amount) external returns (bool)
```

### Security Token Extensions

#### Administrative Functions (onlyAgentOrOwner)
```solidity
function mint(address to, uint256 amount) external onlyAgentOrOwner
function burn(address from, uint256 amount) external onlyAgentOrOwner
function forceTransfer(address from, address to, uint256 amount) external onlyAgentOrOwner
```

#### Account Management
```solidity
function freezeAccount(address user) external onlyAgentOrOwner
function unfreezeAccount(address user) external onlyAgentOrOwner
```

## Access Control

### Modifiers
- **`onlyAgentOrOwner`**: Restricts access to contract owner or authorized agents
  - Checks `s.owner == msg.sender` or `s.agents[msg.sender] == true`
  - Used for administrative functions (mint, burn, freeze, forceTransfer)

## Key Features

### 1. Enhanced Transfer Logic
The `_transfer` internal function includes security checks:
- **Freeze Validation**: Prevents transfers from/to frozen accounts
- **Balance Verification**: Ensures sufficient balance before transfer
- **Event Emission**: Emits Transfer events for transparency

### 2. Account Freezing
```solidity
function freezeAccount(address user) external onlyAgentOrOwner {
    LibAppStorage.diamondStorage().investors[user].isFrozen = true;
    emit AccountFrozen(user, true);
}
```
- Sets `investors[user].isFrozen = true`
- Prevents the account from sending or receiving tokens
- Emits `AccountFrozen` event for off-chain tracking

### 3. Administrative Controls
- **Minting**: Increases total supply and recipient balance
- **Burning**: Decreases balance and total supply with validation
- **Force Transfer**: Bypasses normal transfer restrictions for regulatory compliance

### 4. Compliance Integration
- Works with `ComplianceFacet` for transfer validation
- Integrates with `IdentityFacet` for KYC/AML verification
- Supports regulatory requirements through freezing mechanism

## Events

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event AccountFrozen(address indexed user, bool frozen);
```

## Security Considerations

### Access Control
- Critical functions protected by `onlyAgentOrOwner` modifier
- Agent system allows delegation of administrative privileges
- Owner maintains ultimate control over all operations

### Transfer Safety
- Frozen account checks prevent unauthorized movements
- Balance validation prevents over-spending
- Allowance system maintains ERC-20 compatibility

### State Consistency
- Uses diamond storage pattern for consistent state access
- Atomic operations ensure state integrity
- Event emission provides audit trail

## Integration with T-REX System

### Compliance Layer
- All transfers can be subject to compliance rules (via ComplianceFacet)
- Identity verification requirements (via IdentityFacet)
- Trusted issuer validation for claims

### Role-Based Permissions
- Works with `RolesFacet` for granular permission management
- Agent system allows operational delegation
- Owner retains administrative oversight

### Storage Coordination
- Shares `AppStorage` with other facets
- Maintains consistency across investor registry
- Coordinates with compliance and identity systems

## Usage Examples

### Basic Token Operations
```solidity
// Transfer tokens
tokenFacet.transfer(recipient, 1000 * 10**18);

// Approve spending
tokenFacet.approve(spender, 500 * 10**18);

// Transfer from approved amount
tokenFacet.transferFrom(owner, recipient, 250 * 10**18);
```

### Administrative Operations
```solidity
// Mint new tokens (agent/owner only)
tokenFacet.mint(investor, 10000 * 10**18);

// Freeze problematic account
tokenFacet.freezeAccount(suspiciousAddress);

// Force transfer for compliance
tokenFacet.forceTransfer(violator, treasury, balance);
```

## Best Practices

1. **Always verify identity**: Ensure recipients have valid identity claims
2. **Check compliance**: Validate transfers meet regulatory requirements  
3. **Monitor frozen accounts**: Track freezing events for audit trails
4. **Manage agent roles**: Regularly review agent permissions
5. **Coordinate with facets**: Ensure consistency across the diamond system

## Upgradeability

The TokenFacet can be upgraded through the Diamond pattern:
- Function selectors can be modified via `DiamondCutFacet`
- Storage remains persistent through `AppStorage`
- New functionality can be added without losing state
- Critical security functions should be carefully reviewed before upgrades

This facet provides the foundation for secure, compliant token operations within the T-REX framework, balancing ERC-20 compatibility with regulatory requirements for security tokens.
