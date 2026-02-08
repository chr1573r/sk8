#!/bin/sh
# sk8 installer - downloads sk8 package manager
#
# Usage:
#   curl -sSf https://raw.githubusercontent.com/chr1573r/sk8/main/install.sh | sh
#   curl -sSf <url> | sh -s -- /custom/install/dir
#
# Environment variables:
#   SK8_DOWNLOAD_URL  Override download URL (for self-hosted setups)

set -e

SK8_INSTALL_DIR="${1:-$HOME/.local/bin}"
SK8_URL="${SK8_DOWNLOAD_URL:-https://raw.githubusercontent.com/chr1573r/sk8/main/sk8}"

echo "sk8 installer"
echo "============="
echo ""

# Create install directory
if [ ! -d "$SK8_INSTALL_DIR" ]; then
    echo "Creating directory: $SK8_INSTALL_DIR"
    mkdir -p "$SK8_INSTALL_DIR"
fi

# Download sk8
echo "Downloading sk8 to $SK8_INSTALL_DIR/sk8..."
if command -v curl >/dev/null 2>&1; then
    curl -sSf "$SK8_URL" -o "$SK8_INSTALL_DIR/sk8"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$SK8_INSTALL_DIR/sk8" "$SK8_URL"
else
    echo "Error: Neither curl nor wget found. Install one and try again." >&2
    exit 1
fi

chmod +x "$SK8_INSTALL_DIR/sk8"

echo ""
echo "sk8 installed to: $SK8_INSTALL_DIR/sk8"

# Check if install dir is in PATH
case ":$PATH:" in
    *":$SK8_INSTALL_DIR:"*) ;;
    *)
        echo ""
        echo "NOTE: $SK8_INSTALL_DIR is not in your PATH."
        echo "Add it by appending this to your shell profile (~/.bashrc or ~/.zshrc):"
        echo ""
        echo "  export PATH=\"$SK8_INSTALL_DIR:\$PATH\""
        ;;
esac

echo ""
echo "Next steps:"
echo "  sk8                          # Interactive setup"
echo "  SK8_RB_URL=<url> sk8 list    # Auto-setup with server URL"
echo ""
