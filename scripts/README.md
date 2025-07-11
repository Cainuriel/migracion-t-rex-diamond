# T-REX Diamond Scripts - New Architecture

Este directorio contiene los scripts principales para desplegar, verificar e interactuar con el sistema T-REX Diamond refactorizado con la nueva arquitectura modular.

## 📁 Scripts Disponibles

### 🚀 `deploy.js` - Script de Despliegue Principal
Despliega todo el sistema T-REX Diamond con la nueva arquitectura modular:
- Diamond contract principal
- Todos los facets externos (Token, Compliance, Identity, Roles, ClaimTopics, TrustedIssuers)
- Todos los facets internos (business logic)
- Storage libraries independientes por dominio
- Configuración inicial del sistema
- Reglas de cumplimiento básicas

**Uso:**
```bash
# Despliegue en red <CUSTOM_NETWORK>
npx hardhat run scripts/deploy.js --network <CUSTOM_NETWORK>

# Despliegue en BSC testnet
npx hardhat run scripts/deploy.js --network bscTestnet

# Despliegue en red local
npx hardhat run scripts/deploy.js --network localhost
```

### 🔍 `verify.js` - Script de Verificación Universal
Verifica que el despliegue se haya completado correctamente en cualquier red:
- Valida que todos los facets estén correctamente registrados
- Verifica la configuración inicial del sistema
- Comprueba el funcionamiento de la nueva arquitectura modular
- Valida el estado de agentes y permisos
- Prueba las funciones de storage separado
- Genera reporte de estado completo

**Características:**
- ✅ Funciona en cualquier red donde esté desplegado el diamond
- ✅ Auto-detecta el archivo de deployment o usa direcciones conocidas
- ✅ Reporte completo con métricas de éxito
- ✅ Compatible con <CUSTOM_NETWORK>, BSC, Polygon, etc.

**Uso:**
```bash
# Verificar despliegue en <CUSTOM_NETWORK> (auto-detecta)
npx hardhat run scripts/verify.js --network <CUSTOM_NETWORK>

# Verificar despliegue en BSC testnet
npx hardhat run scripts/verify.js --network bscTestnet

# Verificar cualquier red con deployment file
npx hardhat run scripts/verify.js --network <network-name>
```

### 🎮 `interact.js` - Script de Interacción Universal
Script interactivo para realizar operaciones administrativas y operacionales en cualquier red:

**Funcionalidades nuevas:**
- ✅ Compatible con nueva arquitectura modular
- ✅ Funciona en cualquier red
- ✅ Auto-detecta deployment files o usa direcciones conocidas
- ✅ Soporte para variables de entorno
- ✅ Manejo robusto de errores

**Comandos disponibles:**
- `setup-issuer <issuerAddr> <topicId>` - Agregar issuer confiable
- `register-investor <investorAddr> <identityAddr>` - Registrar identidad de inversor
- `mint <recipientAddr> <amount>` - Mintear tokens
- `set-agent <agentAddr> <true/false>` - Configurar estado de agente
- `check-agent <agentAddr>` - Verificar estado de agente
- `freeze <investorAddr>` - Congelar cuenta de inversor
- `unfreeze <investorAddr>` - Descongelar cuenta de inversor
- `balance <address>` - Consultar balance de tokens
- `total-supply` - Consultar supply total
- `transfer <toAddr> <amount>` - Transferir tokens
- `info` - Mostrar información completa del sistema
- `freeze <investorAddr>` - Congelar cuenta de inversor
- `unfreeze <investorAddr>` - Descongelar cuenta de inversor
- `compliance-rules` - Ver reglas de compliance
- `token-info` - Ver información del token
- `investor-info <investorAddr>` - Ver información de inversor
- `transfer-ownership <newOwnerAddr>` - Transferir propiedad

**Uso:**
```bash
# Método 1: Usando variables de entorno
$env:TREX_COMMAND='compliance-rules'
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Método 2: Usando argumentos directos
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK> -- compliance-rules

# Ejemplo: Mintear tokens
$env:TREX_COMMAND='mint'
$env:TREX_ARGS='0x1234567890123456789012345678901234567890 50000'
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```

**Uso con argumentos de línea de comandos (problemático en Hardhat):**
```bash
# No recomendado - Hardhat puede interpretar mal los argumentos
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK> info
```

**Uso recomendado con variables de entorno:**
```bash
# Mostrar información del sistema
$env:TREX_COMMAND="info"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Consultar balance
$env:TREX_COMMAND="balance"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Transferir tokens
$env:TREX_COMMAND="transfer"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2 100"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Mintear tokens (solo agentes)
$env:TREX_COMMAND="mint"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2 1000"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```

**Comandos Linux/Mac:**
```bash
# Mostrar información del sistema
TREX_COMMAND="info" npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Consultar balance
TREX_COMMAND="balance" TREX_ARGS="0x742d35Cc..." npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```


