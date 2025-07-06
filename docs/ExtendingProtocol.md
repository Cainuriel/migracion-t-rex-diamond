# Extending the T-REX Diamond Protocol

## Overview

This guide explains how to **add new functionality** to our T-REX Diamond implementation while maintaining the architectural principles and ensuring compatibility with the existing ERC-3643 system.

## Understanding the Extension Model

Our Diamond architecture is designed to be **easily extensible**. You can add new functionality by:

1. **Creating New Facets**: Add completely new domains of functionality
2. **Extending Existing Facets**: Add functions to existing domains
3. **Creating Specialized Modules**: Build specific compliance or identity modules
4. **Integrating External Systems**: Connect with other protocols

## Architecture Patterns to Follow

### 1. **Dual Facet Pattern**

Always implement functionality using the **Internal/External** pattern:

```
New Feature Domain
├── ExternalFacet.sol     # Public interface
└── InternalFacet.sol     # Business logic & storage
```

**External Facet Responsibilities:**
- Input validation
- Access control
- Event emission
- User-friendly interface

**Internal Facet Responsibilities:**
- Business logic implementation
- Storage management
- Cross-facet communication
- Complex operations

### 2. **Encapsulated Storage**

Each new domain must manage its own storage:

```solidity
contract YourInternalFacet {
    // Define domain-specific storage
    struct YourStorage {
        mapping(address => uint256) yourData;
        uint256 yourCounter;
        address[] yourArray;
    }

    // Unique storage slot for your domain
    bytes32 constant YOUR_STORAGE_POSITION = keccak256("your.domain.storage");

    function _getYourStorage() internal pure returns (YourStorage storage ys) {
        bytes32 position = YOUR_STORAGE_POSITION;
        assembly { ys.slot := position }
    }
}
```

### 3. **Interface Segregation**

Create separate interfaces for each concern:

```
contracts/interfaces/
├── events/IYourEvents.sol
├── errors/IYourErrors.sol
├── structs/IYourStructs.sol
└── storage/IYourStorage.sol
```

## Step-by-Step Guide: Adding a New Feature

Let's walk through adding a **"Dividend Distribution"** feature as an example.

### Step 1: Design the Feature

**Requirements:**
- Track dividend entitlements
- Distribute dividends to eligible holders
- Compliance with securities regulations
- Integration with existing token balances

### Step 2: Create Interface Definitions

#### Events Interface
```solidity
// contracts/interfaces/events/IDividendEvents.sol
pragma solidity 0.8.17;

interface IDividendEvents {
    event DividendDeclared(
        uint256 indexed dividendId,
        uint256 totalAmount,
        uint256 recordDate,
        uint256 paymentDate
    );
    
    event DividendPaid(
        uint256 indexed dividendId,
        address indexed investor,
        uint256 amount
    );
    
    event DividendClaimed(
        uint256 indexed dividendId,
        address indexed investor,
        uint256 amount
    );
}
```

#### Errors Interface
```solidity
// contracts/interfaces/errors/IDividendErrors.sol
pragma solidity 0.8.17;

interface IDividendErrors {
    error DividendNotFound(uint256 dividendId);
    error DividendAlreadyPaid(uint256 dividendId, address investor);
    error DividendNotYetPayable(uint256 dividendId, uint256 currentTime);
    error InsufficientDividendFunds(uint256 required, uint256 available);
    error InvalidRecordDate(uint256 recordDate);
}
```

#### Structs Interface
```solidity
// contracts/interfaces/structs/IDividendStructs.sol
pragma solidity 0.8.17;

interface IDividendStructs {
    struct Dividend {
        uint256 id;
        uint256 totalAmount;
        uint256 recordDate;
        uint256 paymentDate;
        uint256 totalPaid;
        bool isActive;
    }
    
    struct InvestorEntitlement {
        uint256 dividendId;
        address investor;
        uint256 entitlement;
        bool claimed;
    }
}
```

### Step 3: Create the Internal Facet (Business Logic)

