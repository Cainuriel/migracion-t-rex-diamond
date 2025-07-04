/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  ITrustedIssuersErrors,
  ITrustedIssuersErrorsInterface,
} from "../../../../contracts/interfaces/errors/ITrustedIssuersErrors";

const _abi = [
  {
    inputs: [],
    name: "EmptyClaimTopics",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "issuer",
        type: "address",
      },
    ],
    name: "InvalidIssuer",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "issuer",
        type: "address",
      },
    ],
    name: "TrustedIssuerAlreadyExists",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "issuer",
        type: "address",
      },
    ],
    name: "TrustedIssuerNotFound",
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

export class ITrustedIssuersErrors__factory {
  static readonly abi = _abi;
  static createInterface(): ITrustedIssuersErrorsInterface {
    return new Interface(_abi) as ITrustedIssuersErrorsInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): ITrustedIssuersErrors {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as ITrustedIssuersErrors;
  }
}
