use core::option::OptionTrait;
use core::traits::{TryInto, Into};
use core::starknet::SyscallResultTrait;
use starknet::{ContractAddress, class_hash::ClassHash, contract_address_const};
use scanguard::interfaces::IProduct::{IProductsDispatcher, IProductsDispatcherTrait};
use scanguard::interfaces::IOwnable::{IOwnableContractDispatcher, IOwnableContractDispatcherTrait};
use scanguard::base::types::{ProductParams};
use snforge_std::{declare, ContractClassTrait, CheatTarget, start_prank, stop_prank};

const OWNER_ADDR: felt252 = 0x1;
const USER_ONE_ADDR: felt252 = 0x2;

fn __setup__() -> (ContractAddress, ContractAddress) {
    // deploy Owner contract
    let owner_contract = declare("OwnerContract").unwrap();
    let mut product_constructor_calldata = array![OWNER_ADDR];
    let (ownable_contract_address, _) = owner_contract
        .deploy(@product_constructor_calldata)
        .unwrap_syscall();

    // deploy Prodct contract
    let product_contract = declare("Product").unwrap();
    let mut product_constructor_calldata = array![];
    let (product_contract_address, _) = product_contract
        .deploy(@product_constructor_calldata)
        .unwrap_syscall();

    (ownable_contract_address, product_contract_address)
}

#[test]
#[should_panic(expected: ('Caller not owner',))]
fn test_store_product_with_incorrect_owner() {
    let (ownable_contract_address, product_contract_address) = __setup__();
    let product_dispatcher = IProductsDispatcher { contract_address: product_contract_address };

    start_prank(CheatTarget::One(product_contract_address), USER_ONE_ADDR.try_into().unwrap());

    let product_id: felt252 = 1;
    let ipfs_hash: ByteArray = "QmVqyWcuoBpHvt5tT5Gw9eJz2qYJyGKw4NY4yEdFcopK69";

    product_dispatcher.store_product(product_id, ipfs_hash.clone(), ownable_contract_address);

    stop_prank(CheatTarget::One(product_contract_address),);
}

#[test]
fn test_store_product_() {
    let (ownable_contract_address, product_contract_address) = __setup__();
    let product_dispatcher = IProductsDispatcher { contract_address: product_contract_address };

    start_prank(CheatTarget::One(product_contract_address), OWNER_ADDR.try_into().unwrap());

    let product_id: felt252 = 1;
    let ipfs_hash: ByteArray = "QmVqyWcuoBpHvt5tT5Gw9eJz2qYJyGKw4NY4yEdFcopK69";

    product_dispatcher.store_product(product_id, ipfs_hash.clone(), ownable_contract_address);

    let verify_product = product_dispatcher.verify(product_id);
    assert(verify_product == ipfs_hash, 'no products found');

    stop_prank(CheatTarget::One(product_contract_address),);
}

#[test]
fn test_store_multiple_products() {
    let (ownable_contract_address, product_contract_address) = __setup__();
    let product_dispatcher = IProductsDispatcher { contract_address: product_contract_address };
    start_prank(CheatTarget::One(product_contract_address), OWNER_ADDR.try_into().unwrap());

    let product_one_id: felt252 = 1;
    let ipfs_hash_one: ByteArray = "QmVqyWcuoBpHvt5tT5Gw9eJz2qYJyGKw4NY4yEdFcopK69";

    let product_two_id: felt252 = 2;
    let ipfs_hash_two: ByteArray = "QmVqyWcuoBpHvt5tT5Gw9eJz2qYJyGKw4NY4yEdFcncep5";

    product_dispatcher
        .store_product(product_one_id, ipfs_hash_one.clone(), ownable_contract_address);

    let verify_product_one = product_dispatcher.verify(product_one_id);
    assert(verify_product_one == ipfs_hash_one, 'no hashes matched');

    product_dispatcher
        .store_product(product_two_id, ipfs_hash_two.clone(), ownable_contract_address);

    let verify_product_two = product_dispatcher.verify(product_two_id);
    assert(verify_product_two == ipfs_hash_two, 'no hashes matched');

    stop_prank(CheatTarget::One(product_contract_address),);
}

