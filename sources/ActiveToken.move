address admin {

module ActiveToken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct ACTIVE{}

    struct CoinCapabilities<phantom ACTIVE> has key {
        mint_capability: coin::MintCapability<ACTIVE>,
        burn_capability: coin::BurnCapability<ACTIVE>,
        freeze_capability: coin::FreezeCapability<ACTIVE>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_active(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<ACTIVE>(
            account,
            string::utf8(b"ACTIVE Token"),
            string::utf8(b"ACTIVE"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<ACTIVE>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<ACTIVE>>(account, CoinCapabilities<ACTIVE>{mint_capability, burn_capability, freeze_capability});
    }

    public entry fun mint<ACTIVE>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<ACTIVE>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<ACTIVE>>(account_address).mint_capability;
        let coins = coin::mint<ACTIVE>(amount, mint_capability);
        coin::deposit(user, coins)
    }
}
}