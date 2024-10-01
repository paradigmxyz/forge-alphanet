use alloy::{primitives::U256, providers::ProviderBuilder, sol, sol_types::SolValue};
use blst::{
    blst_bendian_from_fp, blst_fp, blst_fp2, blst_fp_from_bendian, blst_keygen, blst_p1,
    blst_p1_affine, blst_p1_to_affine, blst_p2, blst_p2_add_or_double, blst_p2_affine,
    blst_p2_from_affine, blst_p2_to_affine, blst_scalar, blst_sign_pk_in_g1, blst_sk_to_pk_in_g1,
};
use rand::RngCore;
use BLS::G2Point;

sol! {
    #[derive(Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
    #[sol(rpc)]
    BLSMultisig,
    "../../out/BLSMultisig.sol/BLSMultisig.json"
}

impl From<BLS::Fp> for blst_fp {
    fn from(value: BLS::Fp) -> Self {
        let data = value.abi_encode();

        let mut val = blst_fp::default();
        unsafe { blst_fp_from_bendian(&mut val, data[16..].as_ptr()) };

        val
    }
}

impl From<blst_fp> for BLS::Fp {
    fn from(value: blst_fp) -> Self {
        let mut data = [0u8; 48];
        unsafe { blst_bendian_from_fp(data.as_mut_ptr(), &value) };

        Self {
            a: U256::from_be_slice(&data[..16]),
            b: U256::from_be_slice(&data[16..]),
        }
    }
}

impl From<BLS::Fp2> for blst_fp2 {
    fn from(value: BLS::Fp2) -> Self {
        Self {
            fp: [value.c0.into(), value.c1.into()],
        }
    }
}

impl From<blst_fp2> for BLS::Fp2 {
    fn from(value: blst_fp2) -> Self {
        Self {
            c0: value.fp[0].into(),
            c1: value.fp[1].into(),
        }
    }
}

impl From<BLS::G2Point> for blst_p2 {
    fn from(value: BLS::G2Point) -> Self {
        let b_aff = blst_p2_affine {
            x: value.x.into(),
            y: value.y.into(),
        };

        let mut b = blst_p2::default();
        unsafe { blst_p2_from_affine(&mut b, &b_aff) };

        b
    }
}

impl From<blst_p2> for BLS::G2Point {
    fn from(value: blst_p2) -> Self {
        let mut affine = blst_p2_affine::default();
        unsafe { blst_p2_to_affine(&mut affine, &value) };

        BLS::G2Point {
            x: affine.x.into(),
            y: affine.y.into(),
        }
    }
}

impl From<blst_p1> for BLS::G1Point {
    fn from(value: blst_p1) -> Self {
        let mut affine = blst_p1_affine::default();
        unsafe { blst_p1_to_affine(&mut affine, &value) };

        BLS::G1Point {
            x: affine.x.into(),
            y: affine.y.into(),
        }
    }
}

/// Generates `num` BLS keys and returns them as a tuple of secret keys and public keys, sorted by public key.
fn generate_keys(num: usize) -> (Vec<blst_scalar>, Vec<BLS::G1Point>) {
    let mut rng = rand::thread_rng();
    let mut keys = Vec::with_capacity(num);

    for _ in 0..num {
        let mut ikm = [0u8; 32];
        rng.fill_bytes(&mut ikm);

        let key_info: &[u8] = &[];

        // secret key
        let mut sk = blst_scalar::default();
        unsafe {
            blst_keygen(
                &mut sk,
                ikm.as_ptr(),
                ikm.len(),
                key_info.as_ptr(),
                key_info.len(),
            )
        };

        // public key
        let mut pk = blst_p1::default();
        unsafe { blst_sk_to_pk_in_g1(&mut pk, &sk) }

        keys.push((sk, BLS::G1Point::from(pk)));
    }

    keys.sort_by(|(_, pk1), (_, pk2)| pk1.cmp(pk2));

    keys.into_iter().unzip()
}

/// Signs a message with the provided keys and returns the aggregated signature.
fn sign_message(keys: &[blst_scalar], message: blst_p2) -> G2Point {
    let mut signatures = Vec::new();

    // create individual signatures
    for key in keys {
        let mut sig = blst_p2::default();
        unsafe { blst_sign_pk_in_g1(&mut sig, &message, key) };

        signatures.push(sig);
    }

    // aggregate signatures by adding them
    let mut agg_sig = signatures.swap_remove(0);
    for sig in signatures {
        unsafe { blst_p2_add_or_double(&mut agg_sig, &agg_sig, &sig) };
    }

    agg_sig.into()
}

#[tokio::main]
pub async fn main() {
    let provider = ProviderBuilder::new().on_anvil_with_config(|config| config.arg("--alphanet"));

    let (keys, signers) = generate_keys(100);

    let multisig = BLSMultisig::deploy(provider, signers.clone(), U256::from(1))
        .await
        .unwrap();

    let operation = BLSMultisig::Operation::default();

    let point: blst_p2 = multisig
        .getOperationPoint(operation.clone())
        .call()
        .await
        .unwrap()
        ._0
        .into();

    let signature = sign_message(&keys, point);

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
