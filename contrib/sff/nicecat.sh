#!/bin/sh

VERSION="1.1.0"
DEFAULT_REMOTE_HOST="singer"

# Extract just the filename from $0 for clean usage printing
SCRIPT_NAME="${0##*/}"

# 1. Handle Version Flags
if test "$1" = "-v" || test "$1" = "-V" || test "$1" = "--version"; then
    echo "nicecat version $VERSION"
    exit 0
fi

# 2. Check for Help Flags or Missing Arguments
if test -z "$1" || test "$1" = "-h" || test "$1" = "--help" || test "$1" = "--usage"; then
    if test -z "$1"; then
        exec >&2
    fi

    echo "Usage:"
    echo "  Local view & save:  $SCRIPT_NAME <target_file>"
    echo "  Remote update:      $SCRIPT_NAME -R [ssh_host]  (default: $DEFAULT_REMOTE_HOST)"
    echo "  Version check:      $SCRIPT_NAME -V"

    if test -z "$1"; then
        exit 1
    fi
    exit 0
fi

# 3. Handle Remote Deployment Flag (-R)
if test "$1" = "-R"; then
    if test -n "$2"; then
        REMOTE_HOST="$2"
    else
        REMOTE_HOST="$DEFAULT_REMOTE_HOST"
    fi

    # Find where this running script lives so we can read it
    SCRIPT_PATH="$0"
    if test ! -f "$SCRIPT_PATH"; then
        SCRIPT_PATH=$(which "$0" 2>/dev/null)
    fi

    if test -z "$SCRIPT_PATH" || test ! -f "$SCRIPT_PATH"; then
        echo "Error: Could not determine the local script path for streaming." >&2
        exit 1
    fi

    echo "Atomically deploying script to remote host: $REMOTE_HOST..."

    # Securely stream this script into the remote safecat instance to overwrite itself
    cat "$SCRIPT_PATH" | ssh "$REMOTE_HOST" "bin/safecat.sh bin/nicecat.sh"
    exit $?
fi

# 4. Standard Operation: Save to file and display output via file descriptors
exec 3>&1
tee /dev/fd/3 | safecat.sh "$1"
exec 3>&-
