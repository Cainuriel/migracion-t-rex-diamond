
### **Main Purpose: UPGRADEABILITY**

The `DiamondCutFacet` is the **upgrade engine** of the Diamond. It allows you to:

```solidity
// Add new functions
diamondCut.diamondCut([{
    facetAddress: newFacet,
    action: FacetCutAction.Add,
    functionSelectors: [selector1, selector2]
}], address(0), "");

// Replace existing functions
diamondCut.diamondCut([{
    facetAddress: upgradedFacet,
    action: FacetCutAction.Replace,
    functionSelectors: [existingSelector]
}], address(0), "");

// Remove functions
diamondCut.diamondCut([{
    facetAddress: address(0),
    action: FacetCutAction.Remove,
    functionSelectors: [selectorToRemove]
}], address(0), "");
```

---

### **Key Features**

#### **1. Facet Management**
```solidity
enum FacetCutAction {
    Add,     // Add new functions
    Replace, // Update existing functions  
    Remove   // Remove functions
}
```

#### **2. Selector Mapping**
- **Adds** new selectors → facet addresses
- **Updates** existing selectors
- **Removes** obsolete selectors

#### **3. Post-Upgrade Initialization**
```solidity
diamondCut(cuts, initAddress, initCalldata);
// initAddress: contract to execute after the cut
// initCalldata: initialization data
```

---

```solidity
// Diamond.sol constructor
constructor(address diamondCutFacet) {
    LibDiamond.setContractOwner(msg.sender);

    // Register the diamondCut function
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;

    IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
    cut[0] = IDiamondCut.FacetCut({
        facetAddress: diamondCutFacet,
        action: IDiamondCut.FacetCutAction.Add,
        functionSelectors: functionSelectors
    });

    // The first "cut" registers the DiamondCutFacet
    LibDiamond.diamondCut(cut, address(0), new bytes(0));
}
```

---

### **Practical Use Cases**

#### **1. Add New Functionality**
```javascript
// Deploy new facet
const NewFeatureFacet = await ethers.getContractFactory("NewFeatureFacet");
const newFeature = await NewFeatureFacet.deploy();

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