### Variables de Entorno (.env)
```bash
ADMIN_WALLET_PRIV_KEY=<tu_clave_privada>
INVESTOR1_PRIV_KEY=<clave_privada_opcional>
INVESTOR2_PRIV_KEY=<clave_privada_opcional>
```


## 🎯 Flujo de Uso Recomendado

1. **Desplegar el sistema:**
   ```bash
   npx hardhat run scripts/deploy.js --network <CUSTOM_NETWORK>
   ```

2. **Verificar el despliegue:**
   ```bash
   npx hardhat run scripts/verify.js --network <CUSTOM_NETWORK>
   ```

3. **Interactuar con el sistema:**
   ```bash
   # Ver reglas de compliance
   $env:TREX_COMMAND='compliance-rules'
   npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
   
   # Registrar un inversor
   $env:TREX_COMMAND='register-investor'
   $env:TREX_ARGS='0x... 0x...'
   npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
   
   # Mintear tokens
   $env:TREX_COMMAND='mint'
   $env:TREX_ARGS='0x... 1000'
   npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
   ```

## 🔧 Estructura de Storage Refactorizada

El sistema utiliza una estructura de storage aplanada que mejora la extensibilidad:

### Antes (Estructuras anidadas):
```solidity
struct Investor {
    address identity;
    uint16 country;
    bool frozen;
}
mapping(address => Investor) investors;
```

### Después (Estructura aplanada):
```solidity
mapping(address => address) investorIdentities;
mapping(address => uint16) investorCountries;
mapping(address => bool) investorFrozenStatus;
```

Esta refactorización permite:
- ✅ Mayor extensibilidad para agregar nuevos campos
- ✅ Mejor legibilidad del código
- ✅ Acceso directo a campos individuales
- ✅ Funcionalidad completamente preservada

## 📄 Archivos de Despliegue

Después del despliegue se generan automáticamente:
- `deployments/{network}-deployment.json` - Información del despliegue
- `deployments/{network}-diamond-abi.json` - ABI combinado del Diamond

## ⚠️ Notas Importantes

1. **Agentes vs Owner**: El owner puede configurar el sistema, pero necesita ser registrado como agent para realizar operaciones de tokens.

2. **Redes Persistentes**: Para usar `interact.js`, despliega en una red persistente (como <CUSTOM_NETWORK>) ya que Hardhat local se reinicia entre ejecuciones.

3. **Validación**: El sistema ha sido completamente validado en la red <CUSTOM_NETWORK> con todas las operaciones funcionando correctamente.

## 🎉 Estado del Proyecto

✅ **Refactorización Completada**: Storage aplanado implementado y validado  
✅ **Despliegue Exitoso**: Validado en red <CUSTOM_NETWORK>  
✅ **Funcionalidad Completa**: Todos los comandos de interacción funcionando  
✅ **Tests Pasando**: 18/18 pruebas exitosas

###  `verify.js` - Script de Verificación
Verifica que el despliegue sea correcto ejecutando múltiples pruebas:
- Contratos desplegados correctamente
- Propietario configurado
- Metadatos del token
- Reglas de cumplimiento
- Sistema de identidades
- Control de acceso

**Uso:**
```bash


# Ejemplo: Verificar despliegue en bscTestnet
npm run verify:bscTestnet
```

### `interact.js` - Script de Interacción
Proporciona comandos para operaciones administrativas y operacionales:

**Comandos disponibles:**
- `setup-issuer <address> <topicId>` - Agregar emisor confiable
- `register-investor <investorAddr> <idAddr>` - Registrar identidad de inversor
- `mint <recipient> <amount>` - Acuñar tokens
- `set-agent <address> <true/false>` - Configurar agentes
- `check-agent <address>` - Verificar estado de un agente
- `freeze <address>` - Congelar cuenta
- `unfreeze <address>` - Descongelar cuenta
- `compliance-rules` - Ver reglas de cumplimiento
- `token-info` - Ver información del token
- `investor-info <address>` - Ver información del inversor
- `transfer-ownership <address>` - Transferir propiedad

**Uso del script (con variables de entorno):**

**INFO:** Los argumentos de línea de comandos no funcionan directamente con `npx hardhat run` debido a limitaciones de Hardhat. 
Se debe usar el sistema de variables de entorno.

