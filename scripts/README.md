# T-REX Diamond Scripts

Este directorio contiene los scripts principales para desplegar, verificar e interactuar con el sistema T-REX Diamond refactorizado.

## 📁 Scripts Disponibles

### 🚀 `deploy.js` - Script de Despliegue Principal
Despliega todo el sistema T-REX Diamond con la nueva estructura de storage aplanada:
- Diamond contract principal
- Todos los facets (Token, Compliance, Identity, Roles, ClaimTopics, TrustedIssuers)
- Configuración inicial del sistema
- Reglas de cumplimiento básicas

**Uso:**
```bash
# Despliegue en red Alastria
npx hardhat run scripts/deploy.js --network alastria

# Despliegue en BSC testnet
npx hardhat run scripts/deploy.js --network bscTestnet

# Despliegue en red local
npx hardhat run scripts/deploy.js --network localhost
```

### 🔍 `verify.js` - Script de Verificación
Verifica que el despliegue se haya completado correctamente:
- Valida que todos los facets estén correctamente registrados
- Verifica la configuración inicial
- Comprueba las reglas de compliance
- Valida el estado de agentes y permisos

**Uso:**
```bash
# Verificar despliegue en Alastria
npx hardhat run scripts/verify.js --network alastria

# Verificar despliegue en BSC testnet
npx hardhat run scripts/verify.js --network bscTestnet
```

### 🎮 `interact.js` - Script de Interacción
Script interactivo para realizar operaciones administrativas y operacionales:

**Comandos disponibles:**
- `setup-issuer <issuerAddr> <topicId>` - Agregar issuer confiable
- `register-investor <investorAddr> <identityAddr>` - Registrar identidad de inversor
- `mint <recipientAddr> <amount>` - Mintear tokens
- `set-agent <agentAddr> <true/false>` - Configurar estado de agente
- `check-agent <agentAddr>` - Verificar estado de agente
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
npx hardhat run scripts/interact.js --network alastria

# Método 2: Usando argumentos directos
npx hardhat run scripts/interact.js --network alastria -- compliance-rules

# Ejemplo: Mintear tokens
$env:TREX_COMMAND='mint'
$env:TREX_ARGS='0x1234567890123456789012345678901234567890 50000'
npx hardhat run scripts/interact.js --network alastria
```

## 🌐 Redes Configuradas

### Alastria
- **URL**: http://108.142.237.13:8545
- **Gas Price**: 0 (red sin gas)
- **Estado**: ✅ Validado - Despliegue y operaciones exitosas

### BSC Testnet
- **URL**: https://data-seed-prebsc-1-s1.bnbchain.org:8545
- **Gas Price**: 400 Gwei
- **Estado**: ⚠️ No validado

### Taycan (Local)
- **URL**: http://5.250.188.118:8545
- **Estado**: ❌ No disponible

## 📋 Configuración Requerida

### Variables de Entorno (.env)
```bash
ADMIN_WALLET_PRIV_KEY=<tu_clave_privada>
INVESTOR1_PRIV_KEY=<clave_privada_opcional>
INVESTOR2_PRIV_KEY=<clave_privada_opcional>
```

### Configuración de Red (hardhat.config.ts)
Las redes están preconfiguradas. Asegúrate de que tu wallet tenga fondos suficientes para el despliegue en redes que requieren gas.

## 🎯 Flujo de Uso Recomendado

1. **Desplegar el sistema:**
   ```bash
   npx hardhat run scripts/deploy.js --network alastria
   ```

2. **Verificar el despliegue:**
   ```bash
   npx hardhat run scripts/verify.js --network alastria
   ```

3. **Interactuar con el sistema:**
   ```bash
   # Ver reglas de compliance
   $env:TREX_COMMAND='compliance-rules'
   npx hardhat run scripts/interact.js --network alastria
   
   # Registrar un inversor
   $env:TREX_COMMAND='register-investor'
   $env:TREX_ARGS='0x... 0x...'
   npx hardhat run scripts/interact.js --network alastria
   
   # Mintear tokens
   $env:TREX_COMMAND='mint'
   $env:TREX_ARGS='0x... 1000'
   npx hardhat run scripts/interact.js --network alastria
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

2. **Redes Persistentes**: Para usar `interact.js`, despliega en una red persistente (como Alastria) ya que Hardhat local se reinicia entre ejecuciones.

3. **Validación**: El sistema ha sido completamente validado en la red Alastria con todas las operaciones funcionando correctamente.

## 🎉 Estado del Proyecto

✅ **Refactorización Completada**: Storage aplanado implementado y validado  
✅ **Despliegue Exitoso**: Validado en red Alastria  
✅ **Funcionalidad Completa**: Todos los comandos de interacción funcionando  
✅ **Tests Pasando**: 5/5 pruebas exitosas

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
# Verificar despliegue en red local
npm run verify:localhost

# Verificar despliegue en bscTestnet
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

### 2. Despliegue en Red Local
```bash

# Desplegar en localhost
npm run deploy:localhost

# Verificar despliegue
npm run verify:localhost
```


