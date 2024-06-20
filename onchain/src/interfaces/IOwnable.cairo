use starknet::{ContractAddress};

#[starknet::interface]
pub trait IOwnableContract<T> {
    fn set_owner(ref self: T, new_owner: ContractAddress);
    fn get_owner(self: @T) -> ContractAddress;
}