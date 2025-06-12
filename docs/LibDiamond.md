# LibDiamond Documentation

## Overview

`LibDiamond` is the **core library** that implements the Diamond Pattern (EIP-2535) functionality for the T-REX security token system. This library provides the fundamental diamond storage management, function selector routing, and facet upgrade capabilities that enable the modular, upgradeable architecture of the system.

## Architecture & Purpose

### Primary Responsibilities
- **Diamond Storage Management**: Isolated storage namespace for diamond metadata
- **Function Selector Routing**: Maps function calls to appropriate facet contracts
- **Facet Management**: Handles addition, modification, and removal of facets
- **Ownership Control**: Manages diamond contract ownership
- **Upgrade Infrastructure**: Provides secure upgrade mechanisms
- **Interface Support**: Manages supported interface declarations

### EIP-2535 Compliance
The library implements the **Diamond Standard (EIP-2535)**:
- **Modular Architecture**: Separates functionality into distinct facets
- **Unlimited Contract Size**: Bypasses 24KB contract size limit
- **Upgradeable Design**: Allows adding/removing/replacing functionality
- **Shared Storage**: Enables data sharing between facets
- **Gas Efficiency**: Optimized function dispatching

## Storage Architecture

### Diamond Storage Pattern
```solidity
bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("isbe.standard.diamond.storage");
```

The library uses a **deterministic storage slot** to avoid storage collisions:
- **Isolated Namespace**: Diamond metadata stored separately from application data
- **Consistent Access**: Same storage location across all facets
- **Collision Avoidance**: Unique hash prevents conflicts
- **Standard Compliance**: Follows EIP-2535 specifications

### DiamondStorage Struct
```solidity
struct DiamondStorage {
    mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
    mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
    address[] facetAddresses;
    mapping(bytes4 => bool) supportedInterfaces;
    address contractOwner;
}
```

**Storage Components**:
- **Selector Mapping**: Routes function selectors to facet addresses
- **Facet Functions**: Tracks which functions belong to each facet
- **Facet Registry**: Maintains list of all facet addresses
- **Interface Support**: EIP-165 interface detection
- **Ownership**: Contract owner for upgrade authorization

### Supporting Structures
```solidity
struct FacetAddressAndPosition {
    address facetAddress;           // Facet contract address
    uint96 functionSelectorPosition; // Position in selector array
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;     // Function selectors for this facet
    uint256 facetAddressPosition;   // Position in facet address array
}
```

## Key Functions

### Storage Access

#### Diamond Storage Retrieval
```solidity
function diamondStorage() internal pure returns (DiamondStorage storage ds)
```
- **Purpose**: Provide access to diamond storage namespace
- **Implementation**: Uses inline assembly for gas optimization
- **Usage**: Called by all diamond management functions
- **Safety**: Pure function ensures consistent storage access

### Ownership Management

#### Set Contract Owner
```solidity
function setContractOwner(address _newOwner) internal
```
- **Purpose**: Update diamond contract owner
- **Usage**: Called during initialization and ownership transfers
- **Access**: Internal function for library use only
- **Integration**: Works with ownership transfer mechanisms

#### Ownership Enforcement
```solidity
function enforceIsContractOwner() internal view
```
- **Purpose**: Verify caller is authorized diamond owner
- **Usage**: Used by upgrade functions and administrative operations
- **Security**: Prevents unauthorized diamond modifications
- **Error Handling**: Provides clear error message for access denial

### Facet Management

#### Diamond Cut Operation
```solidity
function diamondCut(
    IDiamondCut.FacetCut[] memory _cut,
    address _init,
    bytes memory _calldata
) internal
```

**Comprehensive upgrade mechanism**:
- **Batch Operations**: Process multiple facet changes atomically
- **Action Support**: Add, replace, remove facet functions
- **Initialization**: Optional initialization call after upgrades
- **Validation**: Ensures upgrade integrity and security

**Cut Processing Logic**:
1. **Validation**: Verify function selectors provided
2. **Action Execution**: Process Add/Replace/Remove operations
3. **Storage Update**: Update selector mappings and facet registry
4. **Initialization**: Execute optional initialization logic
5. **Event Emission**: Log upgrade activities (in calling contract)

### Current Implementation Status

The current implementation supports:
- ✅ **Add Operations**: Adding new facets and functions
- ✅ **Validation**: Function selector validation
- ✅ **Initialization**: Post-upgrade initialization calls
- ⚠️ **Limited Actions**: Only Add action currently implemented
- ⚠️ **Remove/Replace**: Not yet implemented (returns "Unsupported action")

## Function Selector Management

### Selector Registration
When adding functions:
```solidity
if (action == IDiamondCut.FacetCutAction.Add) {
    for (uint256 selectorIndex; selectorIndex < functionSelectors.length; selectorIndex++) {
        bytes4 selector = functionSelectors[selectorIndex];
        diamondStorage().selectorToFacetAndPosition[selector] = FacetAddressAndPosition({
            facetAddress: facetAddress,
            functionSelectorPosition: uint96(selectorIndex)
        });
    }
}
```

**Registration Process**:
1. **Iterate Selectors**: Process each function selector
2. **Map to Facet**: Associate selector with facet address
3. **Position Tracking**: Store selector position for management
4. **Collision Prevention**: Ensure selectors are unique

