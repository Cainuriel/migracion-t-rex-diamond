/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  FunctionFragment,
  Interface,
  EventFragment,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedLogDescription,
  TypedListener,
} from "../../../common";

export interface IdentityInternalFacetInterface extends Interface {
  getEvent(
    nameOrSignatureOrTopic:
      | "CountryUpdated"
      | "IdentityRegistered"
      | "IdentityRemoved"
      | "IdentityUpdated"
  ): EventFragment;
}

export namespace CountryUpdatedEvent {
  export type InputTuple = [investor: AddressLike, country: BigNumberish];
  export type OutputTuple = [investor: string, country: bigint];
  export interface OutputObject {
    investor: string;
    country: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace IdentityRegisteredEvent {
  export type InputTuple = [
    investor: AddressLike,
    identity: AddressLike,
    country: BigNumberish
  ];
  export type OutputTuple = [
    investor: string,
    identity: string,
    country: bigint
  ];
  export interface OutputObject {
    investor: string;
    identity: string;
    country: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace IdentityRemovedEvent {
  export type InputTuple = [investor: AddressLike];
  export type OutputTuple = [investor: string];
  export interface OutputObject {
    investor: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace IdentityUpdatedEvent {
  export type InputTuple = [investor: AddressLike, newIdentity: AddressLike];
  export type OutputTuple = [investor: string, newIdentity: string];
  export interface OutputObject {
    investor: string;
    newIdentity: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface IdentityInternalFacet extends BaseContract {
  connect(runner?: ContractRunner | null): IdentityInternalFacet;
  waitForDeployment(): Promise<this>;

  interface: IdentityInternalFacetInterface;

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

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getEvent(
    key: "CountryUpdated"
  ): TypedContractEvent<
    CountryUpdatedEvent.InputTuple,
    CountryUpdatedEvent.OutputTuple,
    CountryUpdatedEvent.OutputObject
  >;
  getEvent(
    key: "IdentityRegistered"
  ): TypedContractEvent<
    IdentityRegisteredEvent.InputTuple,
    IdentityRegisteredEvent.OutputTuple,
    IdentityRegisteredEvent.OutputObject
  >;
  getEvent(
    key: "IdentityRemoved"
  ): TypedContractEvent<
    IdentityRemovedEvent.InputTuple,
    IdentityRemovedEvent.OutputTuple,
    IdentityRemovedEvent.OutputObject
  >;
  getEvent(
    key: "IdentityUpdated"
  ): TypedContractEvent<
    IdentityUpdatedEvent.InputTuple,
    IdentityUpdatedEvent.OutputTuple,
    IdentityUpdatedEvent.OutputObject
  >;

  filters: {
    "CountryUpdated(address,uint16)": TypedContractEvent<
      CountryUpdatedEvent.InputTuple,
      CountryUpdatedEvent.OutputTuple,
      CountryUpdatedEvent.OutputObject
    >;
    CountryUpdated: TypedContractEvent<
      CountryUpdatedEvent.InputTuple,
      CountryUpdatedEvent.OutputTuple,
      CountryUpdatedEvent.OutputObject
    >;

    "IdentityRegistered(address,address,uint16)": TypedContractEvent<
      IdentityRegisteredEvent.InputTuple,
      IdentityRegisteredEvent.OutputTuple,
      IdentityRegisteredEvent.OutputObject
    >;
    IdentityRegistered: TypedContractEvent<
      IdentityRegisteredEvent.InputTuple,
      IdentityRegisteredEvent.OutputTuple,
      IdentityRegisteredEvent.OutputObject
    >;

    "IdentityRemoved(address)": TypedContractEvent<
      IdentityRemovedEvent.InputTuple,
      IdentityRemovedEvent.OutputTuple,
      IdentityRemovedEvent.OutputObject
    >;
    IdentityRemoved: TypedContractEvent<
      IdentityRemovedEvent.InputTuple,
      IdentityRemovedEvent.OutputTuple,
      IdentityRemovedEvent.OutputObject
    >;

    "IdentityUpdated(address,address)": TypedContractEvent<
      IdentityUpdatedEvent.InputTuple,
      IdentityUpdatedEvent.OutputTuple,
      IdentityUpdatedEvent.OutputObject
    >;
    IdentityUpdated: TypedContractEvent<
      IdentityUpdatedEvent.InputTuple,
      IdentityUpdatedEvent.OutputTuple,
      IdentityUpdatedEvent.OutputObject
    >;
  };
}
