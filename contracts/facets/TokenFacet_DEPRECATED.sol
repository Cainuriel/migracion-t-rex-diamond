// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

/// @title TokenFacet - ERC20 and ERC-3643 logic
contract TokenFacet is IEIP2535Introspection {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AccountFrozen(address indexed user, bool frozen);

    modifier onlyAgentOrOwner() {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(msg.sender == s.owner || s.agents[msg.sender], "TokenFacet: Not authorized");
        _;
    }

    function name() external view returns (string memory) {
        return LibAppStorage.diamondStorage().name;
    }

    function symbol() external view returns (string memory) {
        return LibAppStorage.diamondStorage().symbol;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return LibAppStorage.diamondStorage().totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return LibAppStorage.diamondStorage().balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 allowed = s.allowances[from][msg.sender];
        require(allowed >= amount, "TokenFacet: allowance exceeded");
        s.allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) external view returns (uint256) {
        return LibAppStorage.diamondStorage().allowances[owner_][spender];
    }

    function mint(address to, uint256 amount) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.totalSupply += amount;
        s.balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyAgentOrOwner {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.balances[from] >= amount, "TokenFacet: burn amount exceeds balance");
        s.balances[from] -= amount;
        s.totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function forceTransfer(address from, address to, uint256 amount) external onlyAgentOrOwner {
        _transfer(from, to, amount);
    }    function freezeAccount(address user) external onlyAgentOrOwner {
        LibAppStorage.diamondStorage().investorFrozenStatus[user] = true;
        emit AccountFrozen(user, true);
    }

    function unfreezeAccount(address user) external onlyAgentOrOwner {
        LibAppStorage.diamondStorage().investorFrozenStatus[user] = false;
        emit AccountFrozen(user, false);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.investorFrozenStatus[from], "TokenFacet: sender frozen");
        require(!s.investorFrozenStatus[to], "TokenFacet: receiver frozen");
        require(s.balances[from] >= amount, "TokenFacet: insufficient balance");
        s.balances[from] -= amount;
        s.balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {        uint256 selectorsLength = 14;
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
    }
}