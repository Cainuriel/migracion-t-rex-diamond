// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ITokenEvents } from "../../interfaces/events/ITokenEvents.sol";
import { ITokenErrors } from "../../interfaces/errors/ITokenErrors.sol";

/// @title TokenInternalFacet - Internal business logic for Token domain
/// @dev Contains all the business logic for token operations
/// @dev This facet is not directly exposed in the diamond interface
contract TokenInternalFacet is ITokenEvents, ITokenErrors {

    // ================== STORAGE STRUCTURES ==================

    /// @title TokenStorage - Unstructured storage for Token domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct TokenStorage {
        // === TOKEN CORE ERC20 ===
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
        
        // === TOKEN ERC-3643 EXTENSIONS ===
        mapping(address => bool) frozenAccounts;
        address[] holders; // Track all token holders for compliance
    }

    /// @title RolesStorage - Unstructured storage for Roles domain
    /// @dev Uses Diamond Storage pattern with unique storage slot
    struct RolesStorage {
        // === ACCESS CONTROL ===
        address owner;
        mapping(address => bool) agents;
        bool initialized;
    }

    // ================== STORAGE ACCESS ==================

    /// @dev Storage slot for Token domain
    bytes32 private constant TOKEN_STORAGE_POSITION = keccak256("t-rex.diamond.token.storage");
    
    /// @dev Storage slot for Roles domain
    bytes32 private constant ROLES_STORAGE_POSITION = keccak256("t-rex.diamond.roles.storage");

    /// @notice Get Token storage reference
    /// @return ts Token storage struct
    function _getTokenStorage() private pure returns (TokenStorage storage ts) {
        bytes32 position = TOKEN_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    /// @notice Get Roles storage reference
    /// @return rs Roles storage struct
    function _getRolesStorage() private pure returns (RolesStorage storage rs) {
        bytes32 position = ROLES_STORAGE_POSITION;
        assembly {
            rs.slot := position
        }
    }

    // ================== INTERNAL TOKEN OPERATIONS ==================

    /// @notice Internal transfer function with compliance checks
    /// @param from Source address
    /// @param to Destination address  
    /// @param amount Amount to transfer
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        
        TokenStorage storage ts = _getTokenStorage();
        if (ts.frozenAccounts[from]) revert FrozenAccount(from);
        if (ts.frozenAccounts[to]) revert FrozenAccount(to);
        if (ts.balances[from] < amount) revert InsufficientBalance(ts.balances[from], amount);
        
        ts.balances[from] -= amount;
        ts.balances[to] += amount;
        
        // Update holders array if needed
        _updateHoldersArray(from, to);
        
        emit Transfer(from, to, amount);
    }

    /// @notice Internal mint function
    /// @param to Recipient address
    /// @param amount Amount to mint
    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        
        TokenStorage storage ts = _getTokenStorage();
        ts.totalSupply += amount;
        ts.balances[to] += amount;
        
        // Update holders array
        _updateHoldersArray(address(0), to);
        
        emit Transfer(address(0), to, amount);
    }

    /// @notice Internal burn function
    /// @param from Address to burn from
    /// @param amount Amount to burn
    function _burn(address from, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        
        TokenStorage storage ts = _getTokenStorage();
        if (ts.balances[from] < amount) revert InsufficientBalance(ts.balances[from], amount);
        
        ts.balances[from] -= amount;
        ts.totalSupply -= amount;
        
        // Update holders array
        _updateHoldersArray(from, address(0));
        
        emit Transfer(from, address(0), amount);
    }

    /// @notice Internal function to freeze/unfreeze accounts
    /// @param user Account to freeze/unfreeze
    /// @param frozen True to freeze, false to unfreeze
    function _setAccountFrozen(address user, bool frozen) internal {
        TokenStorage storage ts = _getTokenStorage();
        ts.frozenAccounts[user] = frozen;
        emit AccountFrozen(user, frozen);
    }

    /// @notice Internal function to approve allowances
    /// @param owner_ Token owner
    /// @param spender Spender address
    /// @param amount Allowance amount
    function _approve(address owner_, address spender, uint256 amount) internal {
        if (owner_ == address(0)) revert ZeroAddress();
        if (spender == address(0)) revert ZeroAddress();
        
        TokenStorage storage ts = _getTokenStorage();
        ts.allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get token balance of an account
    /// @param account Account to check
    /// @return Balance amount
    function _balanceOf(address account) internal view returns (uint256) {
        return _getTokenStorage().balances[account];
    }

    /// @notice Get allowance between owner and spender
    /// @param owner_ Token owner
    /// @param spender Spender address
    /// @return Allowance amount
    function _allowance(address owner_, address spender) internal view returns (uint256) {
        return _getTokenStorage().allowances[owner_][spender];
    }

    /// @notice Check if account is frozen
    /// @param account Account to check
    /// @return True if frozen
    function _isFrozen(address account) internal view returns (bool) {
        return _getTokenStorage().frozenAccounts[account];
    }

    /// @notice Get total supply
    /// @return Total token supply
    function _totalSupply() internal view returns (uint256) {
        return _getTokenStorage().totalSupply;
    }

    /// @notice Get token name
    /// @return Token name
    function _name() internal view returns (string memory) {
        return _getTokenStorage().name;
    }

    /// @notice Get token symbol
    /// @return Token symbol
    function _symbol() internal view returns (string memory) {
        return _getTokenStorage().symbol;
    }

    /// @notice Get token decimals
    /// @return Token decimals (always 18)
    function _decimals() internal pure returns (uint8) {
        return 18;
    }

    // ================== INTERNAL INITIALIZATION ==================

    /// @notice Initialize token metadata
    /// @param name_ Token name
    /// @param symbol_ Token symbol
    function _initializeToken(string memory name_, string memory symbol_) internal {
        TokenStorage storage ts = _getTokenStorage();
        ts.name = name_;
        ts.symbol = symbol_;
        ts.decimals = 18;
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @notice Update holders array when balances change
    /// @param from Source address (address(0) for minting)
    /// @param to Destination address (address(0) for burning)
    function _updateHoldersArray(address from, address to) private {
        TokenStorage storage ts = _getTokenStorage();
        
        // Add new holder if minting or transferring to new address
        if (to != address(0) && ts.balances[to] == 0) {
            ts.holders.push(to);
        }
        
        // Remove holder if burning all tokens or transferring all balance
        if (from != address(0) && ts.balances[from] == 0) {
            _removeFromHolders(from);
        }
    }

    /// @notice Remove address from holders array
    /// @param holder Address to remove
    function _removeFromHolders(address holder) private {
        TokenStorage storage ts = _getTokenStorage();
        for (uint256 i = 0; i < ts.holders.length; i++) {
            if (ts.holders[i] == holder) {
                ts.holders[i] = ts.holders[ts.holders.length - 1];
                ts.holders.pop();
                break;
            }
        }
    }

    // ================== INTERNAL AUTHORIZATION ==================

    /// @notice Internal check for owner authorization
    /// @param caller Address calling the function
    function _onlyOwner(address caller) internal view {
        require(caller == _getRolesStorage().owner, "TokenInternal: Not owner");
    }

    /// @notice Internal check for agent or owner authorization
    /// @param caller Address calling the function
    function _onlyAgentOrOwner(address caller) internal view {
        RolesStorage storage rs = _getRolesStorage();
        require(caller == rs.owner || rs.agents[caller], "TokenInternal: Not authorized");
    }
}
