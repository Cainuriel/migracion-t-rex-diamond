// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { AppStorage } from "../storage/AppStorage.sol";

library LibAppStorage {
    bytes32 internal constant DIAMOND_APP_STORAGE = keccak256("isbe.diamond.app.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 slot = DIAMOND_APP_STORAGE;
        assembly {
            ds.slot := slot
        }
    }
}