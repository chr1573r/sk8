# sk8

A lightweight package manager for [rollerblades](https://github.com/chr1573r/rollerblades).

## Installation

One-liner install:

```bash
curl -sSf https://raw.githubusercontent.com/chr1573r/sk8/main/install.sh | sh
```

Or install to a custom directory:

```bash
curl -sSf https://raw.githubusercontent.com/chr1573r/sk8/main/install.sh | sh -s -- /usr/local/bin
```

## Features

- Install, update, and remove packages from a rollerblades server
- Cryptographic signature verification (SHA256)
- apt-style command syntax
- Package index with available/installed status
- Batch upgrade all installed packages
- Package manifest support (`sk8.manifest`) for executable linking and setup scripts
- Automatic symlinking of package executables with conflict detection
- Version tracking for installed packages
- Non-interactive setup via environment variables

## Quick Start

### Interactive setup

```bash
sk8
# Follow the prompts to enter your server URL and trust the key
```

### Non-interactive setup (CI/scripting)

```bash
# Auto-configure with server URL from environment variable
SK8_RB_URL=https://packages.example.com sk8 list
```

When `SK8_RB_URL` is set and no config exists, sk8 will:
- Download and trust the server's public key automatically
- Display a warning with the key fingerprint for verification
- Save the configuration for future use

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
| `sk8 setup <pkg>` | Run a package's setup wizard |
| `sk8 update` | Fetch package index from server |
| `sk8 upgrade` | Upgrade all installed packages |
| `sk8 upgrade <pkg>` | Upgrade a specific package |
| `sk8 install <pkg>` | Install a package |
| `sk8 remove <pkg>` | Remove a package |
| `sk8 reinstall <pkg>` | Remove and reinstall a package |
| `sk8 list` | List available packages (with versions) |
| `sk8 list --installed` | List installed packages (with versions) |

## Configuration

Create `~/.sk8/config`:

```bash
# Required: URL of your rollerblades server
SK8_RB_URL="https://packages.example.com"

# Optional: where to symlink package executables (default: ~/.local/bin)
SK8_BIN_DIR="/home/user/.local/bin"
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SK8_DIR` | Override sk8 directory (default: `~/.sk8`) |
| `SK8_RB_URL` | Rollerblades server URL. If set when no config exists, triggers auto-setup. |
| `SK8_BIN_DIR` | Directory for executable symlinks (default: `~/.local/bin`) |

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

## Package Manifest

Packages can include a `sk8.manifest` file in their repository root to declare executables, version info, and setup scripts. The manifest is optional -- packages without one work exactly as before.

### Manifest Format

```
# sk8 package manifest
NAME=My Tool
VERSION=1.0.0
DESCRIPTION=A useful command-line tool
EXECUTABLE=my-tool
EXTRA_BINARIES=bin/helper bin/converter
SETUP=setup.sh
SETUP_ON_UPGRADE=false
```

### Manifest Fields

| Field | Required | Description |
|-------|----------|-------------|
| `NAME` | No | Display name (max 128 chars) |
| `VERSION` | No | Version string, e.g. `1.2.3` |
| `DESCRIPTION` | No | Short description (max 256 chars) |
| `EXECUTABLE` | No | Path to main executable (relative to package root) |
| `EXTRA_BINARIES` | No | Space-separated additional executables to link |
| `SETUP` | No | Path to interactive setup script (relative to package root) |
| `SETUP_ON_UPGRADE` | No | Run setup on upgrade too? `true` or `false` (default: `false`) |

### Executable Linking

When a package has `EXECUTABLE` (and optionally `EXTRA_BINARIES`) in its manifest, sk8 automatically creates symlinks in your configured bin directory (default `~/.local/bin/`).

- Symlinks are created on install, re-created on upgrade, and removed on uninstall
- Before creating a symlink, sk8 checks for conflicts with existing files in the bin directory and other commands in PATH
- If a conflict is found in the bin directory, the symlink is skipped with a warning
- If the same command exists elsewhere in PATH, a note is printed but the symlink is still created

### Setup Scripts

Packages can include a setup/configuration script that runs after installation:

- On install: sk8 prompts `Run setup? [y/n]` (only in interactive terminals)
- On upgrade: only prompted if `SETUP_ON_UPGRADE=true`
- Non-interactive installs (piped stdin) skip setup silently
- Run `sk8 setup <package>` at any time to re-run the setup wizard

### Version Tracking

When a manifest includes `VERSION`, sk8 tracks the installed version:

- `sk8 list` shows `package [installed: 1.0.0]`
- `sk8 list --installed` shows `package (1.0.0)`
- `sk8 upgrade` shows version changes: `package upgraded (1.0.0 -> 1.1.0)`

## Security

- **Trust on first use**: On first run, sk8 shows the server's key fingerprint and asks you to verify
- **Auto-setup trust**: When using `SK8_RB_URL` env var, the key is trusted automatically with a prominent fingerprint warning. Verify the fingerprint with your server administrator.
- All packages are verified against the server's public key (SHA256)
- Package names are sanitized to prevent path traversal attacks
- Failed verifications automatically clean up cached files
- Server messages (MOTD) are sanitized to prevent terminal escape attacks
- Package manifests are parsed line-by-line (never sourced as shell code)
- Manifest paths are validated against traversal attacks and shell metacharacters
- Symlink conflicts are detected to prevent overwriting existing commands
- Setup scripts require explicit user consent before running
- Run `sk8 setup` to reconfigure and trust a different server

## Server Messages

If the rollerblades server provides a `motd.txt`, sk8 will display it:
- During setup (shows server's welcome message)
- When running `sk8 update`

All server-provided content is sanitized (ANSI escapes removed, length limited) for security.

## Examples

### Install and use a package

```bash
# Install directly (index is fetched automatically if needed)
sk8 install my-script

# If the package has a sk8.manifest with EXECUTABLE,
# the binary is automatically symlinked to ~/.local/bin/
# Otherwise, the package is at ~/.sk8/package/my-script/
```

### Keep packages updated

```bash
sk8 update
sk8 upgrade
```

### Bootstrap in a script

```bash
# Non-interactive: set URL and install in one go
export SK8_RB_URL=https://packages.example.com
sk8 install my-tool
sk8 install another-tool
```

### View what's installed

```bash
sk8 list --installed
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
