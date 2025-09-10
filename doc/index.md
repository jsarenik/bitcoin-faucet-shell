# alt.signetfaucet

The main purpose this `bitcoin-faucet-shell` is being developed
is the alternative signet faucet available at multiple addresses:

 * alt.signetfaucet.com
 * signet.bublina.eu.org
 * signetfaucet.bublina.eu.org
 * signet25.bublina.eu.org
 * signet257.bublina.eu.org

Whereas `signet257` is the current subdomain name all the others point
to. Feel free to redirect to https://signet257.bublina.eu.org from any
domain you like.

The faucet depends on a sustainable inflow of sats which is quite easy
to do on a bitcoin signet test-network. This faucet receives 100 test
bitcoins on a global default signet network every 50 blocks.

Faucet's advantage are:

 1. the use of [Cloudflare Turnstile](
https://cloudflare.com/application-services/products/turnstile/)

 2. the use of 25-long in-mempool chain of transactions which helps
to keep the balance big enough with a buffer

 3. wallet refreshing which makes sure
the wallet of the faucet is very small and fast

## Turnstile

The Turnstile helps to limit the rate of requests by requiring the unique
token be used in each request and verifying it with [Siteverify API](
https://developers.cloudflare.com/turnstile/get-started/server-side-validation).

Behind the scenes there is also a mechanism implemented inside `GET.sh`
script which allows only one request from one IP address at the same time.
But many different requests from the same IP address are allowed until
the current overall number of requests reaches 2016 given the address
used is not the same as in previous requests inside the same payout batch.

Example: One asks the faucet to send sats to [tb1pfees9rn5nz](
https://signet257.bublina.eu.org/?x=tb1pfees9rn5nz) once and the transaction
will be added to the main faucet payout transaction in about 30 seconds,
but on another request to the same address there could be two outputs for
a while but that's the biggest number of payouts to the same address ever
possible on this faucet.


## 25-long in-mempool chain

`25` is the default setting for `limitancestorcount` in Bitcoin Core <= 29.0.

This chain of transactions helps with making sure the outputs can not be
spent until confirmed in a block. Helps with attempts to drain faucet's
balance by quickly spending an incoming UTXO while the transaction is still
in the mempool.

Helps a lot with regular RBF every 30 seconds.
See [...dent4 LIVE on mempool.space/signet](https://mempool.space/signet/address/tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4)


## Refreshing wallets

Finally, the long-life of this faucet is guaranteed by regularly refreshing
the descriptor wallets used and keeping it merely in `tmpfs` (an in-memory
Linux filesystem). Currently there are three wallets:

 1. Main signet wallet (`/dev/shm/wallets-signet/newmy*`)
 2. LN Anchor signet wallet (`/dev/shm/wallets-signet/lnanchor`)
 3. OP_TRUE signet wallet (`/dev/shm/wallets-signet/optrue`)

Current stats for the wallet can be seen in the end of [`sffrest.txt`](
https://signet257.bublina.eu.org/sffrest.txt) and the raw size of the wallets
in kilobytes is shown there.


# See also

https://delvingbitcoin.org/t/signet-faucet-using-25-long-tx-chain-rbf/1426