```solidity
// contracts/facets/internal/DividendInternalFacet.sol
pragma solidity 0.8.17;

import { IDividendEvents } from "../../interfaces/events/IDividendEvents.sol";
import { IDividendErrors } from "../../interfaces/errors/IDividendErrors.sol";
import { IDividendStructs } from "../../interfaces/structs/IDividendStructs.sol";

contract DividendInternalFacet is IDividendEvents, IDividendErrors, IDividendStructs {

    // ================== STORAGE ==================
    
    struct DividendStorage {
        mapping(uint256 => Dividend) dividends;
        mapping(uint256 => mapping(address => InvestorEntitlement)) entitlements;
        mapping(address => uint256[]) investorDividends;
        uint256 nextDividendId;
        uint256 totalDividendsFunds;
    }

    bytes32 constant DIVIDEND_STORAGE_POSITION = keccak256("dividend.storage.location");

    function _getDividendStorage() internal pure returns (DividendStorage storage ds) {
        bytes32 position = DIVIDEND_STORAGE_POSITION;
        assembly { ds.slot := position }
    }

    // ================== INTERNAL FUNCTIONS ==================

    function _declareDividend(
        uint256 totalAmount,
        uint256 recordDate,
        uint256 paymentDate
    ) internal returns (uint256 dividendId) {
        DividendStorage storage ds = _getDividendStorage();
        
        // Validations
        if (recordDate >= block.timestamp) revert InvalidRecordDate(recordDate);
        if (ds.totalDividendsFunds < totalAmount) {
            revert InsufficientDividendFunds(totalAmount, ds.totalDividendsFunds);
        }

        // Create dividend
        dividendId = ds.nextDividendId++;
        ds.dividends[dividendId] = Dividend({
            id: dividendId,
            totalAmount: totalAmount,
            recordDate: recordDate,
            paymentDate: paymentDate,
            totalPaid: 0,
            isActive: true
        });

        // Calculate entitlements based on record date balances
        _calculateEntitlements(dividendId, recordDate);

        emit DividendDeclared(dividendId, totalAmount, recordDate, paymentDate);
    }

    function _calculateEntitlements(uint256 dividendId, uint256 recordDate) internal {
        // Integration with TokenInternalFacet to get balances at record date
        // This would require additional implementation for historical balance tracking
        
        DividendStorage storage ds = _getDividendStorage();
        TokenInternalFacet tokenFacet = TokenInternalFacet(address(this));
        
        // Get all token holders (this example assumes current balances)
        address[] memory holders = tokenFacet._getHolders();
        uint256 totalSupply = tokenFacet._getTotalSupply();
        
        for (uint i = 0; i < holders.length; i++) {
            address investor = holders[i];
            uint256 balance = tokenFacet._getBalance(investor);
            
            if (balance > 0) {
                uint256 entitlement = (ds.dividends[dividendId].totalAmount * balance) / totalSupply;
                
                ds.entitlements[dividendId][investor] = InvestorEntitlement({
                    dividendId: dividendId,
                    investor: investor,
                    entitlement: entitlement,
                    claimed: false
                });
                
                ds.investorDividends[investor].push(dividendId);
            }
        }
    }

    function _claimDividend(address investor, uint256 dividendId) internal returns (uint256 amount) {
        DividendStorage storage ds = _getDividendStorage();
        
        // Validations
        if (!ds.dividends[dividendId].isActive) revert DividendNotFound(dividendId);
        if (block.timestamp < ds.dividends[dividendId].paymentDate) {
            revert DividendNotYetPayable(dividendId, block.timestamp);
        }
        
        InvestorEntitlement storage entitlement = ds.entitlements[dividendId][investor];
        if (entitlement.claimed) revert DividendAlreadyPaid(dividendId, investor);
        
        // Mark as claimed and update totals
        amount = entitlement.entitlement;
        entitlement.claimed = true;
        ds.dividends[dividendId].totalPaid += amount;
        
        // Transfer logic would go here (integration with payment system)
        
        emit DividendPaid(dividendId, investor, amount);
        emit DividendClaimed(dividendId, investor, amount);
    }

    // ================== VIEW FUNCTIONS ==================

    function _getDividendEntitlement(address investor, uint256 dividendId) 
        internal view returns (uint256) {
        DividendStorage storage ds = _getDividendStorage();
        return ds.entitlements[dividendId][investor].entitlement;
    }

    function _getInvestorDividends(address investor) 
        internal view returns (uint256[] memory) {
        DividendStorage storage ds = _getDividendStorage();
        return ds.investorDividends[investor];
    }
}
```

### Step 4: Create the External Facet (Public Interface)

