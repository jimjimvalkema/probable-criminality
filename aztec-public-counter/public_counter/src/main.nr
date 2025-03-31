use aztec::macros::aztec;

#[aztec]
pub contract Counter {
    // Weird that imports need to be inside here??
    use aztec::macros::{functions::{initializer, private}, storage::storage}; // used to store private or public state
    use aztec::prelude::{AztecAddress, Map}; // address and mapping
    use aztec::protocol_types::traits::{FromField, ToField}; // utils
    use easy_private_state::EasyPrivateUint; // collects all utxo so we can just fuck with it like its a Uint
    use value_note::{balance_utils, value_note::ValueNote}; // the private note types aka UTXOs types

    // constructor bassically
    #[initializer]
    #[private]
    // We can name our initializer anything we want as long as it's marked as aztec(initializer)
    fn initialize(headstart: u64, owner: AztecAddress) {
        // headstart = how much state to initialize with
        let counters = storage.counters;
        counters.at(owner).add(headstart, owner, context.msg_sender());
    }

    unconstrained fn get_counter(owner: AztecAddress) -> pub Field {
        let counters = storage.counters;
        balance_utils::get_balance(counters.at(owner).set) // what does counters.at(owner).set return? is it somekind of id thing to collect the utxos here?
    }
    
    #[storage]
    struct Storage<Context> {
        counters: Map<AztecAddress, EasyPrivateUint<Context>, Context>,
    }


    #[private]
    fn increment(owner: AztecAddress, sender: AztecAddress) {
        unsafe {
            // unsafe?? i gues this log is just debug?
            dep::aztec::oracle::debug_log::debug_log_format(
                "Incrementing counter for owner {0}",
                [owner.to_field()],
            );
        }
        let counters = storage.counters;
        counters.at(owner).add(1, owner, sender); // increment yay!
    }

}
