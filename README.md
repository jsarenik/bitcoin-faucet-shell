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
and has no other dependencies than Bitcoin and `busybox`
(which can be statically compiled for `Linux x86_64`
into a binary smaller than 1MB).

It runs at https://signet.bublina.eu.org (try to open it
in the Tor Browser) and any feedback is welcome here in
GitHub issues (or anonymously at
[bin.bublina.eu.org](https://bin.bublina.eu.org/?68dbfa5698fcf316#6KBGZkWssS3TrzTVg93K7VCQECBTmwKn2x9WjRYV72rn)).

## Documentation

See also `git log`, about.html and https://github.com/jsarenik/bitcoin-faucet-shell/issues/4.

### API not supported

The original REST API is following:

    https://signetfaucet.com/claim/addr/amount/captcha

Since 2025 change, the faucet is intended to be interactively used
by a human running it in a modern browser (Chromium and Google Chrome
work for sure, both desktop and mobile).
