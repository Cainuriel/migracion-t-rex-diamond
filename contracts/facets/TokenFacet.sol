// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { TokenInternalFacet } from "./internal/TokenInternalFacet.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";
import { LibRolesStorage } from "../storage/RolesStorage.sol";

/// @title TokenFacet - External interface for Token operations
/// @dev Exposes only public/external functions, inherits business logic from TokenInternalFacet
/// @dev Implements IEIP2535Introspection for selector introspection
contract TokenFacet is TokenInternalFacet, IEIP2535Introspection {

    modifier onlyAgentOrOwner() {
        require(
            msg.sender == LibRolesStorage.rolesStorage().owner || 
            LibRolesStorage.rolesStorage().agents[msg.sender], 
            "TokenFacet: Not authorized"
        );
        _;
    }

    // ================== ERC20 EXTERNAL FUNCTIONS ==================

    /// @notice Get token name
    /// @return Token name
    function name() external view returns (string memory) {
        return _name();
    }

    /// @notice Get token symbol
    /// @return Token symbol
    function symbol() external view returns (string memory) {
        return _symbol();
    }

    /// @notice Get token decimals
    /// @return Token decimals (always 18)
    function decimals() external pure returns (uint8) {
        return _decimals();
    }

    /// @notice Get total token supply
    /// @return Total supply amount
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    /// @notice Get balance of an account
    /// @param account Account to check
    /// @return Balance amount
    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    /// @notice Transfer tokens to another account
    /// @param to Destination address
    /// @param amount Amount to transfer
    /// @return Success flag
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve another account to spend tokens
    /// @param spender Spender address
    /// @param amount Amount to approve
    /// @return Success flag
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens from one account to another (with allowance)
    /// @param from Source address
    /// @param to Destination address
    /// @param amount Amount to transfer
    /// @return Success flag
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowance(from, msg.sender);
        require(currentAllowance >= amount, "TokenFacet: allowance exceeded");
        
        _approve(from, msg.sender, currentAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }

    /// @notice Get allowance between owner and spender
    /// @param owner_ Token owner
    /// @param spender Spender address
    /// @return Allowance amount
    function allowance(address owner_, address spender) external view returns (uint256) {
        return _allowance(owner_, spender);
    }

    // ================== ADMINISTRATIVE FUNCTIONS ==================

    /// @notice Mint new tokens (only agent or owner)
    /// @param to Recipient address
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external onlyAgentOrOwner {
        _mint(to, amount);
    }

    /// @notice Burn tokens (only agent or owner)
    /// @param from Address to burn from
    /// @param amount Amount to burn
    function burn(address from, uint256 amount) external onlyAgentOrOwner {
        _burn(from, amount);
    }

    /// @notice Force transfer (bypass normal restrictions) - only agent or owner
    /// @param from Source address
    /// @param to Destination address
    /// @param amount Amount to transfer
    function forceTransfer(address from, address to, uint256 amount) external onlyAgentOrOwner {
        _transfer(from, to, amount);
    }

    /// @notice Freeze an account (only agent or owner)
    /// @param user Account to freeze
    function freezeAccount(address user) external onlyAgentOrOwner {
        _setAccountFrozen(user, true);
    }

    /// @notice Unfreeze an account (only agent or owner)
    /// @param user Account to unfreeze
    function unfreezeAccount(address user) external onlyAgentOrOwner {
        _setAccountFrozen(user, false);
    }

    /// @notice Check if an account is frozen
    /// @param account Account to check
    /// @return True if frozen
    function isFrozen(address account) external view returns (bool) {
        return _isFrozen(account);
    }

    // ================== IEIP2535INTROSPECTION ==================

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 15;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.name.selector;
        selectors_[--selectorsLength] = this.symbol.selector;
        selectors_[--selectorsLength] = this.decimals.selector;
        selectors_[--selectorsLength] = this.totalSupply.selector;
        selectors_[--selectorsLength] = this.balanceOf.selector;
        selectors_[--selectorsLength] = this.transfer.selector;
        selectors_[--selectorsLength] = this.approve.selector;
        selectors_[--selectorsLength] = this.transferFrom.selector;
        selectors_[--selectorsLength] = this.allowance.selector;
        selectors_[--selectorsLength] = this.mint.selector;
        selectors_[--selectorsLength] = this.burn.selector;
        selectors_[--selectorsLength] = this.forceTransfer.selector;
        selectors_[--selectorsLength] = this.freezeAccount.selector;
        selectors_[--selectorsLength] = this.unfreezeAccount.selector;
        selectors_[--selectorsLength] = this.isFrozen.selector;
    }
}
