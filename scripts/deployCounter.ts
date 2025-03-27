import { CounterContractArtifact } from '../aztec-private-counter/contracts/counter/src/artifacts/Counter'
import { createPXEClient, waitForPXE, Contract } from "@aztec/aztec.js"
import { getInitialTestAccountsWallets } from '@aztec/accounts/testing';

import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';

const { PXE_URL = 'http://localhost:8080' } = process.env;

// this is the way to do it in a testing environment.
// for test/dev/main do this https://docs.aztec.network/developers/guides/js_apps/deploy_contract#using-generated-contract-class
// TODO create that script
async function main() {
    console.log("creating PXE client")
    const pxe = createPXEClient(PXE_URL);
    console.log("waiting on PXE client", PXE_URL)
    await waitForPXE(pxe);

    console.log("getting test accounts")
    const [ownerWallet] = await getInitialTestAccountsWallets(pxe);
    const ownerAddress = ownerWallet.getAddress();

    console.log("deploying")
    const counter = await Contract.deploy(ownerWallet, CounterContractArtifact, [0,ownerAddress])
        .send()
        .deployed();

    console.log(`Token deployed at ${counter.address.toString()}`);

    const addresses = { token: counter.address.toString() };
    writeFileSync('addresses.json', JSON.stringify(addresses, null, 2));
}
console.log("hi")
await main();