// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { LibDiamond } from "./libraries/LibDiamond.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Diamond - EIP-2535 core contract
contract Diamond is Initializable {
     
constructor(address diamondCutFacet) {
    LibDiamond.setContractOwner(msg.sender);

    // Crear array de selectors con un solo elemento
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;

    // Crear un array de un solo FacetCut
    IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
    cut[0] = IDiamondCut.FacetCut({
        facetAddress: diamondCutFacet,
        action: IDiamondCut.FacetCutAction.Add,
        functionSelectors: functionSelectors
    });

    // Ejecutar corte
    LibDiamond.diamondCut(cut, address(0), new bytes(0));
}

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }

        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
