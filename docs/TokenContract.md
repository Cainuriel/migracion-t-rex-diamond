# Token Contract - ERC-20 + ERC-3643 Core

## Overview

The **Token Contract** forms the heart of our ERC-3643 implementation, providing both standard **ERC-20** functionality and **security token** features required for regulatory compliance. It's implemented using two facets that work together to deliver a complete token system.

## Architecture

### Dual Facet Implementation

```
┌─────────────────┐    ┌─────────────────┐
│   TokenFacet    │────│TokenInternalFacet│
│   (External)    │    │   (Internal)     │
├─────────────────┤    ├─────────────────┤
│ Public ERC-20   │    │ Business Logic   │
│ Interface       │    │ & Storage        │
└─────────────────┘    └─────────────────┘
```

**TokenFacet** (External)
- **File**: `contracts/facets/TokenFacet.sol`
- **Purpose**: Public-facing ERC-20 interface
- **Responsibilities**: Input validation, access control, event emission
- **Users**: Wallets, exchanges, dApps, end users

**TokenInternalFacet** (Internal)  
- **File**: `contracts/facets/internal/TokenInternalFacet.sol`
- **Purpose**: Core business logic and storage management
- **Responsibilities**: Balance management, compliance integration, cross-facet communication
- **Users**: Other facets within the diamond system

## ERC-20 Standard Functions

### Core Transfer Functions

#### `transfer(address to, uint256 amount)`
```solidity
function transfer(address to, uint256 amount) external returns (bool)
```
- **Purpose**: Transfer tokens between addresses
- **Compliance**: Validates transfer against compliance rules
- **Access**: Public (with compliance checks)
- **Events**: Emits `Transfer(from, to, amount)`

**Implementation Flow:**
1. Input validation (non-zero address, sufficient balance)
2. Compliance validation via ComplianceInternalFacet
3. Identity verification via IdentityInternalFacet  
4. Balance updates via TokenInternalFacet
5. Event emission

#### `transferFrom(address from, address to, uint256 amount)`
```solidity
function transferFrom(address from, address to, uint256 amount) external returns (bool)
```
- **Purpose**: Transfer tokens on behalf of another address
- **Compliance**: Same validation as transfer() plus allowance check
- **Access**: Public (requires prior approval)
- **Events**: Emits `Transfer(from, to, amount)`

#### `approve(address spender, uint256 amount)`
```solidity
function approve(address spender, uint256 amount) external returns (bool)
```
- **Purpose**: Authorize another address to spend tokens
- **Compliance**: Validates spender identity if required
- **Access**: Public
- **Events**: Emits `Approval(owner, spender, amount)`

### Query Functions

#### `balanceOf(address account)`
```solidity
function balanceOf(address account) external view returns (uint256)
```
- **Purpose**: Get token balance for an address
- **Access**: Public view function
- **Returns**: Token balance (18 decimals)

#### `totalSupply()`
```solidity
function totalSupply() external view returns (uint256)
```
- **Purpose**: Get total token supply
- **Access**: Public view function
- **Returns**: Total tokens in circulation

#### `allowance(address owner, address spender)`
```solidity
function allowance(address owner, address spender) external view returns (uint256)
```
- **Purpose**: Get approved spending amount
- **Access**: Public view function
- **Returns**: Approved amount for spender

### Metadata Functions

#### `name()`, `symbol()`, `decimals()`
```solidity
function name() external view returns (string memory)
function symbol() external view returns (string memory)  
function decimals() external view returns (uint8)
```
- **Purpose**: Token metadata
- **Access**: Public view functions
- **Returns**: "T-REX Security Token", "TREX", 18

## ERC-3643 Security Token Extensions

### Administrative Functions

#### `mint(address to, uint256 amount)`
```solidity
function mint(address to, uint256 amount) external onlyAgent
```
- **Purpose**: Create new tokens and assign to address
- **Access**: Agents only (configured via RolesFacet)
- **Validation**: Compliance rules, identity verification
- **Events**: Emits `Transfer(address(0), to, amount)`

**Pre-conditions:**
- Caller must be authorized agent
- Recipient must have verified identity
- Must comply with investment limits
- Recipient cannot be frozen

#### `burn(address from, uint256 amount)`
```solidity
function burn(address from, uint256 amount) external onlyAgent
```
- **Purpose**: Destroy tokens from an address
- **Access**: Agents only
- **Validation**: Sufficient balance, compliance rules
- **Events**: Emits `Transfer(from, address(0), amount)`

### Account Management

#### `freeze(address account)`
```solidity
function freeze(address account) external onlyAgent
```
- **Purpose**: Freeze an account (prevent all transfers)
- **Access**: Agents only
- **Effect**: Account cannot transfer or receive tokens
- **Events**: Emits `AccountFrozen(account)`

