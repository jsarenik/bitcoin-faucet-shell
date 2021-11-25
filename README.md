# bitcoin-faucet-shell

A POSIX shell implementation of a Bitcoin faucet
intended for use with [Busybox](https://busybox.net).

Re-implementation. The original source of this faucet
comes from https://github.com/kallewoof/bitcoin-faucet

The point is to have something that can run anywhere
and has no other dependencies than Bitcoin and `busybox`
(which cat be statically compiled for `x86_64` architecture
into a binary smaller than 1MB).

It runs at https://signet.bublina.eu.org

### Documentation

See `git log` and about.html.
