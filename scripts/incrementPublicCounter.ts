import { AztecAddress, Contract,createPXEClient,waitForPXE, Fr, GrumpkinScalar  } from '@aztec/aztec.js';
import { CounterContractArtifact } from '../aztec-public-counter/public_counter/src/artifacts/Counter'
import {counter as contractAddress} from "../PublicCounterAddresses.json";
import { getInitialTestAccountsWallets,getDeployedTestAccountsWallets } from '@aztec/accounts/testing';
import { getSchnorrAccount } from '@aztec/accounts/schnorr';


const PXE_URL = process.env.PXE_URL || 'http://localhost:8080';
const pxe = createPXEClient(PXE_URL);
const secretKey = Fr.fromHexString("0x1234");
const signingPrivateKey = GrumpkinScalar.fromHexString("0x1234");
const salt = 1234n;
// docs:end:define_account_vars

// docs:start:create_wallet
// Use a pre-funded wallet to pay for the fees for the deployments.
const wallet = (await getDeployedTestAccountsWallets(pxe))[0];
const newAccount = await getSchnorrAccount(pxe, secretKey, signingPrivateKey, salt);

//TODO do this properly
try {
    await newAccount.deploy({ deployWallet: wallet }).wait();
} catch (error) {
    console.log("newAccount.deploy got a error. assuming its already deployed! :P")
}

const newWallet = await newAccount.getWallet();

const contractAddressWithType = AztecAddress.fromString(contractAddress)
console.log({contractAddressWithType, newWalletAddr: newWallet.getAddress()})
const contract = await Contract.at(contractAddressWithType, CounterContractArtifact, wallet);

const countBeforeTx= await contract.methods.get_counter(newWallet.getAddress()).simulate();
console.log({countBeforeTx})

const _tx = await contract.methods.increment(newWallet.getAddress(),newWallet.getAddress()).send().wait();
console.log({txhash:_tx.txHash, blockNumber:_tx.blockNumber})

const countAfterTx = await contract.methods.get_counter(newWallet.getAddress()).simulate();
console.log({countAfterTx})