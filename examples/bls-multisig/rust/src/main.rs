use alloy::{primitives::U256, providers::ProviderBuilder, sol, sol_types::SolValue};
use blst::min_pk::{AggregateSignature, SecretKey, Signature};
use rand::RngCore;
use BLS::G2Point;

sol! {
    #[derive(Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
    #[sol(rpc)]
    BLSMultisig,
    "../../../out/BLSMultisig.sol/BLSMultisig.json"
}

impl From<[u8; 96]> for BLS::G1Point {
    fn from(value: [u8; 96]) -> Self {
        let mut data = [0u8; 128];
        data[16..64].copy_from_slice(&value[0..48]);
        data[80..128].copy_from_slice(&value[48..96]);

        BLS::G1Point::abi_decode(&data, false).unwrap()
    }
}

impl From<[u8; 192]> for BLS::G2Point {
    fn from(value: [u8; 192]) -> Self {
        let mut data = [0u8; 256];
        data[16..64].copy_from_slice(&value[48..96]);
        data[80..128].copy_from_slice(&value[0..48]);
        data[144..192].copy_from_slice(&value[144..192]);
        data[208..256].copy_from_slice(&value[96..144]);

        BLS::G2Point::abi_decode(&data, false).unwrap()
    }
}

/// Generates `num` BLS keys and returns them as a tuple of secret keys and public keys, sorted by public key.
fn generate_keys(num: usize) -> (Vec<SecretKey>, Vec<BLS::G1Point>) {
    let mut rng = rand::thread_rng();
    let mut keys = Vec::with_capacity(num);

    for _ in 0..num {
        let mut ikm = [0u8; 32];
        rng.fill_bytes(&mut ikm);

        let sk = SecretKey::key_gen(&ikm, &[]).unwrap();
        let pk: BLS::G1Point = sk.sk_to_pk().serialize().into();

        keys.push((sk, pk));
    }

    keys.sort_by(|(_, pk1), (_, pk2)| pk1.cmp(pk2));

    keys.into_iter().unzip()
}

/// Signs a message with the provided keys and returns the aggregated signature.
fn sign_message(keys: &[SecretKey], msg: &[u8]) -> G2Point {
    let mut sigs = Vec::new();

    // create individual signatures
    for key in keys {
        let sig = key.sign(msg, b"BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_", &[]);
        sigs.push(sig);
    }

    let agg_sig = Signature::from_aggregate(
        &AggregateSignature::aggregate(sigs.iter().collect::<Vec<_>>().as_slice(), false).unwrap(),
    );

    agg_sig.serialize().into()
}

#[tokio::main]
pub async fn main() {
    let provider = ProviderBuilder::new().on_anvil_with_config(|config| config.arg("--alphanet"));

    let (keys, signers) = generate_keys(100);

    let multisig = BLSMultisig::deploy(provider, signers.clone(), U256::from(1))
        .await
        .unwrap();

    let operation = BLSMultisig::Operation::default();

    let signature = sign_message(&keys, &operation.abi_encode());

    let receipt = multisig
        .verifyAndExecute(BLSMultisig::SignedOperation {
            operation: operation.clone(),
            signers,
            signature,
        })
        .send()
        .await
        .unwrap()
        .get_receipt()
        .await
        .unwrap();

    assert!(receipt.status());
}
