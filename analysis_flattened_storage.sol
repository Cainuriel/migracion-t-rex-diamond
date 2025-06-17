// ANÁLISIS: AppStorage Aplanado
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// === VERSIÓN ACTUAL (Estructuras anidadas) ===
struct Investor {
    address identity;
    uint16 country;
    bool isFrozen;
}

struct Compliance {
    uint256 maxBalance;
    uint256 minBalance;
    uint256 maxInvestors;
}

struct AppStorageCurrent {
    mapping(address => Investor) investors;
    Compliance compliance;
    // ... otros campos
}

// === VERSIÓN PROPUESTA (Aplanado) ===
struct AppStorageFlattened {
    // === INVESTOR DATA (Aplanado) ===
    mapping(address => address) investorIdentities;
    mapping(address => uint16) investorCountries;
    mapping(address => bool) investorFrozenStatus;
    
    // === COMPLIANCE DATA (Aplanado) ===
    uint256 complianceMaxBalance;
    uint256 complianceMinBalance;
    uint256 complianceMaxInvestors;
    
    // === OTROS CAMPOS ===
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    address owner;
    mapping(address => bool) agents;
    address[] complianceModules;
    uint256[] claimTopics;
    mapping(uint256 => address[]) trustedIssuers;
    address[] holders;
}

// === COMPARACIÓN DE ACCESO ===

// ACTUAL (Estructuras anidadas):
// s.investors[user].isFrozen
// s.investors[user].identity  
// s.investors[user].country
// s.compliance.maxBalance

// APLANADO:
// s.investorFrozenStatus[user]
// s.investorIdentities[user]
// s.investorCountries[user]
// s.complianceMaxBalance
