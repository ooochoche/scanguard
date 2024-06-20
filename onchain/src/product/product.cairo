use starknet::{ContractAddress};
use scanguard::base::types::{ProductParams};

const TWO_POW_32: u128 = 0x100000000;
const TWO_POW_64: u128 = 0x10000000000000000;
const TWO_POW_96: u128 = 0x1000000000000000000000000;

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

#[starknet::contract]
pub mod Product {
    use core::clone::Clone;
    use core::option::OptionTrait;
    use core::num::traits::zero::Zero;
    use core::traits::{TryInto, Into};
    use core::byte_array::ByteArrayTrait;
    use starknet::{ContractAddress, get_caller_address};
    use scanguard::interfaces::IProduct::IProducts;
    use scanguard::interfaces::IOwnable::{
        IOwnableContractDispatcher, IOwnableContractDispatcherTrait
    };
    use scanguard::utils::utils::{compute_sha256_byte_array};
    use scanguard::base::types::{ProductParams};
    use scanguard::base::errors::Errors::{ZERO_ADDRESS_OWNER, NOT_OWNER};

    use super::{TWO_POW_32, TWO_POW_64, TWO_POW_96};

    #[storage]
    struct Storage {
        products: LegacyMap::<felt252, ByteArray>,
        verified_products: LegacyMap::<felt252, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Verify: Verify,
    }

    #[derive(Drop, starknet::Event)]
    struct Verify {
        product_id: felt252,
        ipfs_hash: ByteArray,
        no_of_times_verified: u64,
    }

    #[abi(embed_v0)]
    impl ProductImpl of IProducts<ContractState> {
        fn verify(self: @ContractState, product_id: felt252) -> ByteArray {
            self.products.read(product_id)
        }

        fn store_product(
            ref self: ContractState,
            product_id: felt252,
            ipfs_hash: ByteArray,
            ownable_contract_address: ContractAddress
        ) {
            let caller = get_caller_address();
            let owner = IOwnableContractDispatcher { contract_address: ownable_contract_address }
                .get_owner();
            assert(caller == owner, NOT_OWNER);

            // let hash = self._hash_byte_array(ipfs_hash);

            self.products.write(product_id, ipfs_hash);
            self.verified_products.write(product_id, 0);
        }

        // fn verify(ref self: ContractState, product_id: felt252, ipfs_hash: ByteArray) -> bool {
        //     let stored_hash = self.products.read(product_id);

        //     let hash_to_verify = self._hash_byte_array(ipfs_hash.clone());

        //     if (stored_hash == hash_to_verify) {
        //         let verified_product = self.verified_products.read(product_id);
        //         self.verified_products.write(product_id, verified_product + 1);

        //         self
        //             .emit(
        //                 Verify {
        //                     product_id: product_id,
        //                     ipfs_hash: ipfs_hash,
        //                     no_of_times_verified: verified_product,
        //                 }
        //             );

        //         return true;
        //     }
        //     return false;
        // }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _hash_byte_array(ref self: ContractState, ba: ByteArray) -> u256 {
            let [x0, x1, x2, x3, x4, x5, x6, x7] = compute_sha256_byte_array(@ba);
            let hash = u256 {
                high: x0.into() * TWO_POW_96
                    + x1.into() * TWO_POW_64
                    + x2.into() * TWO_POW_32
                    + x3.into(),
                low: x4.into() * TWO_POW_96
                    + x5.into() * TWO_POW_64
                    + x6.into() * TWO_POW_32
                    + x7.into(),
            };
            hash
        }
    }
}
// class hash: 0x1ecca3c9f3462fd142ab143c876024a454fc6f412f8d3961f84ada05c154ac8
// ca: 0x53954be686dd89e05f2e2ce46c038aee9e053efbad79bf1f56ea85fb1d788ba


