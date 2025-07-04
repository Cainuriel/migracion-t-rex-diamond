/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IIdentityErrors,
  IIdentityErrorsInterface,
} from "../../../../contracts/interfaces/errors/IIdentityErrors";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "investor",
        type: "address",
      },
    ],
    name: "AlreadyRegistered",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "uint16",
        name: "country",
        type: "uint16",
      },
    ],
    name: "InvalidCountry",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "identity",
        type: "address",
      },
    ],
    name: "InvalidIdentity",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "investor",
        type: "address",
      },
    ],
    name: "NotRegistered",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "caller",
        type: "address",
      },
    ],
    name: "Unauthorized",
    type: "error",
  },
  {
    inputs: [],
    name: "ZeroAddress",
    type: "error",
  },
] as const;

export class IIdentityErrors__factory {
  static readonly abi = _abi;
  static createInterface(): IIdentityErrorsInterface {
    return new Interface(_abi) as IIdentityErrorsInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IIdentityErrors {
    return new Contract(address, _abi, runner) as unknown as IIdentityErrors;
  }
}
