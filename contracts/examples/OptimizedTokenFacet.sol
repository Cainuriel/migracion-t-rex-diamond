// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MultiDomainStorageAccessor } from "../abstracts/MultiDomainStorageAccessor.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title OptimizedTokenFacet - Example facet using advanced storage accessors
/// @dev Demonstrates the use of MultiDomainStorageAccessor for cleaner, safer code
/// @dev This is an alternative implementation showing best practices for Fase 3
contract OptimizedTokenFacet is MultiDomainStorageAccessor, IEIP2535Introspection {
    
    // ================== ERC20 FUNCTIONS WITH ENHANCED SAFETY ==================
    
    /// @notice Get token name with validation
    /// @return Token name
    function name() external view returns (string memory) {
        require(_isTokenStorageInitialized(), "OptimizedTokenFacet: Token not initialized");
        return _getTokenStorage().name;
    }
    
    /// @notice Get token symbol with validation
    /// @return Token symbol
    function symbol() external view returns (string memory) {
        require(_isTokenStorageInitialized(), "OptimizedTokenFacet: Token not initialized");
        return _getTokenStorage().symbol;
    }
    
    /// @notice Get token decimals with validation
    /// @return Token decimals
    function decimals() external view returns (uint8) {
        require(_isTokenStorageInitialized(), "OptimizedTokenFacet: Token not initialized");
        return _getTokenStorage().decimals;
    }
    
    /// @notice Get total supply using safe accessor
    /// @return Total token supply
    function totalSupply() external view returns (uint256) {
        return _getTotalSupply();
    }
    
    /// @notice Get balance using safe accessor
    /// @param account Account address
    /// @return Account balance
    function balanceOf(address account) external view returns (uint256) {
        return _getBalance(account);
    }
    
    /// @notice Get allowance using safe accessor
    /// @param owner Owner address
    /// @param spender Spender address
    /// @return Allowance amount
    function allowance(address owner, address spender) external view returns (uint256) {
        return _getAllowance(owner, spender);
    }
    
    // ================== ENHANCED TRANSFER WITH CROSS-DOMAIN VALIDATION ==================
    
    /// @notice Transfer tokens with comprehensive validation
    /// @param to Recipient address
    /// @param amount Transfer amount
    /// @return True if transfer successful
    function transfer(address to, uint256 amount) external returns (bool) {
        return _performTransfer(msg.sender, to, amount);
    }
    
    /// @notice Transfer from with comprehensive validation
    /// @param from Sender address
    /// @param to Recipient address
    /// @param amount Transfer amount
    /// @return True if transfer successful
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        // Check allowance
        uint256 currentAllowance = _getAllowance(from, msg.sender);
        require(currentAllowance >= amount, "OptimizedTokenFacet: Insufficient allowance");
        
        // Perform transfer
        bool success = _performTransfer(from, to, amount);
        
        // Update allowance if transfer successful
        if (success && currentAllowance != type(uint256).max) {
            TokenStorage storage ts = _getTokenStorage();
            ts.allowances[from][msg.sender] = currentAllowance - amount;
        }
        
        return success;
    }
    
    /// @notice Approve spender with enhanced safety
    /// @param spender Spender address
    /// @param amount Approval amount
    /// @return True if approval successful
    function approve(address spender, uint256 amount) external returns (bool) {
        _requireNotZero(spender, "OptimizedTokenFacet: Cannot approve zero address");
        
        TokenStorage storage ts = _getTokenStorage();
        ts.allowances[msg.sender][spender] = amount;
        
        return true;
    }
    
    // ================== PRIVILEGED OPERATIONS ==================
    
    /// @notice Mint tokens with comprehensive validation
    /// @param to Recipient address
    /// @param amount Mint amount
    function mint(address to, uint256 amount) external {
        _requireOwnerOrAgent(msg.sender);
        _requireNotZero(to, "OptimizedTokenFacet: Cannot mint to zero address");
        
        // Validate compliance before minting
        uint256 newBalance = _getBalance(to) + amount;
        require(_isBalanceCompliant(newBalance), "OptimizedTokenFacet: Mint would violate compliance");
        
        // Check investor limits if creating new investor
        if (_getBalance(to) == 0) {
            require(_isInvestorCountCompliant(), "OptimizedTokenFacet: Would exceed investor limit");
        }
        
        TokenStorage storage ts = _getTokenStorage();
        ts.balances[to] += amount;
        ts.totalSupply += amount;
        
        // Add to holders if new investor
        if (newBalance == amount) {
            ts.holders.push(to);
        }
    }
    
    /// @notice Freeze account with role validation
    /// @param account Account to freeze
    function freezeAccount(address account) external {
        _requireOwnerOrAgent(msg.sender);
        _requireNotZero(account, "OptimizedTokenFacet: Cannot freeze zero address");
        
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.frozenInvestors[account] = true;
    }
    
    /// @notice Unfreeze account with role validation
    /// @param account Account to unfreeze
    function unfreezeAccount(address account) external {
        _requireOwnerOrAgent(msg.sender);
        _requireNotZero(account, "OptimizedTokenFacet: Cannot unfreeze zero address");
        
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.frozenInvestors[account] = false;
    }
    
    // ================== INTERNAL TRANSFER LOGIC ==================
    
    /// @notice Internal transfer function with comprehensive validation
    /// @param from Sender address
    /// @param to Recipient address
    /// @param amount Transfer amount
    /// @return True if transfer successful
    function _performTransfer(address from, address to, uint256 amount) internal returns (bool) {
        // Use cross-domain validation
        require(_validateTransfer(from, to, amount), "OptimizedTokenFacet: Transfer validation failed");
        
        TokenStorage storage ts = _getTokenStorage();
        
        // Perform the transfer
        ts.balances[from] -= amount;
        ts.balances[to] += amount;
        
        // Update holders array if needed
        if (ts.balances[to] == amount) {
            // New holder
            ts.holders.push(to);
        }
        
        // Update compliance storage
        ComplianceStorage storage cs = _getComplianceStorage();
        cs.lastTransferTime[from] = block.timestamp;
        cs.lastTransferTime[to] = block.timestamp;
        
        return true;
    }
    
    // ================== IEIP2535Introspection IMPLEMENTATION ==================
    
    /// @notice Get function selectors supported by this facet for introspection
    /// @return selectors_ Array of function selectors
    function selectorsIntrospection() external pure returns (bytes4[] memory selectors_) {
        selectors_ = new bytes4[](13);
        selectors_[0] = OptimizedTokenFacet.name.selector;
        selectors_[1] = OptimizedTokenFacet.symbol.selector;
        selectors_[2] = OptimizedTokenFacet.decimals.selector;
        selectors_[3] = OptimizedTokenFacet.totalSupply.selector;
        selectors_[4] = OptimizedTokenFacet.balanceOf.selector;
        selectors_[5] = OptimizedTokenFacet.allowance.selector;
        selectors_[6] = OptimizedTokenFacet.transfer.selector;
        selectors_[7] = OptimizedTokenFacet.transferFrom.selector;
        selectors_[8] = OptimizedTokenFacet.approve.selector;
        selectors_[9] = OptimizedTokenFacet.mint.selector;
        selectors_[10] = OptimizedTokenFacet.freezeAccount.selector;
        selectors_[11] = OptimizedTokenFacet.unfreezeAccount.selector;
        selectors_[12] = OptimizedTokenFacet.selectorsIntrospection.selector;
    }

    /// @notice Get function selectors supported by this facet
    /// @return selectors Array of function selectors
    function getSelectors() external pure returns (bytes4[] memory selectors) {
        selectors = new bytes4[](13);
        selectors[0] = OptimizedTokenFacet.name.selector;
        selectors[1] = OptimizedTokenFacet.symbol.selector;
        selectors[2] = OptimizedTokenFacet.decimals.selector;
        selectors[3] = OptimizedTokenFacet.totalSupply.selector;
        selectors[4] = OptimizedTokenFacet.balanceOf.selector;
        selectors[5] = OptimizedTokenFacet.allowance.selector;
        selectors[6] = OptimizedTokenFacet.transfer.selector;
        selectors[7] = OptimizedTokenFacet.transferFrom.selector;
        selectors[8] = OptimizedTokenFacet.approve.selector;
        selectors[9] = OptimizedTokenFacet.mint.selector;
        selectors[10] = OptimizedTokenFacet.freezeAccount.selector;
        selectors[11] = OptimizedTokenFacet.unfreezeAccount.selector;
        selectors[12] = OptimizedTokenFacet.selectorsIntrospection.selector;
    }
}
