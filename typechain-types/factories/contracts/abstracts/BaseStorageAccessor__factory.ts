/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  BaseStorageAccessor,
  BaseStorageAccessorInterface,
} from "../../../contracts/abstracts/BaseStorageAccessor";

const _abi = [
  {
    inputs: [],
    name: "getStorageNamespace",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "getStorageVersion",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
] as const;

export class BaseStorageAccessor__factory {
  static readonly abi = _abi;
  static createInterface(): BaseStorageAccessorInterface {
    return new Interface(_abi) as BaseStorageAccessorInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): BaseStorageAccessor {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as BaseStorageAccessor;
  }
}
