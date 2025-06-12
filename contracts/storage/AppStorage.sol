// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

struct AppStorage {
    mapping(address => Investor) investors;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    string name;
    string symbol;
    uint8 decimals;
    Compliance compliance;
    address owner;
    mapping(address => bool) agents;
    address[] complianceModules;
    uint256[] claimTopics;
    mapping(uint256 => address[]) trustedIssuers;
    address[] holders;
}