#### `unfreeze(address account)`
```solidity
function unfreeze(address account) external onlyAgent
```
- **Purpose**: Unfreeze a previously frozen account
- **Access**: Agents only
- **Effect**: Restore normal transfer capabilities
- **Events**: Emits `AccountUnfrozen(account)`

#### `isFrozen(address account)`
```solidity
function isFrozen(address account) external view returns (bool)
```
- **Purpose**: Check if an account is frozen
- **Access**: Public view function
- **Returns**: True if account is frozen

### Compliance Integration

#### Transfer Validation Process
Every transfer (including mint) goes through comprehensive validation:

```
1. Input Validation
   ├── Non-zero addresses
   ├── Non-zero amounts  
   └── Sufficient balances

2. Access Control
   ├── Not frozen accounts
   ├── Authorized operations
   └── Agent permissions

3. Compliance Validation  
   ├── Investment limits
   ├── Investor caps
   ├── Regulatory rules
   └── Jurisdiction restrictions

4. Identity Verification
   ├── KYC status
   ├── AML clearance
   ├── Required claims
   └── Trusted issuers

5. Execution
   ├── Balance updates
   ├── Holder tracking
   ├── Event emission
   └── State consistency
```

## Storage Architecture

### TokenStorage Structure
```solidity
struct TokenStorage {
    // === ERC-20 CORE ===
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    
    // === ERC-3643 EXTENSIONS ===
    mapping(address => bool) frozenAccounts;
    address[] holders; // Track all token holders for compliance
}
```

**Storage Location**: `keccak256("token.storage.location")`

### Key Storage Features

#### Balance Management
- **Direct Mapping**: `mapping(address => uint256) balances`
- **Allowance Tracking**: Nested mapping for ERC-20 approvals
- **Total Supply**: Global counter maintained automatically

#### Holder Tracking
- **Holder Array**: Maintains list of all addresses with tokens
- **Compliance Integration**: Used for dividend distributions, voting, compliance checks
- **Gas Optimization**: Array management optimized for add/remove operations

#### Freeze Status
- **Freeze Mapping**: `mapping(address => bool) frozenAccounts`
- **Transfer Blocking**: Checked on every transfer operation
- **Agent Control**: Only agents can freeze/unfreeze accounts

## Integration with Other Facets

### Compliance Integration
```solidity
// Before any transfer
ComplianceInternalFacet compliance = ComplianceInternalFacet(address(this));
bool isValid = compliance._validateTransfer(from, to, amount);
if (!isValid) revert ComplianceViolation(from, to, amount);
```

**Validation Checks:**
- Maximum balance per investor
- Minimum investment amounts
- Maximum number of investors
- Country restrictions
- Time-based restrictions

### Identity Integration
```solidity
// Verify identity before operations
IdentityInternalFacet identity = IdentityInternalFacet(address(this));
bool isVerified = identity._isVerified(to);
if (!isVerified) revert IdentityNotVerified(to);
```

**Identity Checks:**
- KYC/AML status
- Required claim topics
- Trusted issuer validation
- Identity contract registration

### Roles Integration
```solidity
// Access control for administrative functions
RolesInternalFacet roles = RolesInternalFacet(address(this));
if (!roles._isAgent(msg.sender)) revert Unauthorized(msg.sender);
```

**Permission Levels:**
- **Owner**: Contract administration, agent management
- **Agents**: Token operations (mint, burn, freeze)
- **Users**: Standard ERC-20 operations (transfer, approve)

## Error Handling

### Custom Errors
The token system uses custom errors for better UX and gas efficiency:

```solidity
// Address validation
error ZeroAddress();

// Amount validation  
error ZeroAmount();
error InsufficientBalance(address account, uint256 requested, uint256 available);

// Access control
error Unauthorized(address caller);
error AccountFrozen(address account);

// Compliance violations
error ComplianceViolation(address from, address to, uint256 amount);
error IdentityNotVerified(address account);
error InvestmentLimitExceeded(address investor, uint256 currentBalance, uint256 attemptedTransfer, uint256 limit);
```

### Error Context
Errors include relevant context to help users understand the issue:

```solidity
// Instead of generic "transfer failed"
if (balance < amount) {
    revert InsufficientBalance(from, amount, balance);
}

// Instead of "not authorized"  
if (isFrozen(from)) {
    revert AccountFrozen(from);
}
```

## Events

### ERC-20 Standard Events
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

### ERC-3643 Extended Events
```solidity
event AccountFrozen(address indexed account);
event AccountUnfrozen(address indexed account);
event TokenMinted(address indexed to, uint256 amount);
event TokenBurned(address indexed from, uint256 amount);
```

