use starknet::{ContractAddress};

#[starknet::contract]
pub mod Product {
    use core::clone::Clone;
    use core::option::OptionTrait;
    use core::num::traits::zero::Zero;
    use core::traits::{TryInto, Into};
    use core::byte_array::ByteArrayTrait;
    use starknet::{ContractAddress, get_caller_address};
    use scanguard::interfaces::IProduct::IProducts;
    use scanguard::base::types::{ProductParams};
    use scanguard::base::errors::Errors::{ZERO_ADDRESS_CALLER, ZERO_ADDRESS_OWNER, NOT_OWNER};

    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;


    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        products: LegacyMap::<felt252, ByteArray>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        Verify: Verify,
    }

    #[derive(Drop, starknet::Event)]
    struct Verify {
        product_id: felt252,
        ipfs_hash: ByteArray,
        no_of_times_verified: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let caller: ContractAddress = get_caller_address();
        assert(!caller.is_zero(), ZERO_ADDRESS_CALLER);
        self.ownable.initializer(caller);
    }

    #[abi(embed_v0)]
    impl ProductImpl of IProducts<ContractState> {
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.ownable.owner()
        }

        fn verify(self: @ContractState, product_id: felt252) -> ProductParams {
            let ipfs_hash = self.products.read(product_id);

            if (ipfs_hash != "0") {
                let product = ProductParams { product_id: product_id, ipfs_hash: ipfs_hash };
                return product;
            }

            ProductParams { product_id: product_id, ipfs_hash: ipfs_hash }
        }

        fn register_product(ref self: ContractState, product_id: felt252, ipfs_hash: ByteArray) {
            self.ownable.assert_only_owner();
            self.products.write(product_id, ipfs_hash);
        }
    }
}
// class hash: 0x1ecca3c9f3462fd142ab143c876024a454fc6f412f8d3961f84ada05c154ac8
// ca: 0x53954be686dd89e05f2e2ce46c038aee9e053efbad79bf1f56ea85fb1d788ba


