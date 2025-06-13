# T-REX Diamond Deployment Scripts

Este directorio contiene los scripts para desplegar, verificar e interactuar con el sistema T-REX Diamond.

> ⚠️ **Atención:** la red `localhost` utilizada en estos ejemplos es una red personal hyperledger besu llamada **Taycan** y **no está incluida** en este repositorio. Configure su propia red `localhost` para realizar pruebas. No olvide actualizar el ``` package.json ``` para que los comandos funcionen correctamente: 
```json
    "test-serialization": "npx hardhat run scripts/test-serialization.js",
    "deploy:localhost": "npx hardhat run scripts/deploy.js --network <SU_RED_LOCAL>",
    "deploy:bscTestnet": "npx hardhat run scripts/deploy.js --network bscTestnet",
    "deploy:mainnet": "npx hardhat run scripts/deploy.js --network mainnet",
    
    "verify:localhost": "npx hardhat run scripts/verify.js --network <SU_RED_LOCAL>"",
    "verify:bscTestnet": "npx hardhat run scripts/verify.js --network bscTestnet",
    "interact": "npx hardhat run scripts/interact.js",
    "interact:localhost": "npx hardhat run scripts/interact.js --network <SU_RED_LOCAL>"",
    "interact:bscTestnet": "npx hardhat run scripts/interact.js --network bscTestnet",
```

##  Scripts Disponibles

###  `deploy.js` - Script de Despliegue Principal
Despliega todo el sistema T-REX Diamond incluyendo:
- Diamond contract principal
- Todos los facets (Token, Compliance, Identity, etc.)
- Configuración inicial del sistema
- Reglas de cumplimiento básicas

**Uso:**
```bash
# Despliegue en red local
npm run deploy:localhost

# Despliegue en bscTestnet testnet
npm run deploy:bscTestnet

# Despliegue en mainnet
npm run deploy:mainnet
```

**Configuración:**
Edita las variables en la sección `config` del script para personalizar:
- Nombre y símbolo del token
- Reglas de cumplimiento (límites de balance, inversores, etc.)
- Agentes iniciales
- Propietario inicial
- `ownerAsAgent`: Si el owner debe ser registrado automáticamente como agent (recomendado: `true`)

**Nota importante sobre Agents:**
En T-REX, el **owner** del contrato puede configurar el sistema pero necesita ser explícitamente registrado como **agent** para realizar operaciones de tokens (mint, burn, force transfer). El parámetro `ownerAsAgent: true` (por defecto) registra automáticamente al deployer como agent durante el despliegue.

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


