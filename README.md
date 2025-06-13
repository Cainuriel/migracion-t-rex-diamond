# MVP Diamond pattern T-REX

## Esta implementación es **un MVP básico para el estudio de uso de T-REX con el patrón diamond.** 

---

## Resumen del Proyecto 

**sistema T-REX Diamond** que incluye:

###  **Contratos Core**
- 🔹 **Diamond Pattern (EIP-2535)** con upgradeabilidad modular
- 🔹 **7 Facets especializados** (Token, Roles, Identity, Compliance, etc.)
- 🔹 **Sistema de storage unificado** con AppStorage
- 🔹 **Arquitectura T-REX (ERC-3643)** para security tokens

###  **Scripts**
- 🔹 **Deploy script** con configuración automática de owner como agent
- 🔹 **Verification script** con 25+ checks comprehensivos
- 🔹 **Interaction script** con 11 comandos operacionales
- 🔹 **Manejo de BigInt** para compatibilidad JSON
- 🔹 **Sistema de variables de entorno** para facilidad de uso

###  **Documentación**
- 🔹 **Documentación técnica** detallada por cada contrato en la carpeta docs (En inglés): [Ver carpeta](./docs/)
- 🔹 **Documentación de scripts**: consultar la [documentación de despliegue, verificación e interacción`](./scripts/README.md) para detalles de uso y ejemplos.

### testing
``` npm run test ``` 
``` npm run coverage ```

### **IMPLEMENTACIÓN**

#### **1. Arquitectura Diamond Pattern**
```
Diamond.sol (Core)
InitDiamond.sol
├── libraries/
│   ├── LibDiamond.sol (Diamond storage & logic)
│   └── LibAppStorage.sol (App storage accessor)
├── interfaces/
│   └── IDiamondCut.sol (Interface)
├── storage/
│   └── AppStorage.sol (App storage struct)
└── facets/
    ├── DiamondCutFacet.sol (Upgradeability)
    ├── TokenFacet.sol (ERC20 + ERC3643)
    ├── IdentityFacet.sol (OnChain-ID integration)
    ├── ComplianceFacet.sol (Compliance rules)
    ├── RolesFacet.sol (Access control)
    ├── ClaimTopicsFacet.sol (Claim management)
    └── TrustedIssuersFacet.sol (Issuer management)
```

#### **2. Storage Pattern**
- **AppStorage struct unificado**: Evita colisiones de storage
- **LibAppStorage**: Patrón Diamond Storage
- **Tipos estructurados**: `Investor`, `Compliance` definidos
- **Separación de concerns**: Diamond storage vs App storage

#### **3. Funcionalidades T-REX Completas**
- **ERC20 + ERC3643**: Token estándar con compliance
- **Identity Management**: Integración OnChain-ID
- **Compliance Rules**: Max/min balance, max investors
- **Access Control**: Owner/Agent roles
- **Claim Topics**: Gestión de topics de verificación
- **Trusted Issuers**: Gestión de emisores confiables

---

### **ÁREAS A MEJORAR**

#### **1. Funcionalidades T-REX Faltantes**
```solidity

- OwnershipFacet separado (ownership management)
- PausableFacet (emergency pause)
- TransferRestrictionsFacet (transfer rules)
- ComplianceModulesFacet (modular compliance)
- ClaimValidationFacet (claim verification logic)
```

#### **2. Integración OnChain-ID Incompleta**
- **isVerified()** básico pero funcional
- Falta validación profunda de claims
- No hay integración con ClaimIssuer completa

#### **3. Compliance Simplificada**
- Faltan módulos de compliance
- No hay reglas de transferencia complejas
- Falta integración con jurisdicciones

---

---

### **COMPARACIÓN CON T-REX ORIGINAL**

| Funcionalidad | Original T-REX | Esta Implementación | Estado |
|---------------|----------------|-------------------|---------|
| ERC20 Base | ✅ | ✅ | ✅ Completo |
| ERC3643 | ✅ | ⚠️ | ⚠️ Parcial |
| OnChain-ID | ✅ | ⚠️ | ⚠️ Básico |
| Compliance | ✅ | ⚠️ | ⚠️ Simplificado |
| Upgradeability | ❌ | ✅ | ✅ Mejorado |
| Modularity | ⚠️ | ✅ | ✅ Mejorado |

---

### **Por realizar**

#### **Para Producción Inmediata:**
1. **Añadir más tests de edge cases**
2. **Implementar OwnershipFacet separado**
3. **Mejorar validación de claims**
4. **Añadir emergency pause**

#### **Para Versión Completa:**
1. **Implementar compliance modules**
2. **Integración OnChain-ID completa**
3. **Transfer restrictions avanzadas**
4. **Multi-jurisdictional support**

---

##  Recursos Adicionales

- [Documentación T-REX](../docs/)
- [Tests del sistema](../test/)
- [Contratos fuente](../contracts/)
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
- [T-REX Standard](https://github.com/TokenySolutions/T-REX)

