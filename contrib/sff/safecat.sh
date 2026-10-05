#!/bin/sh

VERSION="1.2.5"
DEFAULT_REMOTE_HOST="singer"

# Extract just the filename from $0 for clean usage printing
SCRIPT_NAME="${0##*/}"

# 1. Handle Version Flags
if test "$1" = "-v" || test "$1" = "-V" || test "$1" = "--version"; then
    echo "safecat version $VERSION"
    exit 0
fi

# 2. Check for Help Flags or Missing Arguments
if test -z "$1" || test "$1" = "-h" || test "$1" = "--help" || test "$1" = "--usage"; then
    # Set output channel: stderr (2) if no arguments, stdout (1) if explicitly requested help
    if test -z "$1"; then
        exec >&2
    fi

    echo "Usage:"
    echo "  Local update:  $SCRIPT_NAME <target_file>"
    echo "  Remote update: $SCRIPT_NAME -R [ssh_host]  (default: $DEFAULT_REMOTE_HOST)"
    echo "  Version check: $SCRIPT_NAME -V"

    if test -z "$1"; then
        exit 1
    fi
    exit 0
fi

# 3. Handle Remote Deployment Flag (-R)
if test "$1" = "-R"; then
    # Look at the next argument for a custom host; otherwise use the default
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

    # Securely stream the local script content into the remote safecat instance
    cat "$SCRIPT_PATH" | ssh "$REMOTE_HOST" "bin/safecat.sh bin/safecat.sh"
    exit $?
fi

TARGET="$1"

# Extract directory using POSIX parameter expansion
TARGET_DIR="${TARGET%/*}"

# Fallback: if no slash was found, target is in the current directory
if test "$TARGET_DIR" = "$TARGET"; then
    TARGET_DIR="."
fi

# Ensure the target directory is actually writable before proceeding
if test ! -w "$TARGET_DIR"; then
    echo "Error: Directory '$TARGET_DIR' is not writable." >&2
    exit 1
fi

# Determine permissions dynamically across Linux & OpenBSD
if test -e "$TARGET"; then
    # Auto-detect stat flavor to get the octal permissions cleanly
    if stat --help >/dev/null 2>&1; then
        # GNU / Linux stat
        PERMS=$(stat -c "%a" "$TARGET")
    else
        # OpenBSD / BSD stat
        PERMS=$(stat -f "%OLp" "$TARGET")
    fi
else
    # Fallback permissions if creating a brand new file
    PERMS="644"
fi

# Create the temp file in the SAME directory using OpenBSD/POSIX compatible syntax
tmp=$(mktemp "$TARGET_DIR/tmp-safecat.XXXXXX")
if test $? -ne 0; then
    echo "Error: Failed to create temporary file." >&2
    exit 1
fi

# Catch unexpected exits or interruptions and clean up the temp file
trap 'test -f "$tmp" && rm -f "$tmp"' EXIT INT TERM

# Read stdin into the temp file
cat > "$tmp"

# Explicitly apply the exact permissions of the replaced original file
chmod "$PERMS" "$tmp"

# Atomically swap the new file into the target destination
mv "$tmp" "$TARGET"
