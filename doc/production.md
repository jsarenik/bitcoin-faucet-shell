# Current Production Environment

Here's what runs on the same machine which is
a recycled Intel MacBookPro 2012 running Linux
natively:

  * `nice -n 15 ionice -c 3 bitcoind -signet`

  * faucet loop script sends payouts and regularly refreshes
    the wallets

  * faucet web interface in `busybox httpd` facing Cloudflare
    over Caddy2

## Walkthrough

The local network is 100Mbps Ethernet with cake scheduler
(`sch_cake`) on the main router. Could be replaced with
another router when needed.

The bandwidth of the connection to internet is 50Mbps down
and 10Mbps up. If any attack is executed from the outside
the attacker quickly notices that although their machines
may get quite busy, the server here does not care since it
is dropping merely the excess packets received over an
already bandwidth-shaped-by-ISP network interface.

There are no publicly accessible control ports (like SSH),
even the HTTP ports (80 and 443, both TCP and UDP) talk
only to Cloudflare and shall be invisible for others.

So each client accessing `alt.signetfaucet.com` in their
web browser like Chromium (Chrome) or Firefox is first
being quickly (still on Cloudflare) redirected to
`signet257.bublina.eu.org` which is still showing just
IP addresses of Cloudflare but talking straight to the
main locally-run faucet server behind the scenes.

The payouts are being sent in real signet Bitcoin test
network transactions which are movable when mined in
a block. Until then they are held by maxancestor default
limit of 25 (incl. the leaf), soon to be generally
held by `limitclustercount` of 64.