### Compliance Events
```solidity
event TransferValidated(address indexed from, address indexed to, uint256 amount);
event ComplianceCheckPassed(address indexed account, string checkType);
```

## Gas Optimization

### Storage Efficiency
- **Packed Structs**: Efficient storage layout
- **Direct Access**: Minimal delegatecall overhead
- **Batch Operations**: Support for multiple operations in single transaction

### Transfer Optimization
- **Early Validation**: Fail fast on invalid inputs
- **Minimal External Calls**: Reduce cross-contract communication
- **Event Batching**: Efficient event emission

### Holder Management
- **Lazy Updates**: Only update holder list when necessary
- **Swap-and-Pop**: Efficient array element removal
- **Gas Limits**: Prevent unbounded loops

## Security Features

### Reentrancy Protection
- **Checks-Effects-Interactions**: Proper ordering of operations
- **State Consistency**: Atomic balance updates
- **External Call Safety**: Careful handling of external integrations

### Access Control
- **Role-Based Permissions**: Multi-level access control
- **Function-Level Security**: Each function protected appropriately
- **Owner Controls**: Administrative functions protected

### Input Validation
- **Address Validation**: Prevent zero address operations
- **Amount Validation**: Prevent zero/negative amounts
- **Balance Validation**: Ensure sufficient funds before operations

## Current Implementation Status

### ✅ Completed Features
- **Full ERC-20**: All standard functions implemented
- **Basic Minting/Burning**: Agent-controlled token creation/destruction
- **Account Freezing**: Prevent transfers for compliance
- **Compliance Integration**: Basic transfer validation
- **Custom Errors**: Improved error handling
- **Event System**: Comprehensive event emission

### 🔄 Partial Features
- **Holder Tracking**: Basic implementation (could be optimized)
- **Historical Balances**: Not implemented (needed for dividends)
- **Batch Operations**: Not implemented (could improve efficiency)

### ❌ Future Enhancements
- **Dividend Distribution**: Integration with dividend system
- **Voting Rights**: Token-based governance features
- **Time-Locked Transfers**: Scheduled transfers
- **Fractional Tokens**: Sub-unit token divisions

## Integration Examples

### Basic Token Operations
```javascript
// Get token information
const name = await token.name();
const symbol = await token.symbol();
const decimals = await token.decimals();
const totalSupply = await token.totalSupply();

// Check balance
const balance = await token.balanceOf(userAddress);

// Transfer tokens (as user)
await token.connect(user).transfer(recipientAddress, amount);

// Approve spending (as user)
await token.connect(user).approve(spenderAddress, amount);

// Transfer on behalf (as approved spender)
await token.connect(spender).transferFrom(userAddress, recipientAddress, amount);
```

### Administrative Operations
```javascript
// Mint tokens (as agent)
await token.connect(agent).mint(investorAddress, mintAmount);

// Freeze account (as agent)
await token.connect(agent).freeze(suspiciousAddress);

// Check frozen status
const isFrozen = await token.isFrozen(address);

// Unfreeze account (as agent)
await token.connect(agent).unfreeze(address);

// Burn tokens (as agent)
await token.connect(agent).burn(address, burnAmount);
```

### Compliance Checks
```javascript
// These checks happen automatically during transfers
// but you can query the status

// Check if transfer would be valid
const isValid = await compliance.validateTransfer(from, to, amount);

// Check identity verification
const isVerified = await identity.isVerified(address);

// Check if address is agent
const isAgent = await roles.isAgent(address);
```

## Best Practices

### For Developers
1. **Always validate inputs** before calling token functions
2. **Handle custom errors** appropriately in your UI
3. **Check compliance status** before attempting transfers
4. **Use events** to track token operations
5. **Test with frozen accounts** to ensure proper handling

### For Integrators  
1. **Support ERC-20 interface** for basic compatibility
2. **Handle compliance failures** gracefully
3. **Monitor freeze events** for account status changes
4. **Implement proper access controls** for administrative functions
5. **Test edge cases** like zero amounts, insufficient balances

### For Administrators
1. **Manage agent permissions** carefully
2. **Monitor compliance violations** through events
3. **Implement proper procedures** for account freezing
4. **Keep identity verification** up to date
5. **Plan for emergency procedures** (mass freezing, etc.)

The Token Contract provides a solid foundation for regulatory-compliant security tokens while maintaining compatibility with the broader Ethereum ecosystem through standard ERC-20 interfaces.

## Related Documentation
- [TokenFacet](./TokenFacet.md) - External token interface implementation
- [Identity Contract](./IdentityContract.md) - Identity verification integration
- [Compliance Contract](./ComplianceContract.md) - Compliance rules and validation
- [Roles Contract](./RolesContract.md) - Access control and permissions
- [Architecture Overview](./Architecture.md) - System architecture
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Diamond pattern implementation
