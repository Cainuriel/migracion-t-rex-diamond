// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct Compliance {
    uint256 maxBalance;
    uint256 minBalance;
    uint256 maxInvestors;
}

struct AppStorage {
    // === INVESTOR DATA (Aplanado para extensibilidad) ===
    mapping(address => address) investorIdentities;
    mapping(address => uint16) investorCountries;
    mapping(address => bool) investorFrozenStatus;
    
    // === TOKEN CORE ===
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    
    // === ACCESS CONTROL ===
    address owner;
    mapping(address => bool) agents;
    
    // === COMPLIANCE (Agrupado - cambia poco) ===
    Compliance compliance;
    
    // === T-REX SPECIFIC ===
    address[] complianceModules;
    uint256[] claimTopics;
    mapping(uint256 => address[]) trustedIssuers;
    address[] holders;
}



