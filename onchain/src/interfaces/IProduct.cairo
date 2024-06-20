use starknet::{ContractAddress};

#[starknet::interface]
pub trait IProducts<TState> {
    fn verify(self: @TState, product_id: felt252) -> ByteArray;
    fn store_product(
        ref self: TState,
        product_id: felt252,
        ipfs_hash: ByteArray,
        ownable_contract_address: ContractAddress
    );
    // fn verify(ref self: TState, product_id: felt252, ipfs_hash: ByteArray) -> bool;
}
