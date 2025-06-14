/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type { Signer, ContractDeployTransaction, ContractRunner } from "ethers";
import type { NonPayableOverrides } from "../../../common";
import type {
  RolesFacet,
  RolesFacetInterface,
} from "../../../contracts/facets/RolesFacet";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "agent",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "status",
        type: "bool",
      },
    ],
    name: "AgentSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint8",
        name: "version",
        type: "uint8",
      },
    ],
    name: "Initialized",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_owner",
        type: "address",
      },
    ],
    name: "initializeRoles",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_addr",
        type: "address",
      },
    ],
    name: "isAgent",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_agent",
        type: "address",
      },
      {
        internalType: "bool",
        name: "_status",
        type: "bool",
      },
    ],
    name: "setAgent",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b506105c5806100206000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c80631ffbb0641461005c57806354208a2f146100bc5780638da5cb5b146100d157806397d8c6761461010b578063f2fde38b1461011e575b600080fd5b6100a761006a366004610531565b6001600160a01b031660009081527fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b01a602052604090205460ff1690565b60405190151581526020015b60405180910390f35b6100cf6100ca366004610531565b610131565b005b7fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b019546040516001600160a01b0390911681526020016100b3565b6100cf610119366004610553565b6102a8565b6100cf61012c366004610531565b61039a565b600054610100900460ff16158080156101515750600054600160ff909116105b8061016b5750303b15801561016b575060005460ff166001145b6101d35760405162461bcd60e51b815260206004820152602e60248201527f496e697469616c697a61626c653a20636f6e747261637420697320616c72656160448201526d191e481a5b9a5d1a585b1a5e995960921b60648201526084015b60405180910390fd5b6000805460ff1916600117905580156101f6576000805461ff0019166101001790555b7fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b01980546001600160a01b0319166001600160a01b0384169081179091556040516000907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0908290a380156102a4576000805461ff0019169055604051600181527f7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb38474024989060200160405180910390a15b5050565b7fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b00f600a01546001600160a01b0316331461031c5760405162461bcd60e51b81526020600482015260156024820152742937b632b9a330b1b2ba1d102737ba1037bbb732b960591b60448201526064016101ca565b6001600160a01b03821660008181527fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b01a6020908152604091829020805460ff191685151590811790915591519182527fdfbbd189290ad6ccafc74f11e514df22fe2c990b1f70c48e80c0c152ccf16415910160405180910390a25050565b7fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b00f600a01546001600160a01b0316331461040e5760405162461bcd60e51b81526020600482015260156024820152742937b632b9a330b1b2ba1d102737ba1037bbb732b960591b60448201526064016101ca565b6001600160a01b0381166104765760405162461bcd60e51b815260206004820152602960248201527f526f6c657346616365743a206e6577206f776e657220697320746865207a65726044820152686f206164647265737360b81b60648201526084016101ca565b7fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b019546040517fc2b69da5e7be41c6eaba0bfa82e0e1fef8d4512d663aa63c99ede9dd1d17b00f916001600160a01b03848116929116907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a3600a0180546001600160a01b0319166001600160a01b0392909216919091179055565b80356001600160a01b038116811461052c57600080fd5b919050565b60006020828403121561054357600080fd5b61054c82610515565b9392505050565b6000806040838503121561056657600080fd5b61056f83610515565b91506020830135801515811461058457600080fd5b80915050925092905056fea2646970667358221220d7db2544d227c87b52d3d64cad5b762fa0e857f255ce03ad0641d158c38912a864736f6c63430008110033";

type RolesFacetConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: RolesFacetConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class RolesFacet__factory extends ContractFactory {
  constructor(...args: RolesFacetConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(overrides || {});
  }
  override deploy(overrides?: NonPayableOverrides & { from?: string }) {
    return super.deploy(overrides || {}) as Promise<
      RolesFacet & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): RolesFacet__factory {
    return super.connect(runner) as RolesFacet__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): RolesFacetInterface {
    return new Interface(_abi) as RolesFacetInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): RolesFacet {
    return new Contract(address, _abi, runner) as unknown as RolesFacet;
  }
}
