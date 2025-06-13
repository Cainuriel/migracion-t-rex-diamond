# T-REX Diamond Deployment Scripts

Este directorio contiene los scripts para desplegar, verificar e interactuar con el sistema T-REX Diamond.

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

### 🔧 `interact.js` - Script de Interacción
Proporciona comandos para operaciones administrativas y operacionales:

**Comandos disponibles:**
- `setup-issuer <address> <topicId>` - Agregar emisor confiable
- `register-investor <investorAddr> <idAddr>` - Registrar identidad de inversor
- `mint <recipient> <amount>` - Acuñar tokens
- `set-agent <address> <true/false>` - Configurar agentes
- `freeze <address>` - Congelar cuenta
- `unfreeze <address>` - Descongelar cuenta
- `compliance-rules` - Ver reglas de cumplimiento
- `token-info` - Ver información del token
- `investor-info <address>` - Ver información del inversor
- `transfer-ownership <address>` - Transferir propiedad

**Ejemplos de uso:**
```bash
# Ver comandos disponibles
npm run interact

# Configurar un emisor KYC
npm run interact setup-issuer 0x123...abc 1

# Acuñar 1000 tokens
npm run interact mint 0x456...def 1000

# Ver información del token
npm run interact token-info

# Agregar un agente
npm run interact set-agent 0x789...ghi true
```

## 📁 Archivos Generados

### `/deployments/`
Los scripts generan archivos de información del despliegue:

- `{network}-deployment.json` - Información completa del despliegue
- `{network}-diamond-abi.json` - ABI combinada del Diamond
- `{network}-verification.json` - Resultados de verificación

**Ejemplo de estructura:**
```
deployments/
├── localhost-deployment.json
├── localhost-diamond-abi.json
├── localhost-verification.json
├── sepolia-deployment.json
├── sepolia-diamond-abi.json
└── sepolia-verification.json
```

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
# Iniciar nodo local (terminal separado)
npx hardhat node

# Desplegar en localhost
npm run deploy:localhost

# Verificar despliegue
npm run verify:localhost
```

### 3. Configuración Inicial
```bash
# Agregar emisor KYC confiable
npm run interact:localhost setup-issuer 0xKYC_PROVIDER_ADDRESS 1

# Agregar emisor AML confiable  
npm run interact:localhost setup-issuer 0xAML_PROVIDER_ADDRESS 2

# Configurar agente operacional
npm run interact:localhost set-agent 0xAGENT_ADDRESS true
```

### 4. Primeras Operaciones
```bash
# Registrar un inversor
npm run interact:localhost register-investor 0xINVESTOR_ADDRESS 0xONCHAIN_ID_ADDRESS

# Acuñar tokens iniciales
npm run interact:localhost mint 0xINVESTOR_ADDRESS 10000

# Verificar información
npm run interact:localhost investor-info 0xINVESTOR_ADDRESS
npm run interact:localhost token-info
```

### 5. Despliegue en Testnet/Mainnet
```bash

# Desplegar en bscTestnet
npm run deploy:bscTestnet

# Verificar despliegue
npm run verify:bscTestnet
```


```

## Consejos

##  Solución de Problemas

### Error: "Deployment file not found"
```bash
# Asegúrate de haber desplegado primero
npm run deploy:localhost

# Luego ejecutar verificación o interacción
npm run verify:localhost
```

## 📚 Recursos Adicionales

- [Documentación T-REX](../docs/)
- [Tests del sistema](../test/)
- [Contratos fuente](../contracts/)
- [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535)
- [T-REX Standard](https://github.com/TokenySolutions/T-REX)
