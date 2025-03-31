use dep::std::hash::poseidon;
use std::ops::{Add};

use std::embedded_curve_ops::{EmbeddedCurveScalar, EmbeddedCurvePoint};
use std::hash::pedersen_commitment;
// message = "hii"
// digest = ethers.hashMessage(message)
// sig = await signer.signMessage(message)
// sig = ethers.Signature.from( await signer.signMessage(message))
// pubkey = ethers.SigningKey.recoverPublicKey(digest, sig)
// address = "0x"+ethers.keccak256("0x" + pubkey.slice(4)).slice(26)



#[test]
fn test_pedersen_hash() {
    let amount_bob: Field = 1;
    let amount_alice: Field = 2; // rename to amounts

    let shared_secret_bob: Field = 123; // should be nonce
    let shared_secret_alice: Field = 456;

    let commitment_x: EmbeddedCurvePoint = pedersen_commitment([amount_bob,shared_secret_bob]);
    let commitment_y: EmbeddedCurvePoint= pedersen_commitment([amount_alice,shared_secret_alice]);
    
    let total: Field = amount_bob+amount_alice;
    let combined_secrets: Field = shared_secret_bob+shared_secret_alice;
    let curvepoint_from_combine_preimg: EmbeddedCurvePoint = pedersen_commitment([total, combined_secrets]);
    let combined_curve_points: EmbeddedCurvePoint = commitment_x.add(commitment_y);

    //

    println(f"curvepoint_from_combine_preimg: {curvepoint_from_combine_preimg}");
    println(f"combined_curve_points:          {combined_curve_points}");


    assert(curvepoint_from_combine_preimg == combined_curve_points, "didn't work :(");
}


// this is probably not safe?? 
fn encrypt_poseidon(message: Field, secret: Field) -> Field {
    message + poseidon::bn254::hash_1([secret]) 
}

fn decrypt_poseidon(encrypted_message: Field, secret: Field) -> Field {
    encrypted_message - poseidon::bn254::hash_1([secret]) 
}

pub struct CipherText {
    embedded_randomness: EmbeddedCurvePoint,
    encrypted_message: Field
}


// based of https://github.com/jat9292/noir-elgamal
// TODO this probably broken or unsafe.

// but it doenst use plaintext as a scaler to be put on the curve. Which would create the problem of solving the discrete log, just to decrypt it
// instead i used a symmetric crypto method 

// randomness needs to be a big number since it can be found if its small since it used on as scalar on a CurvePoint that is public
// embedded_randomness is in public and is embedded_randomness= public_key * randomness
// if found. a attack can know the shared_secret and decrypt because shared_secret=public_key * randomness
// use ecdh from zk-kit instead https://github.com/privacy-scaling-explorations/zk-kit.noir/tree/main/packages/ecdh
// or look at https://github.com/privacy-scaling-explorations/zk-kit/blob/main/packages/eddsa-poseidon/src/eddsa-poseidon-factory.ts
// or this https://github.com/ewynx/noir-elgamal

pub fn asym_encrypt(public_key: EmbeddedCurvePoint, plaintext:Field, randomness: EmbeddedCurveScalar) -> CipherText
{
    let  base_pt =  EmbeddedCurvePoint {
        x: 1,
        y: 17631683881184975370165255887551781615748388533673675138860, // sqrt(-16)
        is_infinite: false,
    };
    let embedded_randomness: EmbeddedCurvePoint= std::embedded_curve_ops::multi_scalar_mul([base_pt], [randomness]); // we add base_pt here so no-one can see what the randomness is
    let shared_secret: EmbeddedCurvePoint = std::embedded_curve_ops::multi_scalar_mul([public_key],[randomness] ); // (base_pt * privateKey) * randomness. we do randomness * public_key, so shared_secret can be reconstructed with embedded_randomness * private_key

    // TODO do posseidon cypher or EAS
    let encrypted_message = encrypt_poseidon(plaintext,shared_secret.x); // we dont need a nonce since shared secret is uses "randomness" which is a nonce
    CipherText{embedded_randomness, encrypted_message}
}

pub fn asym_decrypt(private_key : std::embedded_curve_ops::EmbeddedCurveScalar, ciphertext:CipherText) -> Field
{
  let shared_secret =  std::embedded_curve_ops::multi_scalar_mul([ciphertext.embedded_randomness],[private_key]); // (base_pt * randomness) * private_key
  let plain_embedded = decrypt_poseidon(ciphertext.encrypted_message, shared_secret.x);//ciphertext.1.sub(shared_secret);       
  plain_embedded 
}

#[test]
fn test_asymmetric_encryption() {
    let  base_pt =  EmbeddedCurvePoint {
        x: 1,
        y: 17631683881184975370165255887551781615748388533673675138860, // sqrt(-16)
        is_infinite: false,
    };
    let privKey = std::embedded_curve_ops::EmbeddedCurveScalar::from_field(0x1234);

    let pubKey = std::embedded_curve_ops::multi_scalar_mul([base_pt],[privKey]);
    let message = 0xb00b;//std::embedded_curve_ops::EmbeddedCurveScalar::from_field(0xb00b);
    let nonce= std::embedded_curve_ops::EmbeddedCurveScalar::from_field(0x4567);

    let encrypted = asym_encrypt(pubKey, message,nonce);
    let decrypted =  asym_decrypt(privKey, encrypted);

    println(f"{message}");
    println(f"encrypted{encrypted}");
    println(f"decrypted: {decrypted}");
}



#[test]
fn test_eas() {
    let input: [u8; 16] = 0x6e6f697220676f6f64.to_be_bytes(); // Random bytes, will be padded to 16 bytes.
    let iv: [u8; 16] = [0; 16]; // Initialisation vector
    let key: [u8; 16] = 0x11111111111111111111111111111111.to_be_bytes(); // AES key
    let ciphertext = std::aes128::aes128_encrypt(input, iv, key);
    //TODO this can break since 32 bytes can be > Field Limit
    let cypherField = dep::std::field::bytes32_to_field(ciphertext);
    println(f"cypherHex:{cypherField}");
}
/*
decrypt in js
ciphertext=new Uint8Array([224, 213, 65, 49, 78, 0, 16, 45, 109, 252, 168, 188, 0, 123, 108, 138, 197, 134, 6, 67, 199, 27, 168, 165, 52, 117, 8, 113, 136, 222, 173, 55, 118, 199, 250, 151, 25, 95, 169, 193, 10, 203, 40, 27, 248, 253, 168, 219]);
rawKey=new Uint8Array([17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17]);
iv=new Uint8Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
key= await window.crypto.subtle.importKey("raw",rawKey,{ name: "AES-CBC"},true,["encrypt","decrypt"]);
decrypted = new Uint8Array(await window.crypto.subtle.decrypt({ name: "AES-CBC", iv }, key, ciphertext));
decryptedHex = [...decrypted].reduce((a,x)=>a+x.toString(16),"0x");
*/

