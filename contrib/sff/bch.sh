#!/bin/sh

test -d "$1" && { cd "$1" || exit 1; shift; }
test -d .bitcoin && { cd .bitcoin || exit 1; }
ls -A | grep -q . || exit 1

# Handle calls invoked from inside a wallet directory
test -r wallet.dat && {
    mypwd=$PWD
    test -L "$PWD" && mypwd=$(readlink "$PWD")
    w="-rpcwallet=${mypwd##*/}"
    case "$mypwd" in
        /*) ;;
        *) cd .. || exit 1 ;;
    esac
}
cd "${PWD%/wallets*}" || exit 1
ADD=$(printf '%s\n' "$PWD" | md5sum | cut -b-7)
test "$1" = "-i" && {
    printf '%s\n' "$ADD"
    exit 0
}

cmd=bitcoin-cli
test -r blocks || cd "$HOME/.bitcoin" || exit 1

# main signet testnet3 testnet4 regtest liquidv1 liquidtestnet liquidregtest
c=${PWD##*/}
chain=${c%net3}
case "$chain" in
    signet|test|testnet4|regtest|liquid*) ddir=${PWD%/*} ;;
    *) chain="" ;;
esac
chain=${chain:-main}
test -d "/tmp/bdsd-$chain-$ADD" && exit 1

case "$chain" in
    liquid*) cmd=elements-cli ;;
esac

add=""
test "$1" = "-k" && exec pkill -f "$cmd -datadir=${ddir:-$PWD}"
test "$1" = "-g" && exec pgrep -f "$cmd -datadir=${ddir:-$PWD}"
test "$1" = "-t" && { add="-rpcclienttimeout=0"; shift; }

test "$1" = "stop" && mkdir "/tmp/bdsd-$chain-$ADD"

exec "$cmd" $add -datadir="${ddir:-$PWD}" -chain="$chain" $w "$@"
