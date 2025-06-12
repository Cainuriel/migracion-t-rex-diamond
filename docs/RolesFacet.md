# RolesFacet Documentation

## Overview

The `RolesFacet` provides **role-based access control (RBAC)** for the T-REX Diamond system, managing ownership and agent permissions across all facets. This facet establishes the foundational security layer that governs administrative access to critical system functions.

## Architecture & Purpose

### Primary Responsibilities
- **Ownership Management**: Single owner with ultimate administrative control
- **Agent Delegation**: Multi-agent system for operational task distribution
- **Access Control**: Provides modifiers for permission-restricted functions
- **Role Initialization**: Sets up initial ownership during deployment
- **Permission Auditing**: Events for tracking role changes

### Security Model
The RolesFacet implements a **hierarchical permission system**:
- **Owner**: Ultimate authority with all permissions
- **Agents**: Delegated authority for specific operational tasks
- **Users**: Standard token holders with basic transfer rights

## Storage Integration

Uses `AppStorage` for persistent role data:
```solidity
struct AppStorage {
    address owner;                    // Contract owner address
    mapping(address => bool) agents;  // Agent authorization mapping
    // ... other storage fields
}
```

## Key Functions

### Initialization

#### Role Setup
```solidity
function initializeRoles(address _owner) external initializer
```
- **Purpose**: Set initial contract owner during deployment
- **Security**: Uses OpenZeppelin's `initializer` modifier to prevent re-initialization
- **Event**: Emits `OwnershipTransferred(address(0), _owner)`
- **Usage**: Called once during contract deployment/upgrade

### Ownership Management

#### Ownership Transfer
```solidity
function transferOwnership(address _newOwner) external onlyOwner
```
- **Purpose**: Transfer ownership to a new address
- **Validation**: Prevents transfer to zero address
- **Security**: Only current owner can initiate transfer
- **Event**: Emits `OwnershipTransferred(previousOwner, newOwner)`
- **Atomicity**: Transfer is immediate and irreversible

#### Ownership Query
```solidity
function owner() external view returns (address)
```
- **Purpose**: Returns current owner address
- **Usage**: Used by other contracts and front-ends for access control
- **Transparency**: Public visibility for governance verification

### Agent Management

#### Agent Authorization
```solidity
function setAgent(address _agent, bool _status) external onlyOwner
```
- **Purpose**: Grant or revoke agent permissions
- **Parameters**:
  - `_agent`: Address to modify permissions for
  - `_status`: `true` to grant, `false` to revoke
- **Security**: Only owner can modify agent status
- **Event**: Emits `AgentSet(_agent, _status)`

#### Agent Status Query
```solidity
function isAgent(address _addr) external view returns (bool)
```
- **Purpose**: Check if address has agent permissions
- **Usage**: Used by other facets for access control validation
- **Returns**: `true` if address is authorized agent

## Access Control Modifiers

### Owner-Only Access
```solidity
modifier onlyOwner() {
    require(msg.sender == LibAppStorage.diamondStorage().owner, "RolesFacet: Not owner");
    _;
}
```
- **Usage**: Restricts functions to contract owner only
- **Applied to**: Critical administrative functions across all facets
- **Security**: Prevents unauthorized access to privileged operations

### Agent or Owner Access
```solidity
modifier onlyAgentOrOwner() {
    AppStorage storage s = LibAppStorage.diamondStorage();
    require(msg.sender == s.owner || s.agents[msg.sender], "RolesFacet: Not authorized");
    _;
}
```
- **Usage**: Allows both owner and authorized agents
- **Applied to**: Operational functions that can be delegated
- **Flexibility**: Enables operational scaling without compromising security

