#!/bin/sh

VERSION="1.6.1"
DEFAULT_REMOTE_HOST="singer"

SCRIPT_NAME="${0##*/}"

usage() {
    echo "Usage:"
    echo "  Local update:  $SCRIPT_NAME [options] [--] <target_file>"
    echo "  Remote update: $SCRIPT_NAME -R [ssh_host]  \\"
    echo "                 (default: $DEFAULT_REMOTE_HOST)"
    echo "  Version check: $SCRIPT_NAME -V"
    echo ""
    echo "Options:"
    echo "  -a, --append   Append standard input to target atomically"
    echo "  -h, --help     Show this usage screen"
}

# Initialize toggle flag for appending
APPEND_MODE=0

# Loop to parse options flexibly before the target file
while [ $# -gt 0 ]; do
    case "$1" in
        --)
            shift
            break
            ;;
        -a|--append)
            APPEND_MODE=1
            shift
            ;;
        -v*|-V|--version)
            echo "safecat version $VERSION"
            exit 0
            ;;
        -h|--help|--usage)
            usage
            exit 0
            ;;
        -R)
            if [ -n "$2" ] && [ "${2#-}" = "$2" ]; then
                REMOTE_HOST="$2"
                shift 2
            else
                REMOTE_HOST="$DEFAULT_REMOTE_HOST"
                shift 1
            fi

            SCRIPT_PATH="$0"
            if [ ! -f "$SCRIPT_PATH" ]; then
                SCRIPT_PATH=$(command -v "$0" 2>/dev/null)
            fi

            if [ -z "$SCRIPT_PATH" ] || [ ! -f "$SCRIPT_PATH" ]; then
                echo "Error: Could not find local script path." >&2
                exit 1
            fi

            echo "Atomically deploying to remote: $REMOTE_HOST..."
            
            # Pass append flag to remote side if toggled locally
            REMOTE_ARGS="bin/safecat.sh"
            if [ "$APPEND_MODE" -eq 1 ]; then
                REMOTE_ARGS="-a $REMOTE_ARGS"
            fi

            cat "$SCRIPT_PATH" | \
                ssh "$REMOTE_HOST" "bin/safecat.sh $REMOTE_ARGS"
            exit $?
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            echo "Use '$SCRIPT_NAME --help' for usage info." >&2
            exit 1
            ;;
        *)
            # If it doesn't start with a dash, it's our target file
            break
            ;;
    esac
done

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "Error: Missing target file parameter." >&2
    exit 1
fi

# ======================================================================
#                     Atomic File Writing Logic
# ======================================================================

# Recursive symlink resolution loop (POSIX compliant)
# Tracks depth to fail gracefully if there is a circular loop
DEPTH=0
MAX_DEPTH=20

while [ -h "$TARGET" ]; do
    if [ "$DEPTH" -ge "$MAX_DEPTH" ]; then
        echo "Error: Symlink loop detected over $MAX_DEPTH." >&2
        exit 1
    fi

    LINK_TARGET=$(readlink "$TARGET")

    case "$LINK_TARGET" in
        /*)
            # Absolute target: assign directly
            TARGET="$LINK_TARGET"
            ;;
        *)
            # Relative target: resolve against current directory
            LINK_DIR="${TARGET%/*}"
            if [ "$LINK_DIR" = "$TARGET" ]; then
                LINK_DIR="."
            fi
            TARGET="$LINK_DIR/$LINK_TARGET"
            ;;
    esac

    DEPTH=$((DEPTH + 1))
done

# Extract directory using POSIX parameter expansion
TARGET_DIR="${TARGET%/*}"
if [ "$TARGET_DIR" = "$TARGET" ]; then
    TARGET_DIR="."
fi

if [ ! -w "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' is not writable." >&2
    exit 1
fi

# Track if we are running as root (UID 0) to handle ownership
IS_ROOT=0
[ "$(id -u 2>/dev/null)" = "0" ] && IS_ROOT=1

OWNER=""
GROUP=""

if [ -e "$TARGET" ]; then
    if [ ! -w "$TARGET" ]; then
        echo "Error: Target file '$TARGET' is not writable." >&2
        exit 1
    fi

    # Cross-platform permission, owner, and group extraction
    if stat --help >/dev/null 2>&1; then
        # GNU / Linux stat
        PERMS=$(stat -c "%a" "$TARGET")
        [ "$IS_ROOT" -eq 1 ] && OWNER=$(stat -c "%u" "$TARGET")
        [ "$IS_ROOT" -eq 1 ] && GROUP=$(stat -c "%g" "$TARGET")
    else
        # OpenBSD / BSD stat
        PERMS=$(stat -f "%OLp" "$TARGET")
        [ "$IS_ROOT" -eq 1 ] && OWNER=$(stat -f "%u" "$TARGET")
        [ "$IS_ROOT" -eq 1 ] && GROUP=$(stat -f "%g" "$TARGET")
    fi
else
    # Fallback permissions if creating a brand new file
    PERMS="644"
fi

# Create the temp file in the SAME directory
tmp=$(mktemp "$TARGET_DIR/tmp-safecat.XXXXXX")
if [ $? -ne 0 ] || [ -z "$tmp" ]; then
    echo "Error: Failed to create temporary file." >&2
    exit 1
fi

# Catch unexpected exits or interruptions and clean up the temp file
trap 'EXIT_STATUS=$?; rm -f "$tmp"; exit $EXIT_STATUS' EXIT
trap 'exit 1' INT TERM HUP

# Atomic Append Setup
# If append mode is active, copy current data to temp file first
if [ "$APPEND_MODE" -eq 1 ] && [ -f "$TARGET" ]; then
    if ! cat "$TARGET" > "$tmp"; then
        echo "Error: Failed to read original file for appending." >&2
        exit 1
    fi
fi

# Stream standard input into the staging file
if ! cat >> "$tmp"; then
    echo "Error: Failed writing input to temporary file." >&2
    exit 1
fi

# Apply the exact permissions of the replaced original file
chmod "$PERMS" "$tmp"

# Preserve original ownership parameters if executing as Root
if [ "$IS_ROOT" -eq 1 ] && [ -n "$OWNER" ] && [ -n "$GROUP" ]; then
    if ! chown "$OWNER:$GROUP" "$tmp" 2>/dev/null; then
        echo "Warning: Could not restore ownership ($OWNER:$GROUP)." >&2
    fi
fi

# Atomically swap the completed staging file into place
if ! mv "$tmp" "$TARGET"; then
    echo "Error: Atomic swap failed." >&2
    exit 1
fi
