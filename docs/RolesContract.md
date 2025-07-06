# Roles Contract - Permissions & Access Control System

## Overview

The **Roles Contract** implements a comprehensive **access control system** for our ERC-3643 security token. It manages different permission levels throughout the system, ensuring that only authorized parties can perform administrative and operational functions. This contract forms the security backbone that protects all sensitive operations.

## Access Control Model

Our system implements a **hierarchical permission model** with three main levels:

### 1. **Owner** (Highest Authority)
- **Single Address**: Only one owner at a time
- **Full Control**: Can perform all administrative functions
- **Agent Management**: Can add/remove agents
- **System Configuration**: Can modify all system parameters
- **Upgrade Authority**: Can upgrade diamond facets
- **Emergency Powers**: Can freeze system, handle emergencies

### 2. **Agents** (Operational Authority) 
- **Multiple Addresses**: Multiple agents can be active
- **Token Operations**: Can mint, burn, freeze accounts
- **Identity Management**: Can register investor identities
- **Compliance Operations**: Can manage some compliance rules
- **Limited Scope**: Cannot modify core system parameters

### 3. **Users** (Standard Access)
- **All Other Addresses**: Default permission level
- **Token Transfers**: Can transfer tokens (subject to compliance)
- **Standard ERC-20**: Can approve, check balances, etc.
- **Read Access**: Can query system information

## Architecture

### Dual Facet Implementation

```
┌─────────────────┐    ┌─────────────────┐
│   RolesFacet    │────│ RolesInternalFacet │
│   (External)    │    │    (Internal)     │
├─────────────────┤    ├─────────────────┤
│ Role Management │    │ Logic & Storage  │
│ Permission Queries   │ Authorization Logic│
│ Administrative  │    │ Cross-integration │
└─────────────────┘    └─────────────────┘
```

**RolesFacet** (External)
- **File**: `contracts/facets/RolesFacet.sol`
- **Purpose**: Public role management interface
- **Responsibilities**: Agent management, permission queries, role configuration
- **Users**: Owner, administrators, external systems

**RolesInternalFacet** (Internal)
- **File**: `contracts/facets/internal/RolesInternalFacet.sol`
- **Purpose**: Core authorization logic and storage management
- **Responsibilities**: Permission validation, role storage, cross-facet integration
- **Users**: Other facets within the diamond system

## Core Functions

### Owner Management

#### `owner()`
```solidity
function owner() external view returns (address)
```
- **Purpose**: Get current contract owner
- **Access**: Public view function
- **Integration**: Uses LibDiamond.contractOwner()
- **Returns**: Current owner address

#### `transferOwnership(address newOwner)`
```solidity
function transferOwnership(address newOwner) external onlyOwner
```
- **Purpose**: Transfer ownership to a new address
- **Access**: Owner only
- **Validation**: New owner cannot be zero address
- **Events**: Emits `OwnershipTransferred(oldOwner, newOwner)`
- **Security**: Critical function for system control

### Agent Management

#### `setAgent(address agent, bool status)`
```solidity
function setAgent(address agent, bool status) external onlyOwner
```
- **Purpose**: Grant or revoke agent status
- **Access**: Owner only
- **Parameters**: 
  - `agent`: Address to modify
  - `status`: True to grant, false to revoke
- **Events**: Emits `AgentStatusChanged(agent, status)`
- **Validation**: Agent cannot be zero address

#### `isAgent(address account)`
```solidity
function isAgent(address account) external view returns (bool)
```
- **Purpose**: Check if an address has agent permissions
- **Access**: Public view function
- **Usage**: Used throughout system for access control
- **Returns**: True if address is an authorized agent

#### `getAgents()`
```solidity
function getAgents() external view returns (address[] memory)
```
- **Purpose**: Get list of all current agents
- **Access**: Public view function
- **Returns**: Array of all agent addresses
- **Usage**: For administrative oversight and UI display

### Batch Operations

