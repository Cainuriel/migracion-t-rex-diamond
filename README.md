# MVP Diamond pattern T-REX

## Esta implementación es **un MVP básico para estudio de un posible desarrollo posterior.** 

---

### **IMPLEMENTACIÓN**

#### **1. Arquitectura Diamond Pattern**
```
Diamond.sol (Core)
├── LibDiamond.sol (Diamond storage & logic)
├── LibAppStorage.sol (App storage accessor)
├── DiamondCutFacet.sol (Upgradeability)
└── Facets/
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

#### **4. Seguridad y Best Practices**
- **Modifiers**: `onlyOwner`, `onlyAgentOrOwner`
- **Initializable pattern**: Previene re-inicialización
- **Event logging**: Trazabilidad completa
- **Input validation**: Checks de address(0), etc.

---

### **ÁREAS DE MEJORA**

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

1. **Auditoría de seguridad**
2. **Más funcionalidades T-REX**
3. **Testing más exhaustivo**
4. **Documentación completa**

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

### **Documentación Smart Contracts**

- [Carpeta `docs/`](./docs/)

   
### testing
``` npm run test ``` ``` npm run coverage ```