```solidity
// contracts/facets/DividendFacet.sol
pragma solidity 0.8.17;

import { DividendInternalFacet } from "./internal/DividendInternalFacet.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IDividendEvents } from "../interfaces/events/IDividendEvents.sol";
import { IDividendErrors } from "../interfaces/errors/IDividendErrors.sol";

contract DividendFacet is IDividendEvents, IDividendErrors {

    // ================== ACCESS CONTROL ==================

    modifier onlyOwner() {
        if (msg.sender != LibDiamond.contractOwner()) revert Unauthorized(msg.sender);
        _;
    }

    modifier onlyAgent() {
        RolesInternalFacet rolesFacet = RolesInternalFacet(address(this));
        if (!rolesFacet._isAgent(msg.sender)) revert Unauthorized(msg.sender);
        _;
    }

    // ================== ADMINISTRATIVE FUNCTIONS ==================

    function declareDividend(
        uint256 totalAmount,
        uint256 recordDate,
        uint256 paymentDate
    ) external onlyOwner returns (uint256 dividendId) {
        DividendInternalFacet internalFacet = DividendInternalFacet(address(this));
        return internalFacet._declareDividend(totalAmount, recordDate, paymentDate);
    }

    // ================== USER FUNCTIONS ==================

    function claimDividend(uint256 dividendId) external returns (uint256 amount) {
        DividendInternalFacet internalFacet = DividendInternalFacet(address(this));
        return internalFacet._claimDividend(msg.sender, dividendId);
    }

    // ================== VIEW FUNCTIONS ==================

    function getDividendEntitlement(address investor, uint256 dividendId) 
        external view returns (uint256) {
        DividendInternalFacet internalFacet = DividendInternalFacet(address(this));
        return internalFacet._getDividendEntitlement(investor, dividendId);
    }

    function getInvestorDividends(address investor) 
        external view returns (uint256[] memory) {
        DividendInternalFacet internalFacet = DividendInternalFacet(address(this));
        return internalFacet._getInvestorDividends(investor);
    }
}
```

### Step 5: Create Storage Accessor (Optional)

For complex integrations, create a storage accessor:

```solidity
// contracts/abstracts/DividendStorageAccessor.sol
pragma solidity 0.8.17;

import { BaseStorageAccessor } from "./BaseStorageAccessor.sol";

abstract contract DividendStorageAccessor is BaseStorageAccessor {
    
    struct DividendStorage {
        // ... same as in DividendInternalFacet
    }

    bytes32 constant DIVIDEND_STORAGE_POSITION = keccak256("dividend.storage.location");

    function _getDividendStorage() internal pure returns (DividendStorage storage ds) {
        bytes32 position = DIVIDEND_STORAGE_POSITION;
        assembly { ds.slot := position }
    }

    // Helper functions for common operations
    function _hasDividendEntitlement(address investor, uint256 dividendId) 
        internal view returns (bool) {
        DividendStorage storage ds = _getDividendStorage();
        return ds.entitlements[dividendId][investor].entitlement > 0;
    }
}
```

### Step 6: Update Deployment Scripts

Add the new facets to your deployment script:

```javascript
// In scripts/deploy.js
const DividendFacet = await ethers.getContractFactory("DividendFacet");
const dividendFacet = await DividendFacet.deploy();
await dividendFacet.deployed();

const DividendInternalFacet = await ethers.getContractFactory("DividendInternalFacet");
const dividendInternalFacet = await DividendInternalFacet.deploy();
await dividendInternalFacet.deployed();

// Add to diamond cuts
const cuts = [
  // ... existing facets
  {
    facetAddress: dividendFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(dividendFacet)
  }
];
```

### Step 7: Write Tests

```javascript
// test/dividend.test.js
describe("Dividend Distribution", function() {
  it("should declare dividend correctly", async function() {
    const totalAmount = ethers.utils.parseEther("1000");
    const recordDate = Math.floor(Date.now() / 1000) - 86400; // Yesterday
    const paymentDate = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
    
    await dividend.declareDividend(totalAmount, recordDate, paymentDate);
    
    // Verify dividend was created
    const entitlement = await dividend.getDividendEntitlement(investor.address, 0);
    expect(entitlement).to.be.gt(0);
  });
});
```

## Integration Patterns

### 1. **Cross-Facet Data Access**

When your new facet needs data from existing facets:

```solidity
contract YourInternalFacet {
    function yourFunction() internal {
        // Access token data
        TokenInternalFacet tokenFacet = TokenInternalFacet(address(this));
        uint256 balance = tokenFacet._getBalance(user);
        
        // Access compliance data
        ComplianceInternalFacet complianceFacet = ComplianceInternalFacet(address(this));
        bool isCompliant = complianceFacet._validateCompliance(user);
        
        // Your logic here
    }
}
```

### 2. **Event Coordination**

Emit events that other systems can listen to:

