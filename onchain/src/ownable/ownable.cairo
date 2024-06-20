use starknet::{get_caller_address, ContractAddress};

#[starknet::interface]
pub trait IOwnableContract<T> {
    fn set_owner(ref self: T, new_owner: ContractAddress);
    fn get_owner(self: @T) -> ContractAddress;
}


#[starknet::contract]
mod OwnerContract {
    use core::num::traits::zero::Zero;
    use starknet::{get_caller_address, ContractAddress};
    use scanguard::interfaces::IOwnable::IOwnableContract;
    use scanguard::base::errors::Errors::{ZERO_ADDRESS_OWNER, NOT_OWNER, ZERO_ADDRESS_CALLER};

    #[storage]
    struct Storage {
        owner: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), ZERO_ADDRESS_CALLER);
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl OwnerContractImpl of IOwnableContract<ContractState> {
        fn set_owner(ref self: ContractState, new_owner: ContractAddress) {
            assert(!new_owner.is_zero(), ZERO_ADDRESS_OWNER);
            let caller = get_caller_address();
            assert(caller == self.owner.read(), NOT_OWNER);
            self.owner.write(caller);
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }
}
// class hash: 0x31ed1c4e42aeda9ea22f39c4e75432610a2d2b994b1d316e31800ed21c25d12
// ca: 0x15579ffa45a70c8aa4e743ccd854bba75d2abfc6e34a13aff1e688b96af5d4e


