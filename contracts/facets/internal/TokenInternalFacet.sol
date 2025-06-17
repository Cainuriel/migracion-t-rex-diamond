// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibTokenStorage, TokenStorage } from "../storage/TokenStorage.sol";
import { LibRolesStorage, RolesStorage } from "../storage/RolesStorage.sol";

/// @title TokenInternalFacet - Internal business logic for Token domain
/// @dev Contains all the business logic for token operations
/// @dev This facet is not directly exposed in the diamond interface
contract TokenInternalFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AccountFrozen(address indexed user, bool frozen);

    modifier onlyAgentOrOwner() {
        RolesStorage storage rs = LibRolesStorage.rolesStorage();
        require(msg.sender == rs.owner || rs.agents[msg.sender], "TokenInternal: Not authorized");
        _;
    }

    // ================== INTERNAL TOKEN OPERATIONS ==================

    /// @notice Internal transfer function with compliance checks
    /// @param from Source address
    /// @param to Destination address  
    /// @param amount Amount to transfer
    function _transfer(address from, address to, uint256 amount) internal {
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        require(!ts.frozenAccounts[from], "TokenInternal: sender frozen");
        require(!ts.frozenAccounts[to], "TokenInternal: receiver frozen");
        require(ts.balances[from] >= amount, "TokenInternal: insufficient balance");
        
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
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
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
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        require(ts.balances[from] >= amount, "TokenInternal: burn amount exceeds balance");
        
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
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        ts.frozenAccounts[user] = frozen;
        emit AccountFrozen(user, frozen);
    }

    /// @notice Internal function to approve allowances
    /// @param owner_ Token owner
    /// @param spender Spender address
    /// @param amount Allowance amount
    function _approve(address owner_, address spender, uint256 amount) internal {
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        ts.allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    // ================== INTERNAL VIEW FUNCTIONS ==================

    /// @notice Get token balance of an account
    /// @param account Account to check
    /// @return Balance amount
    function _balanceOf(address account) internal view returns (uint256) {
        return LibTokenStorage.tokenStorage().balances[account];
    }

    /// @notice Get allowance between owner and spender
    /// @param owner_ Token owner
    /// @param spender Spender address
    /// @return Allowance amount
    function _allowance(address owner_, address spender) internal view returns (uint256) {
        return LibTokenStorage.tokenStorage().allowances[owner_][spender];
    }

    /// @notice Check if account is frozen
    /// @param account Account to check
    /// @return True if frozen
    function _isFrozen(address account) internal view returns (bool) {
        return LibTokenStorage.tokenStorage().frozenAccounts[account];
    }

    /// @notice Get total supply
    /// @return Total token supply
    function _totalSupply() internal view returns (uint256) {
        return LibTokenStorage.tokenStorage().totalSupply;
    }

    /// @notice Get token name
    /// @return Token name
    function _name() internal view returns (string memory) {
        return LibTokenStorage.tokenStorage().name;
    }

    /// @notice Get token symbol
    /// @return Token symbol
    function _symbol() internal view returns (string memory) {
        return LibTokenStorage.tokenStorage().symbol;
    }

    /// @notice Get token decimals
    /// @return Token decimals
    function _decimals() internal pure returns (uint8) {
        return 18;
    }

    // ================== PRIVATE HELPER FUNCTIONS ==================

    /// @dev Updates the holders array when tokens are transferred
    function _updateHoldersArray(address from, address to) private {
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        
        // Add new holder if they didn't have tokens before
        if (to != address(0) && ts.balances[to] == 0) {
            ts.holders.push(to);
        }
        
        // Remove holder if they no longer have tokens after transfer
        if (from != address(0) && ts.balances[from] == 0) {
            _removeFromHolders(from);
        }
    }

    /// @dev Removes an address from the holders array
    function _removeFromHolders(address holder) private {
        TokenStorage storage ts = LibTokenStorage.tokenStorage();
        for (uint256 i = 0; i < ts.holders.length; i++) {
            if (ts.holders[i] == holder) {
                ts.holders[i] = ts.holders[ts.holders.length - 1];
                ts.holders.pop();
                break;
            }
        }
    }
}