#### `batchSetAgents(address[] agents, bool[] statuses)`
```solidity
function batchSetAgents(
    address[] calldata agents, 
    bool[] calldata statuses
) external onlyOwner
```
- **Purpose**: Set multiple agent statuses in one transaction
- **Access**: Owner only
- **Validation**: Arrays must be same length
- **Gas Optimization**: Reduces transaction costs for bulk operations
- **Events**: Emits `AgentStatusChanged` for each change

## Roles Storage Architecture

### RolesStorage Structure
```solidity
struct RolesStorage {
    // === CORE PERMISSIONS ===
    mapping(address => bool) agents;
    address[] agentList;
    
    // === PERMISSION TRACKING ===
    mapping(address => uint256) permissionLevels;
    mapping(address => string[]) grantedPermissions;
    mapping(address => uint256) lastPermissionUpdate;
    
    // === ROLE HISTORY ===
    mapping(address => uint256) agentSince;
    mapping(address => uint256) agentUntil;
    
    // === ADVANCED PERMISSIONS ===
    mapping(bytes32 => mapping(address => bool)) customPermissions;
    mapping(bytes32 => string) permissionDescriptions;
    
    // === STATISTICS ===
    uint256 totalAgentsEver;
    uint256 currentActiveAgents;
    mapping(address => uint256) actionCounts;
}
```

**Storage Location**: `keccak256("roles.storage.location")`

### Key Storage Features

#### Agent Tracking
- **Agent Mapping**: `mapping(address => bool) agents` - Quick permission checks
- **Agent List**: `address[] agentList` - Enumerable list for queries
- **History Tracking**: Record when agent status was granted/revoked

#### Permission Levels
- **Level System**: Numeric permission levels for future extensibility
- **Custom Permissions**: Support for granular permissions beyond basic agent/user
- **Permission Descriptions**: Human-readable descriptions for complex permissions

#### Activity Tracking
- **Action Counts**: Track how many actions each agent has performed
- **Time Tracking**: Record when permissions were last updated
- **Statistics**: Overall system usage metrics

## Authorization Patterns

### Basic Permission Checks
```solidity
// Owner-only functions
modifier onlyOwner() {
    if (msg.sender != LibDiamond.contractOwner()) {
        revert Unauthorized(msg.sender);
    }
    _;
}

// Agent-only functions
modifier onlyAgent() {
    RolesStorage storage rs = _getRolesStorage();
    if (!rs.agents[msg.sender]) {
        revert Unauthorized(msg.sender);
    }
    _;
}

// Owner or agent functions
modifier onlyAuthorized() {
    if (msg.sender != LibDiamond.contractOwner()) {
        RolesStorage storage rs = _getRolesStorage();
        if (!rs.agents[msg.sender]) {
            revert Unauthorized(msg.sender);
        }
    }
    _;
}
```

### Advanced Permission System
```solidity
// Custom permission checks
modifier requiresPermission(bytes32 permission) {
    if (!_hasPermission(msg.sender, permission)) {
        revert InsufficientPermission(msg.sender, permission);
    }
    _;
}

function _hasPermission(address account, bytes32 permission) 
    internal view returns (bool) {
    
    // Owner has all permissions
    if (account == LibDiamond.contractOwner()) return true;
    
    // Check basic agent permission
    RolesStorage storage rs = _getRolesStorage();
    if (permission == AGENT_PERMISSION) {
        return rs.agents[account];
    }
    
    // Check custom permissions
    return rs.customPermissions[permission][account];
}
```

## Integration Across System

### Token Operations
```solidity
// In TokenFacet - only agents can mint
function mint(address to, uint256 amount) external {
    RolesInternalFacet roles = RolesInternalFacet(address(this));
    if (!roles._isAgent(msg.sender)) {
        revert Unauthorized(msg.sender);
    }
    
    // Continue with mint logic...
}

// In TokenFacet - only agents can burn
function burn(address from, uint256 amount) external {
    RolesInternalFacet roles = RolesInternalFacet(address(this));
    if (!roles._isAgent(msg.sender)) {
        revert Unauthorized(msg.sender);
    }
    
    // Continue with burn logic...
}
```

