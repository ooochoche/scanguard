#[derive(Drop, Serde, starknet::Store, Clone)]
pub struct ProductParams {
    pub product_id: felt252,
    pub ipfs_hash: ByteArray,
}

#[derive(Drop, starknet::Event)]
pub struct VerifyProduct {
    pub product_id: felt252,
    pub ipfs_hash: ByteArray,
}
