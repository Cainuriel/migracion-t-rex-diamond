/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  FunctionFragment,
  Interface,
  EventFragment,
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

export interface IClaimTopicsEventsInterface extends Interface {
  getEvent(
    nameOrSignatureOrTopic: "ClaimTopicAdded" | "ClaimTopicRemoved"
  ): EventFragment;
}

export namespace ClaimTopicAddedEvent {
  export type InputTuple = [topic: BigNumberish];
  export type OutputTuple = [topic: bigint];
  export interface OutputObject {
    topic: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace ClaimTopicRemovedEvent {
  export type InputTuple = [topic: BigNumberish];
  export type OutputTuple = [topic: bigint];
  export interface OutputObject {
    topic: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface IClaimTopicsEvents extends BaseContract {
  connect(runner?: ContractRunner | null): IClaimTopicsEvents;
  waitForDeployment(): Promise<this>;

  interface: IClaimTopicsEventsInterface;

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
    key: "ClaimTopicAdded"
  ): TypedContractEvent<
    ClaimTopicAddedEvent.InputTuple,
    ClaimTopicAddedEvent.OutputTuple,
    ClaimTopicAddedEvent.OutputObject
  >;
  getEvent(
    key: "ClaimTopicRemoved"
  ): TypedContractEvent<
    ClaimTopicRemovedEvent.InputTuple,
    ClaimTopicRemovedEvent.OutputTuple,
    ClaimTopicRemovedEvent.OutputObject
  >;

  filters: {
    "ClaimTopicAdded(uint256)": TypedContractEvent<
      ClaimTopicAddedEvent.InputTuple,
      ClaimTopicAddedEvent.OutputTuple,
      ClaimTopicAddedEvent.OutputObject
    >;
    ClaimTopicAdded: TypedContractEvent<
      ClaimTopicAddedEvent.InputTuple,
      ClaimTopicAddedEvent.OutputTuple,
      ClaimTopicAddedEvent.OutputObject
    >;

    "ClaimTopicRemoved(uint256)": TypedContractEvent<
      ClaimTopicRemovedEvent.InputTuple,
      ClaimTopicRemovedEvent.OutputTuple,
      ClaimTopicRemovedEvent.OutputObject
    >;
    ClaimTopicRemoved: TypedContractEvent<
      ClaimTopicRemovedEvent.InputTuple,
      ClaimTopicRemovedEvent.OutputTuple,
      ClaimTopicRemovedEvent.OutputObject
    >;
  };
}
