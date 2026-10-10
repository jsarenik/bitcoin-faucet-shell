#!/bin/sh

VERSION="1.4.2"
DEFAULT_REMOTE_HOST="singer"

# Extract just the filename from $0 for clean usage printing
SCRIPT_NAME="${0##*/}"

# Main routing based on the first argument
case "$1" in
    -*)
        # 1. First-level dash check: Route known option flags
        case "$1" in
            -v*|-V|--version)
                echo "safecat version $VERSION"
                exit 0
                ;;
            -h|--help|--usage)
                echo "Usage:"
                echo "  Local update:  $SCRIPT_NAME <target_file>"
                echo "  Remote update: $SCRIPT_NAME -R [ssh_host]  (default: $DEFAULT_REMOTE_HOST)"
                echo "  Version check: $SCRIPT_NAME -V"
                exit 0
                ;;
            -R)
                # Handle Remote Deployment Flag (-R)
                if [ -n "$2" ]; then
                    REMOTE_HOST="$2"
                else
                    REMOTE_HOST="$DEFAULT_REMOTE_HOST"
                fi

                # Find where this running script lives so we can read it
                SCRIPT_PATH="$0"
                if [ ! -f "$SCRIPT_PATH" ]; then
                    SCRIPT_PATH=$(which "$0" 2>/dev/null)
                fi

                if [ -z "$SCRIPT_PATH" ] || [ ! -f "$SCRIPT_PATH" ]; then
                    echo "Error: Could not determine the local script path for streaming." >&2
                    exit 1
                fi

                echo "Atomically deploying script to remote host: $REMOTE_HOST..."

                # Securely stream the local script content into the remote safecat instance
                cat "$SCRIPT_PATH" | ssh "$REMOTE_HOST" "bin/safecat.sh bin/safecat.sh"
                exit $?
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Use '$SCRIPT_NAME --help' for usage info." >&2
                exit 1
                ;;
        esac
        ;;
    "")
        # 2. Missing Argument Handling (Emulates original logic when $1 is empty)
        exec >&2
        echo "Usage:"
        echo "  Local update:  $SCRIPT_NAME <target_file>"
        echo "  Remote update: $SCRIPT_NAME -R [ssh_host]  (default: $DEFAULT_REMOTE_HOST)"
        echo "  Version check: $SCRIPT_NAME -V"
        exit 1
        ;;
    *)
        # 3. Path falls through here directly if first letter is NOT a dash (-)
        TARGET="$1"
        ;;
esac

# ==============================================================================
# Atomic File Writing Logic (Completely skipped if $1 started with a dash)
# ==============================================================================

# Recursive symlink resolution loop (POSIX compliant)
# Tracks depth to fail gracefully if there is a circular reference loop
DEPTH=0
MAX_DEPTH=20

while [ -h "$TARGET" ]; do
    if [ "$DEPTH" -ge "$MAX_DEPTH" ]; then
        echo "Error: Symlink loop detected or depth exceeded $MAX_DEPTH paths." >&2
        exit 1
    fi

    # Read the direct destination of the current symlink
    LINK_TARGET=$(readlink "$TARGET")

    case "$LINK_TARGET" in
        /*)
            # Absolute target: assign directly
            TARGET="$LINK_TARGET"
            ;;
        *)
            # Relative target: resolve relative to the current link's directory context
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

# Fallback: if no slash was found, target is in the current directory
if [ "$TARGET_DIR" = "$TARGET" ]; then
    TARGET_DIR="."
fi

# Ensure the target directory is actually writable before proceeding
if [ ! -w "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' is not writable." >&2
    exit 1
fi

# Determine permissions dynamically across Linux & OpenBSD
if [ -e "$TARGET" ]; then
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
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary file." >&2
    exit 1
fi

# Catch unexpected exits or interruptions and clean up the temp file
trap '[ -f "$tmp" ] && rm -f "$tmp"' EXIT INT TERM

# Read stdin into the temp file
cat > "$tmp"

# Explicitly apply the exact permissions of the replaced original file
chmod "$PERMS" "$tmp"

# Atomically swap the new file into the target destination
mv "$tmp" "$TARGET"