## Events

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event AgentSet(address indexed agent, bool status);
```

### Event Usage
- **Ownership Tracking**: Monitor ownership changes for governance
- **Agent Auditing**: Track agent appointments and revocations
- **Compliance**: Provide audit trails for regulatory requirements
- **Integration**: Enable off-chain monitoring and alerting

## Integration with T-REX System

### Cross-Facet Access Control

#### TokenFacet Integration
```solidity
// Administrative token operations
function mint(address to, uint256 amount) external onlyAgentOrOwner
function burn(address from, uint256 amount) external onlyAgentOrOwner
function forceTransfer(address from, address to, uint256 amount) external onlyAgentOrOwner
```

#### ComplianceFacet Integration
```solidity
// Compliance rule configuration
function setMaxBalance(uint256 max) external onlyOwner
function setMinBalance(uint256 min) external onlyOwner
function setMaxInvestors(uint256 max) external onlyOwner
```

#### IdentityFacet Integration
```solidity
// Identity management operations
function registerIdentity(address investor, address identity, uint16 country) external onlyAgentOrOwner
function updateIdentity(address investor, address newIdentity) external onlyAgentOrOwner
```

### Permission Distribution

| Function Category | Owner | Agent | User |
|------------------|-------|-------|------|
| Ownership Transfer | ✓ | ✗ | ✗ |
| Agent Management | ✓ | ✗ | ✗ |
| Compliance Rules | ✓ | ✗ | ✗ |
| Diamond Upgrades | ✓ | ✗ | ✗ |
| Identity Management | ✓ | ✓ | ✗ |
| Token Minting/Burning | ✓ | ✓ | ✗ |
| Account Freezing | ✓ | ✓ | ✗ |
| Standard Transfers | ✓ | ✓ | ✓ |

## Security Considerations

### Ownership Security
- **Single Point of Control**: Owner has ultimate authority
- **Transfer Risks**: Ownership transfer is immediate and irreversible
- **Zero Address Protection**: Prevents accidental ownership loss
- **Event Transparency**: All ownership changes are logged

### Agent Security
- **Revocable Permissions**: Owner can revoke agent status anytime
- **Granular Control**: Agent permissions are function-specific
- **No Self-Grant**: Agents cannot grant permissions to others
- **Audit Trail**: All agent changes are logged

### Access Control Integrity
- **Storage-Based**: Uses diamond storage for consistent state
- **Modifier Reuse**: Consistent access control across facets
- **Error Messages**: Clear error messages for debugging
- **Gas Efficiency**: Minimal gas overhead for access checks

## Operational Patterns

### 1. Initial Setup
```solidity
// Deploy Diamond with RolesFacet
// Initialize roles
rolesFacet.initializeRoles(deployerAddress);

// Set operational agents
rolesFacet.setAgent(kycAgentAddress, true);
rolesFacet.setAgent(complianceAgentAddress, true);
```

### 2. Agent Management
```solidity
// Grant agent permissions
rolesFacet.setAgent(newAgentAddress, true);

// Revoke agent permissions
rolesFacet.setAgent(oldAgentAddress, false);

// Check agent status
bool isAuthorized = rolesFacet.isAgent(agentAddress);
```

### 3. Ownership Transfer
```solidity
// Emergency ownership transfer
rolesFacet.transferOwnership(emergencyOwnerAddress);

// Planned governance transition
rolesFacet.transferOwnership(daoAddress);
```

## Governance Integration

### DAO Compatibility
- Owner role can be transferred to DAO contract
- Agent management through governance proposals
- Time-locked operations through DAO mechanisms
- Multi-signature wallet integration support

### Multi-Signature Integration
```solidity
// Owner set to multi-sig wallet
rolesFacet.transferOwnership(multiSigWalletAddress);

// Agent management requires multi-sig approval
// All owner functions require multiple signatures
```

## Best Practices

### 1. Owner Management
- **Secure Storage**: Use hardware wallets or multi-sig for owner key
- **Emergency Plans**: Establish clear ownership transfer procedures
- **Regular Reviews**: Periodically review ownership arrangements
- **Documentation**: Maintain clear records of ownership changes

### 2. Agent Management
- **Principle of Least Privilege**: Grant minimal necessary permissions
- **Regular Audits**: Review agent list periodically
- **Role Segregation**: Use different agents for different functions
- **Monitoring**: Track agent activities through events

### 3. Access Control
- **Consistent Application**: Use standard modifiers across all facets
- **Clear Documentation**: Document permission requirements
- **Error Handling**: Provide clear error messages for access failures
- **Testing**: Thoroughly test access control logic

## Common Use Cases

### 1. Operational Scaling
```solidity
// Separate agents for different operations
rolesFacet.setAgent(kycAgentAddress, true);      // Identity management
rolesFacet.setAgent(complianceAgentAddress, true); // Compliance operations
rolesFacet.setAgent(treasuryAgentAddress, true);   // Token operations
```

### 2. Emergency Response
```solidity
// Quickly revoke compromised agent
rolesFacet.setAgent(compromisedAgentAddress, false);

// Emergency ownership transfer
rolesFacet.transferOwnership(emergencyOwnerAddress);
```

### 3. Governance Transition
```solidity
// Transition from individual to DAO ownership
rolesFacet.transferOwnership(daoContractAddress);

// Maintain operational agents under DAO
// Agent management now requires DAO proposals
```

## Upgradeability Considerations

### Diamond Pattern Integration
- RolesFacet can be upgraded through DiamondCutFacet
- Storage layout must remain compatible during upgrades
- Access control logic should be backward compatible
- New role types can be added in future versions

### Migration Procedures
- Ownership and agent data persists through upgrades
- New versions must respect existing role assignments
- Initialization functions should handle upgrades gracefully
- Event schemas should remain consistent

The RolesFacet provides the essential foundation for secure, scalable access control in the T-REX Diamond system, enabling proper governance while maintaining operational flexibility.
