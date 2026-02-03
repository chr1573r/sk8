# sk8

A lightweight package manager for [rollerblades](https://github.com/chr1573r/rollerblades).

## Features

- Install, update, and remove packages from a rollerblades server
- Cryptographic signature verification (SHA256)
- apt-style command syntax
- Package index with available/installed status
- Batch upgrade all installed packages

## Quick Start

```bash
# Configure server URL
mkdir -p ~/.sk8
echo 'SK8_RB_URL="https://packages.example.com"' > ~/.sk8/config

# Fetch package index
sk8 update

# List available packages
sk8 list

# Install a package
sk8 install my-tool

# Upgrade all packages
sk8 upgrade
```

## Commands

| Command | Description |
|---------|-------------|
| `sk8 update` | Fetch package index from server |
| `sk8 upgrade` | Upgrade all installed packages |
| `sk8 upgrade <pkg>` | Upgrade a specific package |
| `sk8 install <pkg>` | Install a package |
| `sk8 remove <pkg>` | Remove a package |
| `sk8 reinstall <pkg>` | Remove and reinstall a package |
| `sk8 list` | List available packages |
| `sk8 list --installed` | List installed packages |

## Configuration

Create `~/.sk8/config`:

```bash
# Required: URL of your rollerblades server
SK8_RB_URL="https://packages.example.com"
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SK8_DIR` | Override sk8 directory (default: `~/.sk8`) |
| `SK8_RB_URL` | Rollerblades server URL |

## Directory Structure

```
~/.sk8/
├── config              # Configuration file
├── cache/              # Downloaded packages and signatures
│   ├── packages.txt    # Package index
│   └── rollerblades.pub # Server public key
└── package/            # Installed packages
    ├── my-tool/
    └── another-pkg/
```

## Security

- All packages are verified against the server's public key
- SHA256 signatures are checked before extraction
- Package names are sanitized to prevent path traversal attacks
- Failed verifications automatically clean up cached files

## Examples

### Install and use a package

```bash
# Update index and install
sk8 update
sk8 install my-script

# Package installed to ~/.sk8/package/my-script/
# Add to PATH or symlink as needed
```

### Keep packages updated

```bash
# Check for updates and upgrade all
sk8 update
sk8 upgrade
```

### View what's installed

```bash
sk8 list --installed
```

### View available packages

```bash
sk8 update
sk8 list
# Shows: package-name [installed] for installed packages
```

## Server Setup

sk8 works with any [rollerblades](https://github.com/chr1573r/rollerblades) server.

The server must provide:
- `packages.txt` - Package index
- `<package>.tar.gz` - Package archives
- `<package>.signature` - Package signatures
- `rollerblades.pub` - Public key for verification

## License

GPLv3 License