### Identity Management
```solidity
// In IdentityFacet - only agents can register identities
function registerIdentity(address investor, address identity) external {
    RolesInternalFacet roles = RolesInternalFacet(address(this));
    if (!roles._isAgent(msg.sender)) {
        revert Unauthorized(msg.sender);
    }
    
    // Continue with registration logic...
}
```

### Compliance Configuration
```solidity
// In ComplianceFacet - only owner can set major rules
function setMaxBalancePerInvestor(uint256 maxBalance) external {
    if (msg.sender != LibDiamond.contractOwner()) {
        revert Unauthorized(msg.sender);
    }
    
    // Continue with configuration...
}

// Some compliance operations may be agent-accessible
function setInvestorLockup(address investor, uint256 endTime) external {
    RolesInternalFacet roles = RolesInternalFacet(address(this));
    if (!roles._isAgent(msg.sender)) {
        revert Unauthorized(msg.sender);
    }
    
    // Continue with lockup setting...
}
```

## Permission Levels

### Level 0: Users (Default)
```solidity
uint256 constant USER_LEVEL = 0;
```
**Permissions:**
- Transfer tokens (subject to compliance)
- Approve token spending
- Query balances and allowances
- View public information

**Cannot:**
- Mint or burn tokens
- Freeze accounts
- Modify system configuration
- Access administrative functions

### Level 1: Agents
```solidity
uint256 constant AGENT_LEVEL = 1;
```
**Permissions:**
- All user permissions
- Mint tokens to verified investors
- Burn tokens from accounts
- Freeze/unfreeze accounts
- Register investor identities
- Set investor-specific compliance rules

**Cannot:**
- Modify core system parameters
- Add/remove other agents
- Transfer ownership
- Upgrade system contracts

### Level 2: Owner
```solidity
uint256 constant OWNER_LEVEL = 2;
```
**Permissions:**
- All agent permissions
- Add/remove agents
- Modify compliance rules
- Configure claim topics
- Manage trusted issuers
- Transfer ownership
- Upgrade system contracts
- Emergency controls

## Advanced Features

### Custom Permissions
```solidity
// Define custom permission constants
bytes32 constant MINT_PERMISSION = keccak256("MINT_TOKENS");
bytes32 constant BURN_PERMISSION = keccak256("BURN_TOKENS");
bytes32 constant FREEZE_PERMISSION = keccak256("FREEZE_ACCOUNTS");
bytes32 constant COMPLIANCE_PERMISSION = keccak256("MODIFY_COMPLIANCE");

function grantCustomPermission(
    address account, 
    bytes32 permission, 
    string calldata description
) external onlyOwner {
    RolesStorage storage rs = _getRolesStorage();
    rs.customPermissions[permission][account] = true;
    rs.permissionDescriptions[permission] = description;
    
    emit CustomPermissionGranted(account, permission, description);
}
```

### Role History Tracking
```solidity
function _recordRoleChange(address account, bool isAgent) internal {
    RolesStorage storage rs = _getRolesStorage();
    
    if (isAgent) {
        rs.agentSince[account] = block.timestamp;
        rs.agentUntil[account] = 0; // Clear revocation time
        rs.totalAgentsEver++;
        rs.currentActiveAgents++;
    } else {
        rs.agentUntil[account] = block.timestamp;
        rs.currentActiveAgents--;
    }
    
    rs.lastPermissionUpdate[account] = block.timestamp;
}

function getAgentHistory(address account) external view returns (
    uint256 grantedAt,
    uint256 revokedAt,
    bool isCurrentlyAgent
) {
    RolesStorage storage rs = _getRolesStorage();
    return (
        rs.agentSince[account],
        rs.agentUntil[account],
        rs.agents[account]
    );
}
```

### Emergency Controls
```solidity
function emergencyPause() external onlyOwner {
    // Implementation would set emergency flags
    // that other facets check before operations
    emit EmergencyPaused(msg.sender, block.timestamp);
}

function emergencyUnpause() external onlyOwner {
    // Clear emergency flags
    emit EmergencyUnpaused(msg.sender, block.timestamp);
}
```

