(** An Ethereum address corresponding to a private key k_r is the 
    rightmost truncation to 160 bit of a 256 bit Keccak hash
    of the corresponding ECDSA public key. Cf Yellow Paper. *)

(** Addresses are 20 bytes long, 40 bytes in hex form + 0x. *)
(* TODO: use Bitstr.hex_string *)
type address = private string

(** hash256 are 32 bytes long, 64 bytes in hex form + 0x. *)
type hash256 = private string

(** hash512 are 64 bytes long, 128 bytes in hex form + 0x. *)
type hash512 = private string


val address_to_string   : address -> string
val address_from_string : string -> address

val hash256_to_string   : hash256 -> string
val hash256_from_string : string -> hash256

val hash512_to_string   : hash512 -> string
val hash512_from_string : string -> hash512

(** 10^18 Wei = 1 Ether. TODO: currently unused. *)
type wei      = int
type block_id = int


(** Transactions *)
module Tx :
sig

  type t =
    {
      src       : address;
      dst       : address option;
      gas       : Z.t option;
      gas_price : Z.t option;
      value     : Z.t option;
      data      : string;
      nonce     : int option
    }

  type accepted =
    {
      tx : t;
      block_hash   : hash256;
      block_number : int;
      tx_hash      : hash256;
      tx_index     : int
    }

  type receipt =
    {
      block_hash          : hash256;
      block_number        : int;
      contract_address    : address option;
      cumulative_gas_used : Z.t;
      gas_used            : Z.t;
      src                 : address;
      dst                 : address option;
      logs                : log list;
      (* unused:
       * logs_bloom : string;
       * root : string; *)
      transaction_hash    : hash256;
      transaction_index   : int
    }

  and log =
    {
      log_address           : address;
      log_topics            : hash256 list;
      log_data              : string; (* hex_string *)
      log_block_number      : int;
      log_transaction_hash  : hash256;
      log_transaction_index : int;
      log_block_hash        : hash256;
      log_index             : int;
      log_removed           : bool
    }

  val accepted_from_json : Json.json -> accepted

  val to_json : t -> Json.json

  val receipt_from_json : Json.json -> receipt option    

end


(** Blocks *)
module Block :
sig

  (** Fields, extracted from the JSON RPC doc of Geth.
    number: QUANTITY - the block number. null when its pending block.
    hash: DATA, 32 Bytes - hash of the block. null when its pending block.
    parentHash: DATA, 32 Bytes - hash of the parent block.
    nonce: DATA, 8 Bytes - hash of the generated proof-of-work. null when its pending block.
    sha3Uncles: DATA, 32 Bytes - SHA3 of the uncles data in the block.
    logsBloom: DATA, 256 Bytes - the bloom filter for the logs of the block. null when its pending block.
    transactionsRoot: DATA, 32 Bytes - the root of the transaction trie of the block.
    stateRoot: DATA, 32 Bytes - the root of the final state trie of the block.
    receiptsRoot: DATA, 32 Bytes - the root of the receipts trie of the block.
    miner: DATA, 20 Bytes - the address of the beneficiary to whom the mining rewards were given.
    difficulty: QUANTITY - integer of the difficulty for this block.
    totalDifficulty: QUANTITY - integer of the total difficulty of the chain until this block.
    extraData: DATA - the "extra data" field of this block.
    size: QUANTITY - integer the size of this block in bytes.
    gasLimit: QUANTITY - the maximum gas allowed in this block.
    gasUsed: QUANTITY - the total used gas by all transactions in this block.
    timestamp: QUANTITY - the unix timestamp for when the block was collated.
    transactions: Array - Array of transaction objects, or 32 Bytes transaction hashes depending on the last given parameter.
    uncles: Array - Array of uncle hashes.
  *)
  type t =
    {
      number        : int option;
      hash          : hash256 option;
      parent_hash   : hash256;
      nonce         : int option;
      sha3_uncles   : hash256;
      logs_bloom    : string option;
      transactions_root : hash256;
      state_root    : hash256;
      receipts_root : hash256;
      miner         : address;
      difficulty    : Z.t;
      total_difficulty : Z.t;
      extra_data    : string;
      size          : Z.t;
      gas_limit     : Z.t;
      gas_used      : Z.t;
      timestamp     : Z.t;
      transactions  : Tx.accepted list;
      uncles        : hash256 list
    }

  val from_json : Json.json -> t

end



type port_info =
  {
    discovery : int;
    listener  : int
  }

type protocol_info =
    Eth of {
      difficulty : Z.t;
      genesis    : hash256 option;
      head       : hash256;
      network    : int option
    }

type node_info =
  {
    enode       : string;
    id          : hash512;
    ip          : string;
    listen_addr : string;
    name        : string;
    ports       : port_info;
    protocols   : protocol_info
  }

type network_info =
  {
    local_address  : string;
    remote_address : string;
  }

type peer =
  {
    caps      : string list;
    id        : hash512;
    name      : string;
    network   : network_info;
    protocols : protocol_info;
  }

type peer_info = peer list

type block_info =
  {
    block_root     : hash256;
    block_accounts : ba_info list
  }

and ba_info =
  {
    ba_account   : address;
    ba_balance   : Z.t;
    ba_code      : Evm.bytecode;
    ba_code_hash : hash256;
    ba_nonce     : int;
    ba_root      : hash256;
    ba_storage   : ba_storage
  }

and ba_storage =
  (hash256 * string) list

(* TODO: txpool *)
(* type txpool =
 *   {
 *     pending : txpool_info list;
 *     queued : txpool_info list
 *   }
 * 
 * and txpool_info =
 *   {
 *     (\* tx_block_hash   : hash512;
 *      * tx_block_number : int option;
 *      * tx_src          : address;
 *      * dst             :  *\)
 * 
 *         from: "0x0216d5032f356960cd3749c31ab34eeff21b3395",
 *         to: "0x7f69a91a3cf4be60020fb58b893b7cbb65376db8",
 *         gas: "0x5208",
 *         gasPrice: "0xba43b7400",
 *         value: "0x19a99f0cf456000"
 *         no data !
 *         nonce: "0x326",
 * 
 *         blockHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
 *         blockNumber: null,
 *           
 * 
 *         hash: "0xaf953a2d01f55cfe080c0c94150a60105e8ac3d51153058a1f03dd239dd08586",
 *         input: "0x",
 *         transactionIndex: null,            
 *   } *)

(* val transaction_to_json : transaction -> Json.json *)
(* val receipt_from_json : Json.json -> transaction_receipt option *)
val node_info_from_json : Json.json -> node_info option
val peer_info_from_json : Json.json -> peer_info
val block_from_json : Json.json -> block_info
