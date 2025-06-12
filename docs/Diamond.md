# Diamond.sol - Contrato Principal del Patrón Diamond

## 🎯 **Propósito**

El `Diamond.sol` es el **contrato principal** que implementa el patrón Diamond (EIP-2535) para el sistema T-REX. Actúa como un **proxy inteligente** que delega llamadas a diferentes facets según el selector de función.

---

## 🏗️ **Arquitectura**

```
Diamond.sol (Proxy Core)
    ├── Constructor: Registra DiamondCutFacet
    ├── fallback(): Delega llamadas a facets
    ├── receive(): Recibe ETH
    └── LibDiamond: Gestiona routing y storage
```

---

## 🔧 **Funcionalidades Principales**

### **1. Constructor - Inicialización**
```solidity
constructor(address diamondCutFacet) {
    LibDiamond.setContractOwner(msg.sender);
    
    // Registra el primer facet (DiamondCutFacet)
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;
    
    // Ejecuta el primer "cut" para registrar upgradeability
    LibDiamond.diamondCut(cut, address(0), new bytes(0));
}
```

**¿Qué hace?**
- ✅ Establece el owner del Diamond
- ✅ Registra automáticamente el `DiamondCutFacet`
- ✅ Habilita la capacidad de upgrade desde el inicio

### **2. fallback() - Router Principal**
```solidity
fallback() external payable {
    // 1. Obtiene el storage del Diamond
    LibDiamond.DiamondStorage storage ds;
    
    // 2. Busca qué facet maneja esta función
    address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
    require(facet != address(0), "Diamond: Function does not exist");
    
    // 3. Delega la llamada al facet correspondiente
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

**¿Cómo funciona el routing?**
1. **Captura la llamada**: Cualquier función no definida llega aquí
2. **Busca el facet**: Usa `msg.sig` para encontrar el facet correspondiente
3. **Delega**: Usa `delegatecall` para ejecutar en el contexto del Diamond
4. **Retorna**: Pasa la respuesta al caller original

### **3. receive() - Recepción de ETH**
```solidity
receive() external payable {}
```
- ✅ Permite al Diamond recibir ETH directamente
- ✅ Necesario para operaciones que requieren fondos

---

## 🔄 **Flujo de Operación**

### **Ejemplo: Llamada a `token.transfer(to, amount)`**

```mermaid
graph LR
    A[Usuario] --> B[Diamond.sol]
    B --> C[fallback()]
    C --> D[Busca selector]
    D --> E[TokenFacet]
    E --> F[Ejecuta transfer]
    F --> G[Retorna resultado]
    G --> A
```

1. **Usuario llama**: `diamond.transfer(address, uint256)`
2. **Diamond recibe**: No tiene función `transfer`, va a `fallback()`
3. **Busca facet**: `msg.sig` = `transfer(address,uint256)` → `TokenFacet`
4. **Delega**: `delegatecall` a `TokenFacet.transfer()`
5. **Ejecuta**: Transfer se ejecuta en contexto del Diamond
6. **Retorna**: Resultado vuelve al usuario

---

## 🎯 **Casos de Uso en T-REX**

### **1. Operaciones de Token**
```javascript
// Estas llamadas van a TokenFacet
await diamond.transfer(recipient, amount);
await diamond.mint(investor, tokens);
await diamond.balanceOf(account);
```

### **2. Gestión de Identidades**
```javascript
// Estas llamadas van a IdentityFacet
await diamond.registerIdentity(investor, identityContract, country);
await diamond.isVerified(investor);
```

### **3. Compliance**
```javascript
// Estas llamadas van a ComplianceFacet
await diamond.setMaxBalance(limit);
await diamond.canTransfer(from, to, amount);
```

### **4. Upgrades**
```javascript
// Esta llamada va a DiamondCutFacet
await diamond.diamondCut(cuts, initAddress, initData);
```

---

## 🛡️ **Características de Seguridad**

### **1. Delegatecall Seguro**
```solidity
// Valida que el facet existe
require(facet != address(0), "Diamond: Function does not exist");

// Usa delegatecall (mantiene contexto del Diamond)
delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
```

### **2. Storage Separation**
- ✅ **Diamond Storage**: Para routing de funciones
- ✅ **App Storage**: Para datos de la aplicación
- ✅ **Sin colisiones**: Cada storage en slot específico

### **3. Ownership Control**
- ✅ Solo el owner puede hacer diamond cuts
- ✅ Ownership transferible vía `LibDiamond`
- ✅ Control granular por facet

---

## ⚡ **Ventajas del Diseño**

### **1. Modularidad**
```diff
+ ✅ Cada funcionalidad en su propio facet
+ ✅ Fácil mantenimiento y testing
+ ✅ Separación clara de responsabilidades
```

### **2. Upgradeability**
```diff
+ ✅ Añadir nuevas funciones sin redeployar
+ ✅ Corregir bugs en facets específicos
+ ✅ Remover funcionalidades obsoletas
```

### **3. Eficiencia de Gas**
```diff
+ ✅ Un solo contrato para todas las operaciones
+ ✅ Sin overhead de múltiples contratos
+ ✅ Storage optimizado
```

### **4. Compatibilidad**
```diff
+ ✅ Compatible con herramientas existentes
+ ✅ Interfaces estándar (ERC20, ERC3643)
+ ✅ Integración transparente
```

---

## 🚨 **Consideraciones Importantes**

### **1. Delegatecall Risks**
- ⚠️ Los facets pueden modificar el storage del Diamond
- ⚠️ Necesario confiar en la implementación de facets
- ⚠️ Testing exhaustivo es crítico

### **2. Function Selector Collisions**
- ⚠️ Diferentes facets no pueden tener mismos selectores
- ⚠️ `LibDiamond` valida esto automáticamente
- ⚠️ Planificación cuidadosa de interfaces

### **3. Complexity**
- ⚠️ Más complejo que contratos tradicionales
- ⚠️ Debugging puede ser más difícil
- ⚠️ Requiere entendimiento del patrón Diamond

---

## 📋 **Integración con el Ecosistema T-REX**

### **En el contexto T-REX:**
1. **Cumplimiento regulatorio**: Facets modulares para diferentes jurisdicciones
2. **Identity management**: Integración OnChain-ID vía IdentityFacet
3. **Compliance automation**: Reglas automáticas vía ComplianceFacet
4. **Future-proofing**: Capacidad de añadir nuevos requirements

### **Deployment flow:**
```javascript
1. Deploy Diamond.sol
2. Deploy DiamondCutFacet
3. Deploy otros facets (Token, Identity, Compliance...)
4. Execute diamond cuts para registrar facets
5. Initialize via InitDiamond
```

---

## 🎯 **Conclusión**

El `Diamond.sol` es el **corazón arquitectural** del sistema T-REX modular. Proporciona:

- ✅ **Flexibilidad**: Upgrades sin redeployar
- ✅ **Modularidad**: Funcionalidades separadas
- ✅ **Eficiencia**: Un solo punto de entrada
- ✅ **Escalabilidad**: Fácil añadir funcionalidades

Es la **base fundamental** que permite que el T-REX sea adaptable a cambios regulatorios y requirements futuros.
