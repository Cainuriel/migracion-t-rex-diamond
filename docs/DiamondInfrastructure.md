# Diamond Infrastructure

The **Diamond Infrastructure** provides the foundational architecture for the T-REX protocol using the EIP-2535 Diamond Standard. This modular architecture enables upgradeable smart contracts while maintaining storage consistency and gas efficiency.

## Overview

The Diamond Standard (EIP-2535) allows a single contract to implement multiple facets (logic contracts) while maintaining unified storage. This architecture provides:

- **Upgradability**: Add, remove, or replace functions without changing the contract address
- **Modularity**: Separate business logic into focused, maintainable facets
- **Gas Efficiency**: Only deploy code that changes, reuse existing facets
- **Storage Isolation**: Each domain manages its own storage using unique slots

## Architecture Components

### Core Components

```
Diamond (Proxy Contract)
├── LibDiamond (Core Library)
├── DiamondCutFacet (Upgrade Management)
├── InitDiamond (Initialization Logic)
└── Business Facets (Protocol Logic)
    ├── TokenFacet
    ├── IdentityFacet
    ├── ComplianceFacet
    ├── RolesFacet
    ├── ClaimTopicsFacet
    └── TrustedIssuersFacet
```

## Core Contracts

### Diamond.sol
The main proxy contract that routes function calls to appropriate facets.

```solidity
contract Diamond is Initializable {
    constructor(address diamondCutFacet) {
        LibDiamond.setContractOwner(msg.sender);
        // Initialize with DiamondCut facet for upgrades
    }
    
    fallback() external payable {
        // Route calls to appropriate facets
        LibDiamond.DiamondStorage storage ds;
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        // Delegate call to facet
    }
}
```

**Key Features:**
- Function selector routing to facets
- Delegatecall execution preserving context
- Owner initialization and management
- Payable fallback for ether handling

### LibDiamond.sol
Core library managing Diamond storage and facet operations.

```solidity
library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("isbe.standard.diamond.storage");
    
    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }
}
```

**Key Features:**
- Diamond storage pattern implementation
- Facet address and selector management
- Owner authorization enforcement
- Interface support tracking

### InitDiamond.sol
Initialization contract for setting up the complete T-REX system.

```solidity
contract InitDiamond is Initializable {
    function init(
        address owner,
        string memory name,
        string memory symbol,
        // ... other parameters
    ) external initializer {
        // Initialize all storage domains
        _initTokenStorage(name, symbol);
        _initRolesStorage(owner);
        _initIdentityStorage();
        _initComplianceStorage();
        // ... other domains
    }
}
```

**Key Features:**
- One-time initialization for all facets
- Storage domain setup
- Parameter validation and setup
- Event emission for tracking

## Storage Architecture

### Diamond Storage Pattern
Each facet uses isolated storage to prevent conflicts:

```solidity
// Example: Token storage
struct TokenStorage {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    mapping(address => bool) frozenAccounts;
    address[] holders;
}

bytes32 private constant TOKEN_STORAGE_POSITION = 
    keccak256("t-rex.diamond.token.storage");

function _getTokenStorage() private pure returns (TokenStorage storage ts) {
    bytes32 position = TOKEN_STORAGE_POSITION;
    assembly { ts.slot := position }
}
```

### Storage Domains
Each major protocol component has its own storage domain:

1. **TokenStorage**: ERC-20 and ERC-3643 token data
2. **RolesStorage**: Access control and ownership
3. **IdentityStorage**: Identity registry mappings
4. **ComplianceStorage**: Compliance rules and limits
5. **ClaimTopicsStorage**: Required claim topics
6. **TrustedIssuersStorage**: Authorized claim issuers

## Facet Management

### Adding New Facets
```solidity
// 1. Deploy new facet contract
MyNewFacet newFacet = new MyNewFacet();

// 2. Prepare function selectors
bytes4[] memory selectors = new bytes4[](2);
selectors[0] = MyNewFacet.newFunction1.selector;
selectors[1] = MyNewFacet.newFunction2.selector;

// 3. Create facet cut
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(newFacet),
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});

// 4. Execute diamond cut
diamondCutFacet.diamondCut(cut, address(0), "");
```

### Upgrading Existing Facets
```solidity
// 1. Deploy new version of facet
TokenFacetV2 newTokenFacet = new TokenFacetV2();

// 2. Replace existing functions
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(newTokenFacet),
    action: IDiamondCut.FacetCutAction.Replace,
    functionSelectors: existingSelectors
});

// 3. Execute upgrade
diamondCutFacet.diamondCut(cut, address(initContract), initData);
```