```bash
# Ver comandos disponibles
npm run interact:localhost

### Configuración Inicial
Topic ID 1: KYC (Know Your Customer)
Topic ID 2: AML (Anti-Money Laundering)
Topic ID 3+: Otros tipos de verificaciones personalizadas

# Agregar emisor KYC confiable
$env:TREX_COMMAND='setup-issuer'; $env:TREX_ARGS='0xKYC_PROVIDER_ADDRESS 1'; npm run interact:localhost

# Agregar emisor AML confiable  
$env:TREX_COMMAND='setup-issuer'; $env:TREX_ARGS='0xAML_PROVIDER_ADDRESS 2'; npm run interact:localhost

# Configurar agente operacional
$env:TREX_COMMAND='set-agent'; $env:TREX_ARGS='0xAGENT_ADDRESS true'; npm run interact:localhost

# Verificar estado de un agente
$env:TREX_COMMAND='check-agent'; $env:TREX_ARGS='0x789...ghi'; npm run interact:localhost

### Primeras Operaciones

# Registrar un inversor
$env:TREX_COMMAND='register-investor'; $env:TREX_ARGS='0xINVESTOR_ADDRESS 0xONCHAIN_ID_ADDRESS'; npm run interact:localhost

# Acuñar tokens iniciales
$env:TREX_COMMAND='mint'; $env:TREX_ARGS='0xINVESTOR_ADDRESS 10000'; npm run interact:localhost

# Verificar información
$env:TREX_COMMAND='investor-info'; $env:TREX_ARGS='0xINVESTOR_ADDRESS'; npm run interact:localhost
$env:TREX_COMMAND='token-info'; $env:TREX_ARGS=''; npm run interact:localhost

# Acuñar 1000 tokens
$env:TREX_COMMAND='mint'; $env:TREX_ARGS='0x456...def 1000'; npm run interact:localhost

```

## Archivos Generados

### `/deployments/`
Los scripts generan archivos de información del despliegue:

- `{network}-deployment.json` - Información completa del despliegue
- `{network}-diamond-abi.json` - ABI combinada del Diamond
- `{network}-verification.json` - Resultados de verificación


## Flujo de Despliegue Recomendado

### 1. Preparación
```bash
# Compilar contratos
npm run compile

# Ejecutar tests
npm run test
```

### 2. Despliegue en Red custom
```bash

# Desplegar en localhost - En este repo era una custom network
npm run deploy:localhost

# Verificar despliegue
npm run verify:localhost
```



### ✅ Facets Externos Soportados
- **TokenFacet** - Operaciones de tokens ERC-3643
- **RolesFacet** - Gestión de roles y permisos
- **IdentityFacet** - Registro de identidades
- **ComplianceFacet** - Reglas de cumplimiento
- **ClaimTopicsFacet** - Gestión de claim topics
- **TrustedIssuersFacet** - Gestión de issuers confiables

### ✅ Storage Modular
- **TokenStorage** - Estado de tokens aislado
- **RolesStorage** - Estado de roles aislado
- **IdentityStorage** - Estado de identidades aislado
- **ComplianceStorage** - Estado de compliance aislado
- **ClaimTopicsStorage** - Estado de claim topics aislado
- **TrustedIssuersStorage** - Estado de trusted issuers aislado




## 🚀 Ejemplos Prácticos

### Deployment y Verificación Completa
```bash
# 1. Desplegar en <CUSTOM_NETWORK>
npx hardhat run scripts/deploy.js --network <CUSTOM_NETWORK>

# 2. Verificar deployment
npx hardhat run scripts/verify.js --network <CUSTOM_NETWORK>

# 3. Mostrar información del sistema
$env:TREX_COMMAND="info"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```

### Operaciones de Administración
```bash
# Configurar agente
$env:TREX_COMMAND="set-agent"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2 true"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Mintear tokens iniciales
$env:TREX_COMMAND="mint"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2 10000"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```

### Operaciones de Usuario
```bash
# Consultar balance
$env:TREX_COMMAND="balance"
$env:TREX_ARGS="0x742d35Cc6606C8B4B8B8F4B2B8e2e2e2e2e2e2e2"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>

# Transferir tokens
$env:TREX_COMMAND="transfer"
$env:TREX_ARGS="0x123... 500"
npx hardhat run scripts/interact.js --network <CUSTOM_NETWORK>
```

## ✨ Mejoras en la Nueva Versión

### 🔄 Migración Completa
- ✅ **Storage Modular**: Cada dominio tiene su propio storage aislado
- ✅ **Facets Separados**: External/Internal facet pattern implementado
- ✅ **EIP-2535 Compliance**: Diamond standard completamente implementado
- ✅ **Compatibilidad Universal**: Scripts funcionan en cualquier red

### 🛠️ Funcionalidades Mejoradas
- ✅ **Auto-detección**: Encuentra automáticamente el diamond desplegado
- ✅ **Manejo de Errores**: Recuperación robusta de fallos
- ✅ **Reportes Detallados**: Información completa de estado
- ✅ **Variables de Entorno**: Solución para limitaciones de Hardhat

### 🎯 Listo para Producción
Todos los scripts están optimizados y listos para uso en entornos de producción con la nueva arquitectura modular de ISBE.

---

**📝 Actualizado**: Nueva arquitectura modular - Junio 2025  
**🔧 Compatibilidad**: Universal - Cualquier red EVM  
**🎯 Estado**: Listo para ampliar el protocolo t-rex


