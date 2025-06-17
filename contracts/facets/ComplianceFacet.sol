// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAppStorage, AppStorage } from "../libraries/LibAppStorage.sol";
import { Compliance } from "../storage/AppStorage.sol";

contract ComplianceFacet {
    event MaxBalanceSet(uint256 max);
    event MinBalanceSet(uint256 min);
    event MaxInvestorsSet(uint256 max);

    modifier onlyOwner() {
        require(msg.sender == LibAppStorage.diamondStorage().owner, "Not owner");
        _;
    }

    function setMaxBalance(uint256 max) external onlyOwner {
        LibAppStorage.diamondStorage().compliance.maxBalance = max;
        emit MaxBalanceSet(max);
    }

    function setMinBalance(uint256 min) external onlyOwner {
        LibAppStorage.diamondStorage().compliance.minBalance = min;
        emit MinBalanceSet(min);
    }

    function setMaxInvestors(uint256 max) external onlyOwner {
        LibAppStorage.diamondStorage().compliance.maxInvestors = max;
        emit MaxInvestorsSet(max);
    }    function canTransfer(address from, address to, uint256 amount) external view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.investorFrozenStatus[from] || s.investorFrozenStatus[to]) return false;
        if (s.investorIdentities[to] == address(0)) return false;

        uint256 newBalance = s.balances[to] + amount;
        if (s.compliance.maxBalance > 0 && newBalance > s.compliance.maxBalance) return false;
        if (s.compliance.minBalance > 0 && newBalance < s.compliance.minBalance) return false;

        if (s.compliance.maxInvestors > 0 && s.balances[to] == 0) {
            uint256 count = 0;
            for (uint i = 0; i < s.holders.length; i++) {
                if (s.balances[s.holders[i]] > 0) count++;
            }
            if (count >= s.compliance.maxInvestors) return false;
        }
        return true;
    }

    function complianceRules() external view returns (uint256 maxBalance, uint256 minBalance, uint256 maxInvestors) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (
            s.compliance.maxBalance,
            s.compliance.minBalance,
            s.compliance.maxInvestors
        );
    }
}
