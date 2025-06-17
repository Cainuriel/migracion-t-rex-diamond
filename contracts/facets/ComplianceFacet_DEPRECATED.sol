// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { IEIP2535Introspection } from "../interfaces/IEIP2535Introspection.sol";

contract ComplianceFacet_DEPRECATED  is IEIP2535Introspection {
    event MaxBalanceSet(uint256 max);
    event MinBalanceSet(uint256 min);
    event MaxInvestorsSet(uint256 max);    modifier onlyOwner() {
        require(msg.sender == LibAppStorage.diamondStorage().owner, "Not owner");
        _;
    }

    function setMaxBalance(uint256 max) external onlyOwner {
        LibAppStorage.diamondStorage().complianceMaxBalance = max;
        emit MaxBalanceSet(max);
    }

    function setMinBalance(uint256 min) external onlyOwner {
        LibAppStorage.diamondStorage().complianceMinBalance = min;
        emit MinBalanceSet(min);
    }

    function setMaxInvestors(uint256 max) external onlyOwner {
        LibAppStorage.diamondStorage().complianceMaxInvestors = max;        emit MaxInvestorsSet(max);
    }

    function canTransfer(address from, address to, uint256 amount) external view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.investorFrozenStatus[from] || s.investorFrozenStatus[to]) return false;
        if (s.investorIdentities[to] == address(0)) return false;

        uint256 newBalance = s.balances[to] + amount;
        if (s.complianceMaxBalance > 0 && newBalance > s.complianceMaxBalance) return false;
        if (s.complianceMinBalance > 0 && newBalance < s.complianceMinBalance) return false;

        if (s.complianceMaxInvestors > 0 && s.balances[to] == 0) {
            uint256 count = 0;
            for (uint i = 0; i < s.holders.length; i++) {
                if (s.balances[s.holders[i]] > 0) count++;
            }
            if (count >= s.complianceMaxInvestors) return false;
        }        return true;
    }

    function complianceRules() external view returns (uint256 maxBalance, uint256 minBalance, uint256 maxInvestors) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.complianceMaxBalance,
            s.complianceMinBalance,
            s.complianceMaxInvestors
        );
    }

    /// @notice Returns the function selectors supported by this facet
    /// @dev Implementation of IEIP2535Introspection
    /// @return selectors_ Array of function selectors exposed by this facet
    function selectorsIntrospection()
        external
        pure
        override
        returns (bytes4[] memory selectors_)
    {
        uint256 selectorsLength = 5;
        selectors_ = new bytes4[](selectorsLength);
        selectors_[--selectorsLength] = this.setMaxBalance.selector;
        selectors_[--selectorsLength] = this.setMinBalance.selector;
        selectors_[--selectorsLength] = this.setMaxInvestors.selector;
        selectors_[--selectorsLength] = this.canTransfer.selector;
        selectors_[--selectorsLength] = this.complianceRules.selector;
    }
}
