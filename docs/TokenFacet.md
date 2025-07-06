# TokenFacet

The **TokenFacet** provides the external interface for all token operations in the T-REX Diamond protocol. It implements the ERC-20 standard with ERC-3643 security token extensions, offering comprehensive token management functionality while maintaining clean separation between interface and business logic.

## Overview

TokenFacet serves as the user-facing interface for token operations, delegating complex business logic to TokenInternalFacet. This separation ensures clean API design, efficient gas usage, and maintainable code architecture within the Diamond pattern.

## Architecture

### Contract Structure
```
TokenFacet (External Interface)
├── TokenInternalFacet (Business Logic)
├── ITokenEvents (Events Interface)
├── ITokenErrors (Errors Interface)
└── Diamond Storage (Token Data)
```

### Design Pattern
- **External Interface**: Clean, ERC-20 compliant public API
- **Internal Logic**: Complex business rules and storage management
- **Modular Events**: Centralized event definitions
- **Custom Errors**: Gas-efficient error handling

## Core Functionality

### Standard ERC-20 Interface

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

### ERC-3643 Security Token Extensions

#### Administrative Functions
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
```solidity
function freezeAccount(address account) external onlyAgentOrOwner
function unfreezeAccount(address account) external onlyAgentOrOwner
function isFrozen(address account) external view returns (bool)
```

#### Compliance Integration
```solidity
function holderCount() external view returns (uint256)
function holderAt(uint256 index) external view returns (address)
```

## Access Control

### Permission Levels
- **Public**: Standard ERC-20 functions available to all users
- **Agent or Owner**: Administrative functions for authorized personnel
- **Internal**: Business logic accessible only within the Diamond

### Security Features
- Role-based access control through RolesInternalFacet
- Input validation with custom errors
- Compliance checks before state changes
- Event emission for audit trails

## Integration Patterns

### With ComplianceFacet
```solidity
// Transfer validation through compliance rules
function transfer(address to, uint256 amount) external returns (bool) {
    return _transfer(msg.sender, to, amount);
}

// Internal validation includes compliance checks
function _transfer(address from, address to, uint256 amount) internal {
    // Compliance validation happens in TokenInternalFacet
    ComplianceInternalFacet(address(this))._validateTransfer(from, to, amount);
    // ... transfer logic
}
```

### With IdentityFacet
```solidity
// Identity verification before operations
function mint(address to, uint256 amount) external onlyAgentOrOwner {
    // Verify recipient identity in TokenInternalFacet
    IdentityInternalFacet(address(this))._requireValidIdentity(to);
    _mint(to, amount);
}
```

## Events and Errors

### Standard ERC-20 Events
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

### ERC-3643 Extensions
```solidity
event Mint(address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event ForcedTransfer(address indexed from, address indexed to, uint256 value);
event AccountFrozen(address indexed account);
event AccountUnfrozen(address indexed account);
```

### Custom Errors
```solidity
error ZeroAddress();
error ZeroAmount();
error InsufficientBalance(address account, uint256 available, uint256 required);
error InsufficientAllowance(address owner, address spender, uint256 available, uint256 required);
error AccountFrozen(address account);
error ComplianceViolation(address from, address to, uint256 amount);
```

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

### Compliance-Aware Operations
```javascript
// Check compliance before transfer
try {
    await tokenFacet.transfer(recipient, amount);
    console.log("Transfer completed successfully");
} catch (error) {
    if (error.message.includes("ComplianceViolation")) {
        console.log("Transfer blocked by compliance rules");
    }
}
```

## Best Practices

### For Developers
1. **Validate inputs**: Always check addresses and amounts before operations
2. **Handle errors**: Implement proper error handling for custom errors
3. **Monitor events**: Listen to events for real-time updates
4. **Understand roles**: Verify user permissions before calling restricted functions

### For Administrators
1. **Identity verification**: Ensure all token holders have valid identities
2. **Compliance monitoring**: Regular compliance checks and rule updates
3. **Agent management**: Carefully manage agent permissions and access
4. **Audit trails**: Monitor all administrative actions through events

### For Integration
1. **Use interfaces**: Interact through well-defined interfaces
2. **Batch operations**: Group multiple operations for gas efficiency
3. **Error handling**: Implement comprehensive error handling
4. **State monitoring**: Track contract state changes through events

## Upgradeability and Migration

### Diamond Upgrades
- TokenFacet can be upgraded through DiamondCutFacet
- Storage remains intact during function upgrades
- New functionality can be added without affecting existing operations

### Migration Considerations
- Storage layout compatibility must be maintained
- Event signatures should remain consistent
- Access control patterns should be preserved

## Related Documentation
- [Token Contract](./TokenContract.md) - Complete token system overview
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Diamond architecture
- [Compliance Contract](./ComplianceContract.md) - Compliance integration
- [Identity Contract](./IdentityContract.md) - Identity management
- [Architecture Overview](./Architecture.md) - System architecture
- Storage remains persistent through `AppStorage`
- New functionality can be added without losing state
- Critical security functions should be carefully reviewed before upgrades

This facet provides the foundation for secure, compliant token operations within the T-REX framework, balancing ERC-20 compatibility with regulatory requirements for security tokens.