## Deployment Process

### 1. Deploy Core Infrastructure
```javascript
// Deploy Diamond with DiamondCutFacet
const DiamondCutFacet = await ethers.deployContract("DiamondCutFacet");
const Diamond = await ethers.deployContract("Diamond", [DiamondCutFacet.target]);

// Deploy initialization contract
const InitDiamond = await ethers.deployContract("InitDiamond");
```

### 2. Deploy Business Facets
```javascript
// Deploy all business logic facets
const TokenFacet = await ethers.deployContract("TokenFacet");
const IdentityFacet = await ethers.deployContract("IdentityFacet");
const ComplianceFacet = await ethers.deployContract("ComplianceFacet");
const RolesFacet = await ethers.deployContract("RolesFacet");
const ClaimTopicsFacet = await ethers.deployContract("ClaimTopicsFacet");
const TrustedIssuersFacet = await ethers.deployContract("TrustedIssuersFacet");
```

### 3. Add Facets to Diamond
```javascript
// Prepare all facet cuts
const facetCuts = [
    {
        facetAddress: TokenFacet.target,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(TokenFacet)
    },
    // ... other facets
];

// Execute diamond cut with initialization
await diamondCut.diamondCut(
    facetCuts,
    InitDiamond.target,
    initCalldata
);
```

## Security Considerations

### Access Control
- **Diamond Owner**: Controls facet additions, removals, and replacements
- **Facet-Level Access**: Each facet implements its own authorization
- **Storage Isolation**: Facets cannot access other facets' storage
- **Selector Conflicts**: Diamond prevents function selector collisions

### Upgrade Safety
- **Initialization Protection**: Prevent multiple initializations
- **Storage Compatibility**: Ensure storage layout compatibility in upgrades
- **Function Preservation**: Maintain critical function availability
- **Event Continuity**: Preserve event emission patterns

### Best Practices
- Use multi-signature wallets for diamond ownership
- Implement timelock for critical upgrades
- Test upgrades on testnets extensively
- Maintain comprehensive upgrade documentation

## Monitoring & Maintenance

### Facet Introspection
```solidity
// Check supported interfaces
bool supportsInterface = diamond.supportsInterface(interfaceId);

// Get facet addresses
address[] memory facets = diamond.facetAddresses();

// Get function selectors for facet
bytes4[] memory selectors = diamond.facetFunctionSelectors(facetAddress);
```

### Upgrade Tracking
```javascript
// Monitor diamond cut events
diamond.on('DiamondCut', (facetCuts, init, calldata, event) => {
    console.log('Diamond upgraded:', {
        facetCuts,
        initContract: init,
        calldata,
        blockNumber: event.blockNumber
    });
    
    // Update deployment records
    updateDeploymentLog(facetCuts, event);
});
```

## Gas Optimization

### Function Routing
- Optimal selector ordering for common functions
- Minimal gas overhead for delegatecalls
- Efficient storage access patterns

### Deployment Efficiency
- Reuse existing facets across diamonds
- Incremental deployments for updates
- Minimal proxy bytecode size

## Error Handling

### Common Errors
- **"Diamond: Function does not exist"**: Call to unregistered function selector
- **"LibDiamond: Must be contract owner"**: Unauthorized upgrade attempt
- **"Diamond: No selectors in facet to cut"**: Empty selector array in facet cut

### Troubleshooting
1. Verify function selectors are correctly registered
2. Check diamond owner permissions
3. Validate facet deployment addresses
4. Ensure initialization completion

## Future Enhancements

### Planned Improvements
- Automated facet verification
- Upgrade proposal and voting system
- Cross-chain diamond synchronization
- Enhanced storage migration tools

### Integration Possibilities
- Diamond factory patterns
- Standardized facet registries
- Automated testing frameworks
- Upgrade simulation tools

## Related Documentation
- [Architecture Overview](./Architecture.md) - Complete system architecture
- [ExtendingProtocol](./ExtendingProtocol.md) - Adding new facets and functionality
- [Token Contract](./TokenContract.md) - Token facet implementation
- [Identity Contract](./IdentityContract.md) - Identity management
- [Compliance Contract](./ComplianceContract.md) - Compliance verification

## External References
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
- [Diamond Architecture Patterns](https://github.com/mudgen/diamond)
- [OpenZeppelin Upgradeable Contracts](https://docs.openzeppelin.com/contracts/4.x/upgradeable)
