# Diamond.sol - Main Contract of the Diamond Pattern

## **Purpose**

`Diamond.sol` is the **main contract** implementing the Diamond pattern (EIP-2535) for the T-REX system. It acts as a **smart proxy** that delegates calls to different facets based on the function selector.

---

## **Architecture**

```
Diamond.sol (Proxy Core)
    ├── Constructor: Registers DiamondCutFacet
    ├── fallback(): Delegates calls to facets
    ├── receive(): Receives ETH
    └── LibDiamond: Manages routing and storage
```

---

## **Main Functionalities**

### **1. Constructor - Initialization**
```solidity
constructor(address diamondCutFacet) {
    LibDiamond.setContractOwner(msg.sender);
    
    // Registers the first facet (DiamondCutFacet)
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;
    
    // Executes the first "cut" to register upgradeability
    LibDiamond.diamondCut(cut, address(0), new bytes(0));
}
```

**What does it do?**
- ✅ Sets the owner of the Diamond
- ✅ Automatically registers the `DiamondCutFacet`
- ✅ Enables upgradeability from the start

### **2. fallback() - Main Router**
```solidity
fallback() external payable {
    // 1. Gets the Diamond's storage
    LibDiamond.DiamondStorage storage ds;
    
    // 2. Finds which facet handles this function
    address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
    require(facet != address(0), "Diamond: Function does not exist");
    
    // 3. Delegates the call to the corresponding facet
    assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
}
```

**How does the routing work?**
1. **Captures the call**: Any undefined function arrives here
2. **Finds the facet**: Uses `msg.sig` to find the corresponding facet
3. **Delegates**: Uses `delegatecall` to execute in the Diamond's context
4. **Returns**: Passes the response to the original caller

### **3. receive() - Receiving ETH**
```solidity
receive() external payable {}
```
- ✅ Allows the Diamond to receive ETH directly
- ✅ Necessary for operations requiring funds

---

## 🔄 **Operation Flow**

### **Example: Calling `token.transfer(to, amount)`**

```mermaid
graph LR
    A[User] --> B[Diamond.sol]
    B --> C[fallback()]
    C --> D[Find selector]
    D --> E[TokenFacet]
    E --> F[Execute transfer]
    F --> G[Return result]
    G --> A
```

1. **User calls**: `diamond.transfer(address, uint256)`
2. **Diamond receives**: No `transfer` function, goes to `fallback()`
3. **Finds facet**: `msg.sig` = `transfer(address,uint256)` → `TokenFacet`
4. **Delegates**: `delegatecall` to `TokenFacet.transfer()`
5. **Executes**: Transfer runs in the Diamond's context
6. **Returns**: Result goes back to the user

---

## **Use Cases in T-REX**

### **1. Token Operations**
```javascript
// These calls go to TokenFacet
await diamond.transfer(recipient, amount);
await diamond.mint(investor, tokens);
await diamond.balanceOf(account);
```

### **2. Identity Management**
```javascript
// These calls go to IdentityFacet
await diamond.registerIdentity(investor, identityContract, country);
await diamond.isVerified(investor);
```

### **3. Compliance**
```javascript
// These calls go to ComplianceFacet
await diamond.setMaxBalance(limit);
await diamond.canTransfer(from, to, amount);
```

### **4. Upgrades**
```javascript
// This call goes to DiamondCutFacet
await diamond.diamondCut(cuts, initAddress, initData);
```

---

## **Security Features**

### **1. Safe Delegatecall**
```solidity
// Validates that the facet exists
require(facet != address(0), "Diamond: Function does not exist");

// Uses delegatecall (keeps Diamond's context)
delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
```

### **2. Storage Separation**
- ✅ **Diamond Storage**: For function routing
- ✅ **App Storage**: For application data
- ✅ **No collisions**: Each storage in a specific slot

### **3. Ownership Control**
- ✅ Only the owner can perform diamond cuts
- ✅ Ownership transferable via `LibDiamond`
- ✅ Granular control per facet

---

## **Design Advantages**

### **1. Modularity**
```diff
+ ✅ Each functionality in its own facet
+ ✅ Easy maintenance and testing
+ ✅ Clear separation of responsibilities
```

### **2. Upgradeability**
```diff
+ ✅ Add new functions without redeploying
+ ✅ Fix bugs in specific facets
+ ✅ Remove obsolete functionalities
```

### **3. Gas Efficiency**
```diff
+ ✅ Single contract for all operations
+ ✅ No overhead from multiple contracts
+ ✅ Optimized storage
```

### **4. Compatibility**
```diff
+ ✅ Compatible with existing tools
+ ✅ Standard interfaces (ERC20, ERC3643)
+ ✅ Transparent integration
```

---

## **Important Considerations**

### **1. Delegatecall Risks**
- ⚠️ Facets can modify the Diamond's storage
- ⚠️ Trust in facet implementation is required
- ⚠️ Thorough testing is critical

### **2. Function Selector Collisions**
- ⚠️ Different facets cannot have the same selectors
- ⚠️ `LibDiamond` validates this automatically
- ⚠️ Careful interface planning is needed

### **3. Complexity**
- ⚠️ More complex than traditional contracts
- ⚠️ Debugging can be harder
- ⚠️ Requires understanding of the Diamond pattern

---

## **Integration with the T-REX Ecosystem**

### **In the T-REX context:**
1. **Regulatory compliance**: Modular facets for different jurisdictions
2. **Identity management**: OnChain-ID integration via IdentityFacet
3. **Compliance automation**: Automated rules via ComplianceFacet
4. **Future-proofing**: Ability to add new requirements

### **Deployment flow:**
```javascript
1. Deploy Diamond.sol
2. Deploy DiamondCutFacet
3. Deploy other facets (Token, Identity, Compliance...)
4. Execute diamond cuts to register facets
5. Initialize via InitDiamond
```

---

## **Conclusion**

`Diamond.sol` is the **architectural core** of the modular T-REX system. It provides:

- ✅ **Flexibility**: Upgrades without redeploying
- ✅ **Modularity**: Separated functionalities
- ✅ **Efficiency**: Single entry point
- ✅ **Scalability**: Easy to add functionalities

It is the **fundamental base** that enables T-REX to adapt to regulatory changes and future requirements.
