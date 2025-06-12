// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("isbe.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition;
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition;
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.contractOwner = _newOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    function diamondCut(
        IDiamondCut.FacetCut[] memory _cut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _cut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _cut[facetIndex].action;
            address facetAddress = _cut[facetIndex].facetAddress;
            bytes4[] memory functionSelectors = _cut[facetIndex].functionSelectors;
            require(functionSelectors.length > 0, "LibDiamond: No selectors in facet");

            if (action == IDiamondCut.FacetCutAction.Add) {
                for (uint256 selectorIndex; selectorIndex < functionSelectors.length; selectorIndex++) {
                    bytes4 selector = functionSelectors[selectorIndex];
                    diamondStorage().selectorToFacetAndPosition[selector] = FacetAddressAndPosition({
                        facetAddress: facetAddress,
                        functionSelectorPosition: uint96(selectorIndex)
                    });
                }
            } else {
                revert("LibDiamond: Unsupported action");
            }
        }

        if (_init != address(0)) {
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            require(success, string(error));
        }
    }
}