```solidity
// Emit comprehensive events for external integration
emit YourDomainEvent({
    user: user,
    amount: amount,
    tokenBalance: currentBalance,
    complianceStatus: isCompliant,
    timestamp: block.timestamp
});
```

### 3. **Access Control Integration**

Use existing role system:

```solidity
modifier onlyAuthorizedUser() {
    RolesInternalFacet rolesFacet = RolesInternalFacet(address(this));
    require(
        rolesFacet._isAgent(msg.sender) || 
        rolesFacet._hasSpecialPermission(msg.sender, "YOUR_PERMISSION"),
        "Unauthorized"
    );
    _;
}
```

## Common Extension Scenarios

### 1. **Adding Compliance Modules**

For jurisdiction-specific compliance:

```solidity
contract EUComplianceInternalFacet {
    struct EUComplianceStorage {
        mapping(address => bool) mifidCompliant;
        mapping(address => string) vatNumbers;
        mapping(uint256 => bool) restrictedCountries;
    }
    
    function _validateEUCompliance(address investor) internal view returns (bool) {
        // EU-specific validation logic
    }
}
```

### 2. **Enhanced Identity Features**

For advanced KYC/AML:

```solidity
contract EnhancedIdentityInternalFacet {
    struct EnhancedIdentityStorage {
        mapping(address => uint256) riskScores;
        mapping(address => uint256) lastKYCUpdate;
        mapping(address => bool) pepStatus;
        mapping(address => string[]) sanctions;
    }
    
    function _calculateRiskScore(address investor) internal view returns (uint256) {
        // Advanced risk calculation
    }
}
```

### 3. **Advanced Token Features**

For complex token mechanics:

```solidity
contract VotingInternalFacet {
    struct VotingStorage {
        mapping(uint256 => Proposal) proposals;
        mapping(uint256 => mapping(address => bool)) hasVoted;
        mapping(address => uint256) votingPower;
    }
    
    function _createProposal(string memory description) internal returns (uint256) {
        // Voting proposal logic
    }
}
```

## Best Practices

### 1. **Storage Management**
- Always use unique storage slots
- Keep storage structures flat when possible
- Plan for future expansion
- Document storage layout changes

### 2. **Error Handling**
- Use custom errors for gas efficiency
- Provide meaningful error messages
- Include relevant context in errors
- Follow existing error naming conventions

### 3. **Access Control**
- Leverage existing role system
- Add new roles only when necessary
- Document permission requirements
- Test access control thoroughly

### 4. **Integration**
- Minimize cross-facet dependencies
- Use events for loose coupling
- Design for composability
- Maintain interface stability

### 5. **Testing**
- Test in isolation first
- Test integration scenarios
- Test upgrade scenarios
- Test gas usage

## Future-Proofing

### 1. **Interface Versioning**
Plan for interface evolution:

```solidity
interface IYourFacetV1 {
    function basicFunction() external;
}

interface IYourFacetV2 is IYourFacetV1 {
    function enhancedFunction() external;
}
```

### 2. **Migration Support**
Design for smooth upgrades:

```solidity
contract YourInternalFacetV2 {
    function migrate() external onlyOwner {
        // Migration logic for storage format changes
    }
}
```

### 3. **Backwards Compatibility**
Maintain existing interfaces when possible:

```solidity
// Keep old function for compatibility
function oldFunction() external {
    return newFunction();
}

function newFunction() public returns (uint256) {
    // New implementation
}
```

## Roadmap Integration

Consider how your extension fits into the broader roadmap:

### Current Gaps to Address
1. **Advanced Compliance Modules**
2. **Full OnChain-ID Integration**
3. **Multi-Jurisdiction Support**
4. **Complex Transfer Restrictions**
5. **Advanced Claim Verification**

### Integration Points
- How does your feature work with compliance?
- Does it need identity verification?
- Should it respect transfer restrictions?
- How does it handle different jurisdictions?

By following these patterns and practices, you can extend the T-REX Diamond system while maintaining its architectural integrity and ensuring compatibility with future enhancements.

## Related Documentation
- [Architecture Overview](./Architecture.md) - Complete system architecture
- [Diamond Infrastructure](./DiamondInfrastructure.md) - Diamond pattern implementation
- [DiamondCutFacet](./DiamondCutFacet.md) - Upgrade management
- [Token Contract](./TokenContract.md) - Core token functionality
- [Identity Contract](./IdentityContract.md) - Identity management system
- [Compliance Contract](./ComplianceContract.md) - Compliance engine
- [Roles Contract](./RolesContract.md) - Access control system
