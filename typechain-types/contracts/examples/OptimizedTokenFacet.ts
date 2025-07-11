/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedListener,
  TypedContractMethod,
} from "../../common";

export interface OptimizedTokenFacetInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "allowance"
      | "approve"
      | "balanceOf"
      | "decimals"
      | "freezeAccount"
      | "getSelectors"
      | "getStorageNamespace"
      | "getStorageStatus"
      | "getStorageVersion"
      | "mint"
      | "name"
      | "selectorsIntrospection"
      | "symbol"
      | "totalSupply"
      | "transfer"
      | "transferFrom"
      | "unfreezeAccount"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "allowance",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "approve",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "balanceOf",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "decimals", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "freezeAccount",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "getSelectors",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getStorageNamespace",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getStorageStatus",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getStorageVersion",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "mint",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "name", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "selectorsIntrospection",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "symbol", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "totalSupply",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "transfer",
    values: [AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "transferFrom",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "unfreezeAccount",
    values: [AddressLike]
  ): string;

  decodeFunctionResult(functionFragment: "allowance", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "approve", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "balanceOf", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "decimals", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "freezeAccount",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getSelectors",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getStorageNamespace",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getStorageStatus",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getStorageVersion",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "name", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "selectorsIntrospection",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "symbol", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "totalSupply",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "transfer", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "transferFrom",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "unfreezeAccount",
    data: BytesLike
  ): Result;
}

export interface OptimizedTokenFacet extends BaseContract {
  connect(runner?: ContractRunner | null): OptimizedTokenFacet;
  waitForDeployment(): Promise<this>;

  interface: OptimizedTokenFacetInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  allowance: TypedContractMethod<
    [owner: AddressLike, spender: AddressLike],
    [bigint],
    "view"
  >;

  approve: TypedContractMethod<
    [spender: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;

  balanceOf: TypedContractMethod<[account: AddressLike], [bigint], "view">;

  decimals: TypedContractMethod<[], [bigint], "view">;

  freezeAccount: TypedContractMethod<
    [account: AddressLike],
    [void],
    "nonpayable"
  >;

  getSelectors: TypedContractMethod<[], [string[]], "view">;

  getStorageNamespace: TypedContractMethod<[], [string], "view">;

  getStorageStatus: TypedContractMethod<
    [],
    [
      [boolean, boolean, boolean] & {
        token: boolean;
        roles: boolean;
        compliance: boolean;
      }
    ],
    "view"
  >;

  getStorageVersion: TypedContractMethod<[], [bigint], "view">;

  mint: TypedContractMethod<
    [to: AddressLike, amount: BigNumberish],
    [void],
    "nonpayable"
  >;

  name: TypedContractMethod<[], [string], "view">;

  selectorsIntrospection: TypedContractMethod<[], [string[]], "view">;

  symbol: TypedContractMethod<[], [string], "view">;

  totalSupply: TypedContractMethod<[], [bigint], "view">;

  transfer: TypedContractMethod<
    [to: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;

  transferFrom: TypedContractMethod<
    [from: AddressLike, to: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;

  unfreezeAccount: TypedContractMethod<
    [account: AddressLike],
    [void],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "allowance"
  ): TypedContractMethod<
    [owner: AddressLike, spender: AddressLike],
    [bigint],
    "view"
  >;
  getFunction(
    nameOrSignature: "approve"
  ): TypedContractMethod<
    [spender: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "balanceOf"
  ): TypedContractMethod<[account: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "decimals"
  ): TypedContractMethod<[], [bigint], "view">;
  getFunction(
    nameOrSignature: "freezeAccount"
  ): TypedContractMethod<[account: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "getSelectors"
  ): TypedContractMethod<[], [string[]], "view">;
  getFunction(
    nameOrSignature: "getStorageNamespace"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "getStorageStatus"
  ): TypedContractMethod<
    [],
    [
      [boolean, boolean, boolean] & {
        token: boolean;
        roles: boolean;
        compliance: boolean;
      }
    ],
    "view"
  >;
  getFunction(
    nameOrSignature: "getStorageVersion"
  ): TypedContractMethod<[], [bigint], "view">;
  getFunction(
    nameOrSignature: "mint"
  ): TypedContractMethod<
    [to: AddressLike, amount: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "name"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "selectorsIntrospection"
  ): TypedContractMethod<[], [string[]], "view">;
  getFunction(
    nameOrSignature: "symbol"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "totalSupply"
  ): TypedContractMethod<[], [bigint], "view">;
  getFunction(
    nameOrSignature: "transfer"
  ): TypedContractMethod<
    [to: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "transferFrom"
  ): TypedContractMethod<
    [from: AddressLike, to: AddressLike, amount: BigNumberish],
    [boolean],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "unfreezeAccount"
  ): TypedContractMethod<[account: AddressLike], [void], "nonpayable">;

  filters: {};
}
