// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { LibDiamond } from "./libraries/LibDiamond.sol";
import { LibAppStorage } from "./libraries/LibAppStorage.sol";

contract InitDiamond is Initializable {
    function init() external initializer {
        // Initialize the owner in the LibAppStorage
        LibAppStorage.diamondStorage().owner = LibDiamond.diamondStorage().contractOwner;
        
        // Initialize basic token metadata
        LibAppStorage.diamondStorage().name = "T-REX Token";
        LibAppStorage.diamondStorage().symbol = "TREX";
        LibAppStorage.diamondStorage().decimals = 18;
    }
}