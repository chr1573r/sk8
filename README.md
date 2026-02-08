# sk8

A lightweight package manager for [rollerblades](https://github.com/chr1573r/rollerblades).

## Features

- Install, update, and remove packages from a rollerblades server
- Cryptographic signature verification (SHA256)
- apt-style command syntax
- Package index with available/installed status
- Batch upgrade all installed packages

## Quick Start

Just run sk8 - it will guide you through setup:

```bash
$ sk8

Welcome to sk8 - package manager for rollerblades
==================================================

No configuration found. Let's set things up!

Enter rollerblades server URL: https://packages.example.com

Connecting to https://packages.example.com...

Server found!

  URL:         https://packages.example.com
  Packages:    5 available
  Key SHA256:  a1b2c3d4e5f6g7h8...i9j0k1l2m3n4o5p6

The authenticity of this server cannot be established.
Do you want to trust this server? (yes/no): yes

Setup complete!
```

Then use sk8 normally:

```bash
sk8 list              # Show available packages
sk8 install my-tool   # Install a package
sk8 upgrade           # Upgrade all packages
```

## Commands

| Command | Description |
|---------|-------------|
| `sk8 setup` | Interactive setup wizard |
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
│   ├── motd.txt        # Server message (if provided)
│   └── rollerblades.pub # Server public key
└── package/            # Installed packages
    ├── my-tool/
    └── another-pkg/
```

## Security

- **Trust on first use**: On first run, sk8 shows the server's key fingerprint and asks you to verify
- All packages are verified against the server's public key (SHA256)
- Package names are sanitized to prevent path traversal attacks
- Failed verifications automatically clean up cached files
- Server messages (MOTD) are sanitized to prevent terminal escape attacks
- Run `sk8 setup` to reconfigure and trust a different server

## Server Messages

If the rollerblades server provides a `motd.txt`, sk8 will display it:
- During setup (shows server's welcome message)
- When running `sk8 update` or `sk8 list`

All server-provided content is sanitized (ANSI escapes removed, length limited) for security.

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