### Function Dispatching
The Diamond contract uses this library for routing:
```solidity
// In Diamond.sol fallback function
FacetAddressAndPosition memory facetAddressAndPosition = 
    LibDiamond.diamondStorage().selectorToFacetAndPosition[msg.sig];
address facet = facetAddressAndPosition.facetAddress;
```

## Initialization Support

### Post-Upgrade Initialization
```solidity
if (_init != address(0)) {
    (bool success, bytes memory error) = _init.delegatecall(_calldata);
    require(success, string(error));
}
```

**Initialization Features**:
- **Optional Execution**: Only runs if initialization address provided
- **Delegatecall Context**: Runs in diamond's storage context
- **Error Handling**: Propagates initialization errors
- **Data Migration**: Supports storage schema updates

## Security Considerations

### Access Control
- **Owner Enforcement**: Critical functions require owner authorization
- **Internal Functions**: Library functions are internal-only
- **Upgrade Authorization**: Only owner can perform diamond cuts
- **Validation**: Input validation prevents malformed upgrades

### Storage Safety
- **Isolated Storage**: Diamond storage separate from application data
- **Deterministic Slots**: Consistent storage layout across upgrades
- **Collision Avoidance**: Unique storage positions prevent conflicts
- **State Preservation**: Application data persists through upgrades

### Upgrade Security
- **Atomic Operations**: All changes applied atomically
- **Rollback Safety**: Failed upgrades don't leave inconsistent state
- **Initialization Safety**: Delegatecall in diamond context
- **Validation Requirements**: Function selector validation

## Integration with T-REX System

### Diamond Contract Integration
```solidity
// In Diamond.sol
import { LibDiamond } from "./libraries/LibDiamond.sol";

// Owner enforcement
modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
}

// Upgrade execution
function diamondCut(
    IDiamondCut.FacetCut[] calldata _cut,
    address _init,
    bytes calldata _calldata
) external onlyOwner {
    LibDiamond.diamondCut(_cut, _init, _calldata);
}
```

### DiamondCutFacet Integration
```solidity
// In DiamondCutFacet.sol
function diamondCut(
    IDiamondCut.FacetCut[] calldata _cut,
    address _init,
    bytes calldata _calldata
) external {
    LibDiamond.enforceIsContractOwner();
    LibDiamond.diamondCut(_cut, _init, _calldata);
    emit DiamondCut(_cut, _init, _calldata);
}
```

### Application Storage Coordination
- **Separate Namespaces**: LibDiamond storage isolated from LibAppStorage
- **No Conflicts**: Different storage positions prevent interference
- **Coordinated Access**: Both libraries can be used safely together
- **Upgrade Compatibility**: Application data preserved during upgrades

## Gas Optimization

### Storage Efficiency
- **Packed Structs**: Efficient storage layout for metadata
- **Minimal Mappings**: Optimized selector-to-facet mapping
- **Assembly Usage**: Gas-optimized storage access
- **Batch Operations**: Atomic multi-facet updates

### Function Dispatching
- **Direct Mapping**: O(1) selector-to-facet lookup
- **Minimal Overhead**: Efficient function routing
- **Cache-Friendly**: Optimized storage layout
- **Assembly Optimization**: Gas-efficient storage access

## Common Upgrade Patterns

### 1. Adding New Facet
```solidity
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: newFacetAddress,
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: getSelectors("NewFacet")
});

LibDiamond.diamondCut(cut, address(0), "");
```

### 2. Upgrading Existing Facet
```solidity
// Remove old functions (when implemented)
// Add new functions
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: upgradedFacetAddress,
    action: IDiamondCut.FacetCutAction.Replace,  // Not yet implemented
    functionSelectors: getSelectors("UpgradedFacet")
});

LibDiamond.diamondCut(cut, initializationAddress, initCalldata);
```

## Best Practices

### 1. Upgrade Planning
- **Test Thoroughly**: Comprehensive testing before production upgrades
- **Backup Plans**: Ensure rollback capabilities
- **Staged Rollout**: Consider gradual deployment strategies
- **Documentation**: Document all upgrade procedures

### 2. Security Practices
- **Owner Protection**: Secure owner key management
- **Validation**: Verify all upgrade parameters
- **Monitoring**: Monitor upgrade transactions
- **Emergency Procedures**: Plan for emergency responses

### 3. Development Practices
- **Library Updates**: Keep LibDiamond updated with latest standards
- **Interface Consistency**: Maintain consistent facet interfaces
- **Storage Management**: Coordinate storage usage across facets
- **Testing**: Comprehensive diamond functionality testing

## Future Enhancements

### Planned Improvements
1. **Complete Action Support**: Implement Replace and Remove actions
2. **Enhanced Validation**: More comprehensive upgrade validation
3. **Batch Optimizations**: Improved gas efficiency for large upgrades
4. **Event Enhancement**: More detailed upgrade event emissions

### Extended Functionality
- **Facet Introspection**: Enhanced facet discovery capabilities
- **Version Management**: Facet version tracking
- **Governance Integration**: DAO-controlled upgrades
- **Cross-Chain Support**: Multi-chain diamond synchronization

LibDiamond provides the essential foundation for the T-REX Diamond system's modularity and upgradeability, enabling sophisticated security token functionality while maintaining flexibility for future enhancements and regulatory changes.
