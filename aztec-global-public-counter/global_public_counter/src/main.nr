use aztec::macros::aztec;

#[aztec]
pub contract Counter {
    // imports specific to the contract
    use aztec::macros::{functions::{initializer, public}, storage::storage}; 
    use aztec::prelude::{PublicMutable}; 
    // unused
    // use aztec::protocol_types::traits::{}; 
    // use easy_private_state::{}; 
    // use value_note::{}; 

    // constructor
    #[initializer]
    #[public]
    // We can name our initializer anything we want as long as it's marked as aztec(initializer)
    fn initialize() {
    }

    unconstrained fn get_counter() -> pub Field {
        storage.counter.read()
    }
    
    #[storage]
    struct Storage<Context> {
        counter: PublicMutable<Field,Context>     
    }


    #[public]
    fn increment() {
        // doesnt need to be unsafe like in other counters. Since we don't do .to_field()
        dep::aztec::oracle::debug_log::debug_log("Incrementing counter :D");

        let new_total = storage.counter.read() + 1;
        storage.counter.write(new_total);
    }

}
