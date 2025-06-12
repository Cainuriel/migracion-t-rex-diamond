

### **Propósito Principal: UPGRADEABILITY**

El `DiamondCutFacet` es el **motor de upgrades** del Diamond. Permite:

```solidity
// Añadir nuevas funciones
diamondCut.diamondCut([{
    facetAddress: newFacet,
    action: FacetCutAction.Add,
    functionSelectors: [selector1, selector2]
}], address(0), "");

// Reemplazar funciones existentes
diamondCut.diamondCut([{
    facetAddress: upgradedFacet,
    action: FacetCutAction.Replace,
    functionSelectors: [existingSelector]
}], address(0), "");

// Remover funciones
diamondCut.diamondCut([{
    facetAddress: address(0),
    action: FacetCutAction.Remove,
    functionSelectors: [selectorToRemove]
}], address(0), "");
```

---

### **Funcionalidades Clave**

#### **1. Gestión de Facets**
```solidity
enum FacetCutAction {
    Add,     // Añadir nuevas funciones
    Replace, // Actualizar funciones existentes  
    Remove   // Eliminar funciones
}
```

#### **2. Mapping de Selectores**
- **Añade** nuevos selectores → facet addresses
- **Actualiza** selectores existentes
- **Remueve** selectores obsoletos

#### **3. Inicialización Post-Upgrade**
```solidity
diamondCut(cuts, initAddress, initCalldata);
// initAddress: contrato para ejecutar después del cut
// initCalldata: datos para la inicialización
```

---


```solidity
// Diamond.sol constructor
constructor(address diamondCutFacet) {
    LibDiamond.setContractOwner(msg.sender);

    // Registra la función diamondCut
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;

    IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
    cut[0] = IDiamondCut.FacetCut({
        facetAddress: diamondCutFacet,
        action: IDiamondCut.FacetCutAction.Add,
        functionSelectors: functionSelectors
    });

    // El primer "cut" registra el DiamondCutFacet
    LibDiamond.diamondCut(cut, address(0), new bytes(0));
}
```

---

### **Casos de Uso Prácticos**

#### **1. Añadir Nueva Funcionalidad**
```javascript
// Desplegar nuevo facet
const NewFeatureFacet = await ethers.getContractFactory("NewFeatureFacet");
const newFeature = await NewFeatureFacet.deploy();

// Añadirlo al Diamond
await diamondCut.diamondCut([{
    facetAddress: await newFeature.getAddress(),
    action: 0, // Add
    functionSelectors: [
        newFeature.interface.getFunction("newFunction").selector
    ]
}], ethers.ZeroAddress, "0x");
```

#### **2. Corregir Bug en Facet Existente**
```javascript
// Desplegar versión corregida
const TokenFacetV2 = await ethers.getContractFactory("TokenFacetV2");
const tokenV2 = await TokenFacetV2.deploy();

// Reemplazar funciones buggeadas
await diamondCut.diamondCut([{
    facetAddress: await tokenV2.getAddress(),
    action: 1, // Replace
    functionSelectors: [
        tokenV2.interface.getFunction("transfer").selector,
        tokenV2.interface.getFunction("transferFrom").selector
    ]
}], ethers.ZeroAddress, "0x");
```

#### **3. Remover Funcionalidad Deprecated**
```javascript
await diamondCut.diamondCut([{
    facetAddress: ethers.ZeroAddress,
    action: 2, // Remove
    functionSelectors: [deprecatedSelector]
}], ethers.ZeroAddress, "0x");
```

---

