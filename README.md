# bitcoin-faucet-shell

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/jsarenik/bitcoin-faucet-shell)

***This is a test network. Coins have no value.***

**alt.signetfaucet is intended for education purposes
  in controlled environment with free testing sats.
  The learned skills may be used with real Bitcoin
  main network.**

A POSIX shell implementation of a Bitcoin faucet
intended for use with [Busybox](https://busybox.net).

Re-implementation. The original source of this faucet
comes from https://github.com/kallewoof/bitcoin-faucet

The point is to have something that can run anywhere
and has no dependencies other than Bitcoin Core and
`busybox` (which can be statically compiled for
`Linux x86_64` into a binary smaller than 1MB).

It runs at https://signet25.bublina.eu.org (try to open it
in the Tor Browser) and any feedback is welcome here in
GitHub issues, or via email.

## Documentation

See also `git log`, about.html and https://github.com/jsarenik/bitcoin-faucet-shell/issues/4.

### API

The original REST API is following:

    https://signetfaucet.com/claim/addr/amount/captcha

Amount is ignored here and captcha is any random string of
at least 32 characters (the interactive CF turnstille is just
for show now, not really used on server-side anymore).

Busybox is returning 404 error on non-existent directories
so it has to be used with Caddy2 to get a backward-compatible
API. See in-repo `Caddyfile.txt` for an example on how to set
up the redirects properly.

See `contrib/getcoins.sh` for an example script using wget.