## Events

### Core Role Events
```solidity
event OwnershipTransferred(
    address indexed previousOwner, 
    address indexed newOwner
);

event AgentStatusChanged(
    address indexed agent, 
    bool status, 
    address indexed changedBy
);

event BatchAgentUpdate(
    address[] agents, 
    bool[] statuses, 
    uint256 successCount
);
```

### Permission Events
```solidity
event CustomPermissionGranted(
    address indexed account,
    bytes32 indexed permission,
    string description
);

event CustomPermissionRevoked(
    address indexed account,
    bytes32 indexed permission
);

event PermissionLevelChanged(
    address indexed account,
    uint256 oldLevel,
    uint256 newLevel
);
```

### Administrative Events
```solidity
event EmergencyPaused(address indexed by, uint256 timestamp);
event EmergencyUnpaused(address indexed by, uint256 timestamp);

event SystemAction(
    address indexed performer,
    string actionType,
    bytes data
);
```

## Error Handling

### Custom Errors
```solidity
// Basic authorization errors
error Unauthorized(address caller);
error InsufficientPermission(address caller, bytes32 permission);

// Role management errors
error InvalidAgent(address agent);
error AgentAlreadyExists(address agent);
error AgentNotFound(address agent);

// Ownership errors
error InvalidOwner(address owner);
error OwnershipTransferFailed(address from, address to);

// Emergency errors
error SystemPaused();
error EmergencyOnly();

// Batch operation errors
error ArrayLengthMismatch(uint256 length1, uint256 length2);
error BatchOperationFailed(uint256 index, address account);
```

### Detailed Authorization Context
```solidity
function _requireAuthorization(address caller, string memory operation) 
    internal view {
    
    // Check if owner
    if (caller == LibDiamond.contractOwner()) return;
    
    // Check if agent
    RolesStorage storage rs = _getRolesStorage();
    if (rs.agents[caller]) return;
    
    // Provide specific error with context
    revert UnauthorizedOperation(caller, operation, "Requires agent or owner");
}
```

## Gas Optimization

### Efficient Permission Checks
```solidity
// Cache repeated permission checks
mapping(address => uint256) private _permissionCache;
mapping(address => uint256) private _cacheBlock;

function _isAgentCached(address account) internal view returns (bool) {
    // Use cache if from same block
    if (_cacheBlock[account] == block.number) {
        return _permissionCache[account] == 1;
    }
    
    // Perform check and cache result
    RolesStorage storage rs = _getRolesStorage();
    bool result = rs.agents[account];
    
    _permissionCache[account] = result ? 1 : 0;
    _cacheBlock[account] = block.number;
    
    return result;
}
```

### Batch Processing
```solidity
function _batchSetAgents(address[] calldata agents, bool[] calldata statuses) 
    internal {
    
    require(agents.length == statuses.length, "Array length mismatch");
    
    RolesStorage storage rs = _getRolesStorage();
    uint256 changes = 0;
    
    for (uint i = 0; i < agents.length; i++) {
        if (agents[i] != address(0) && rs.agents[agents[i]] != statuses[i]) {
            rs.agents[agents[i]] = statuses[i];
            _updateAgentList(agents[i], statuses[i]);
            changes++;
            
            emit AgentStatusChanged(agents[i], statuses[i], msg.sender);
        }
    }
    
    emit BatchAgentUpdate(agents, statuses, changes);
}
```

## Security Considerations

### Ownership Protection
```solidity
// Prevent accidental ownership renunciation
function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "New owner cannot be zero address");
    require(newOwner != msg.sender, "Cannot transfer to same address");
    
    // Could add timelock here for extra security
    _transferOwnership(newOwner);
}

// Two-step ownership transfer for extra security
address private _pendingOwner;

function proposeOwnershipTransfer(address newOwner) external onlyOwner {
    _pendingOwner = newOwner;
    emit OwnershipTransferProposed(msg.sender, newOwner);
}

function acceptOwnership() external {
    require(msg.sender == _pendingOwner, "Not pending owner");
    _transferOwnership(_pendingOwner);
    _pendingOwner = address(0);
}
```

