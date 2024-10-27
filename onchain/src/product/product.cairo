#[starknet::contract]
pub mod Product {
    use core::num::traits::zero::Zero;
    use core::starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::ContractAddress;
    use scanguard::interfaces::IProduct::IProducts;
    use scanguard::base::types::{ProductParams, VerifyProduct};
    use scanguard::base::errors::Errors::ZERO_ADDRESS_CALLER;
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;


    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        products: Map::<felt252, ByteArray>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        VerifyProduct: VerifyProduct,
        ProductRegistered: ProductRegistered
    }

    /// @notice Emitted when a product is registered
    /// @param product_id the ID of the product
    /// @param ipfs_hash
    #[derive(Drop, starknet::Event)]
    pub struct ProductRegistered {
        pub product_id: felt252,
        pub ipfs_hash: ByteArray
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), ZERO_ADDRESS_CALLER);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl ProductImpl of IProducts<ContractState> {
        fn verify(ref self: ContractState, product_id: felt252) -> ProductParams {
            let ipfs_hash = self.products.read(product_id);

            self.emit(VerifyProduct { product_id: product_id, ipfs_hash: ipfs_hash.clone() });
            ProductParams { product_id: product_id, ipfs_hash: ipfs_hash }
        }

        fn register_product(ref self: ContractState, product_id: felt252, ipfs_hash: ByteArray) {
            self.ownable.assert_only_owner();
            self.products.write(product_id.clone(), ipfs_hash.clone());

            self.emit(ProductRegistered { product_id, ipfs_hash, });
        }
    }
}
