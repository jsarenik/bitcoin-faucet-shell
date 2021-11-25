# bitcoin-faucet-shell

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

### Documentation

See `git log` and about.html.