### Agent Validation
```solidity
function _validateAgent(address agent) internal pure {
    require(agent != address(0), "Agent cannot be zero address");
    require(agent.code.length == 0 || _isValidContract(agent), "Invalid agent contract");
}

function _isValidContract(address account) internal view returns (bool) {
    // Additional validation for contract agents if needed
    // For example, check if it implements specific interfaces
    return true;
}
```

## Current Implementation Status

### ✅ **Completed Features**
- **Basic Role System**: Owner/Agent/User hierarchy
- **Agent Management**: Add/remove agents
- **Permission Queries**: Check authorization status
- **Access Control Integration**: Used throughout system
- **Event System**: Comprehensive event emission
- **Batch Operations**: Efficient bulk agent management

### 🔄 **Partial Implementation**
- **Custom Permissions**: Basic framework (could be expanded)
- **Role History**: Simple tracking (could be enhanced)
- **Emergency Controls**: Basic structure (could be more sophisticated)

### ❌ **Future Enhancements**
- **Time-Limited Roles**: Roles that expire automatically
- **Delegated Permissions**: Allow agents to delegate specific permissions
- **Multi-Signature Requirements**: Require multiple signatures for critical operations
- **Role Templates**: Predefined permission sets for common roles
- **Permission Inheritance**: Hierarchical permission structures

## Integration Examples

### Basic Role Management
```javascript
// Check current owner
const owner = await roles.owner();

// Set an agent (as owner)
await roles.connect(owner).setAgent(agentAddress, true);

// Check if address is agent
const isAgent = await roles.isAgent(agentAddress);

// Get all agents
const agents = await roles.getAgents();

// Remove agent (as owner)
await roles.connect(owner).setAgent(agentAddress, false);
```

### Batch Operations
```javascript
// Set multiple agents at once (as owner)
const agents = [addr1, addr2, addr3];
const statuses = [true, true, false]; // Grant to first two, revoke from third

await roles.connect(owner).batchSetAgents(agents, statuses);
```

### Permission Checks in Code
```javascript
// Before performing admin operation
const isAuthorized = await roles.isAgent(userAddress);
if (!isAuthorized) {
    throw new Error("User not authorized for this operation");
}

// Proceed with operation...
```

## Best Practices

### For Administrators
1. **Minimize Agent Count**: Only grant agent status when necessary
2. **Regular Audits**: Review agent list periodically
3. **Document Permissions**: Keep records of why agents were granted access
4. **Monitor Activity**: Track agent actions for security
5. **Emergency Procedures**: Have plans for revoking compromised agents

### For Developers
1. **Check Permissions Early**: Validate authorization before expensive operations
2. **Use Appropriate Modifiers**: Choose correct permission level for each function
3. **Handle Unauthorized Gracefully**: Provide clear error messages
4. **Cache Repeated Checks**: Optimize gas for multiple permission checks
5. **Test Edge Cases**: Verify behavior with various permission combinations

### For Security
1. **Protect Owner Key**: Use hardware wallets or multi-sig for owner
2. **Validate Agent Addresses**: Ensure agents are trusted entities
3. **Monitor for Anomalies**: Watch for unusual agent activity
4. **Plan for Compromise**: Have procedures for handling compromised agents
5. **Regular Updates**: Keep permission lists current

The Roles Contract provides the essential access control foundation that secures all administrative and operational functions throughout our ERC-3643 security token system.

## Related Documentation
- [Token Contract](./TokenContract.md) - Token operations with role-based access
- [Identity Contract](./IdentityContract.md) - Identity management with agent permissions
- [Compliance Contract](./ComplianceContract.md) - Compliance configuration access control
- [ClaimTopics Contract](./ClaimTopicsContract.md) - Topic management permissions
- [TrustedIssuers Contract](./TrustedIssuersContract.md) - Issuer management permissions
- [Architecture Overview](./Architecture.md) - System architecture and security
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Diamond ownership patterns
