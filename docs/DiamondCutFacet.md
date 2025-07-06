
# DiamondCutFacet

The **DiamondCutFacet** is the upgrade management system for the T-REX Diamond architecture. It implements the EIP-2535 Diamond Standard upgrade mechanism, enabling the addition, replacement, and removal of facet functions while maintaining the contract's address and storage.

## Overview

The DiamondCutFacet provides the core upgradeability functionality for the Diamond proxy. It manages function selector routing, facet address mapping, and safe upgrade procedures. This facet is essential for the modular and upgradeable nature of the T-REX protocol.

## Architecture

### Contract Structure
```
DiamondCutFacet (Upgrade Management)
├── LibDiamond (Core Diamond Library)
├── IDiamondCut (Interface Definition)
└── Diamond Storage (Selector Mappings)
```

## Core Functionality

### Diamond Cut Operations

#### Adding New Facets
```solidity
// Add new functionality to the diamond
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: newFacet,
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: [selector1, selector2]
});

diamondCutFacet.diamondCut(cut, address(0), "");
```

#### Replacing Existing Functions
```solidity
// Upgrade existing functionality
cut[0] = IDiamondCut.FacetCut({
    facetAddress: upgradedFacet,
    action: IDiamondCut.FacetCutAction.Replace,
    functionSelectors: [existingSelector]
});

diamondCutFacet.diamondCut(cut, initContract, initCalldata);
```

#### Removing Functions
```solidity
// Remove obsolete functionality
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(0),
    action: IDiamondCut.FacetCutAction.Remove,
    functionSelectors: [selectorToRemove]
});

diamondCutFacet.diamondCut(cut, address(0), "");
```

## Key Features

### 1. Facet Management
```solidity
enum FacetCutAction {
    Add,     // Add new functions to the diamond
    Replace, // Update existing functions with new implementations
    Remove   // Remove functions from the diamond
}
```

### 2. Selector Mapping
- Maps function selectors to facet addresses
- Prevents selector collisions
- Maintains function availability during upgrades
- Supports batch operations for efficiency

### 3. Initialization Support
```solidity
function diamondCut(
    FacetCut[] memory _cut,
    address _init,
    bytes memory _calldata
) external
```
## Security & Access Control

### Owner-Only Operations
- All `diamondCut` operations require contract owner authorization
- Critical for preventing unauthorized upgrades
- Implemented through `LibDiamond.enforceIsContractOwner()`

### Upgrade Safety Measures
- Validates facet addresses and selectors
- Prevents function selector collisions
- Ensures atomic upgrade operations
- Supports initialization for complex migrations

## Integration with T-REX Protocol

### Protocol Upgrades
```javascript
// Example: Upgrading compliance logic
const ComplianceFacetV2 = await ethers.deployContract("ComplianceFacetV2");

const upgradeComplianceCut = [{
    facetAddress: ComplianceFacetV2.target,
    action: FacetCutAction.Replace,
    functionSelectors: await getSelectors(ComplianceFacetV2)
}];

await diamondCut.diamondCut(
    upgradeComplianceCut,
    migrationContract.target,
    migrationCalldata
);
```

### Adding New Protocol Features
```javascript
// Example: Adding new claim verification facet
const ClaimVerificationFacet = await ethers.deployContract("ClaimVerificationFacet");

const addFeatureCut = [{
    facetAddress: ClaimVerificationFacet.target,
    action: FacetCutAction.Add,
    functionSelectors: await getSelectors(ClaimVerificationFacet)
}];

await diamondCut.diamondCut(addFeatureCut, address(0), "0x");
```

## Best Practices

### Upgrade Planning
1. **Test on Testnets**: Always test upgrades on testnets first
2. **Backup Strategies**: Maintain deployment records and rollback plans
3. **Staged Rollouts**: Use feature flags and gradual deployment
4. **Communication**: Notify stakeholders before major upgrades

### Security Considerations
- Use multi-signature wallets for diamond ownership
- Implement timelock contracts for critical upgrades
- Perform thorough security audits before upgrades
- Monitor events and system health after upgrades

### Storage Compatibility
- Ensure storage layout compatibility between facet versions
- Use Diamond Storage pattern to prevent conflicts
- Plan for data migration when changing storage structures
- Test storage access patterns after upgrades

## Events and Monitoring

### DiamondCut Event
```solidity
event DiamondCut(
    IDiamondCut.FacetCut[] _cut, 
    address _init, 
    bytes _calldata
);
```

### Monitoring Upgrades
```javascript
// Listen for upgrade events
diamond.on('DiamondCut', (cuts, init, calldata, event) => {
    logUpgrade({
        cuts: cuts.map(cut => ({
            facetAddress: cut.facetAddress,
            action: cut.action,
            selectors: cut.functionSelectors
        })),
        initContract: init,
        initData: calldata,
        blockNumber: event.blockNumber,
        transactionHash: event.transactionHash
    });
});
```

## Troubleshooting

### Common Issues
- **"LibDiamond: Must be contract owner"**: Unauthorized upgrade attempt
- **Function selector collision**: Attempting to add existing selector
- **Invalid facet address**: Zero address or non-contract address provided

### Debugging Upgrades
1. Verify owner permissions
2. Check function selector uniqueness
3. Validate facet contract deployment
4. Test initialization logic separately
5. Monitor gas usage for large upgrades

## Future Enhancements

### Planned Improvements
- Governance-based upgrade approval
- Automated upgrade testing frameworks
- Cross-chain upgrade synchronization
- Enhanced upgrade analytics and reporting

## Related Documentation
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Complete Diamond architecture
- [Architecture Overview](./Architecture.md) - System overview
- [Extending Protocol](./ExtendingProtocol.md) - Adding new functionality
- [LibDiamond](./LibDiamond.md) - Core Diamond library documentation

## External References
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
- [Diamond Implementation Examples](https://github.com/mudgen/diamond)

// Add it to the Diamond
await diamondCut.diamondCut([{
    facetAddress: await newFeature.getAddress(),
    action: 0, // Add
    functionSelectors: [
        newFeature.interface.getFunction("newFunction").selector
    ]
}], ethers.ZeroAddress, "0x");
```

#### **2. Fix a Bug in an Existing Facet**
```javascript
// Deploy fixed version
const TokenFacetV2 = await ethers.getContractFactory("TokenFacetV2");
const tokenV2 = await TokenFacetV2.deploy();

// Replace buggy functions
await diamondCut.diamondCut([{
    facetAddress: await tokenV2.getAddress(),
    action: 1, // Replace
    functionSelectors: [
        tokenV2.interface.getFunction("transfer").selector,
        tokenV2.interface.getFunction("transferFrom").selector
    ]
}], ethers.ZeroAddress, "0x");
```

#### **3. Remove Deprecated Functionality**
```javascript
await diamondCut.diamondCut([{
    facetAddress: ethers.ZeroAddress,
    action: 2, // Remove
    functionSelectors: [deprecatedSelector]
}], ethers.ZeroAddress, "0x");
```

---

