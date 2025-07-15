# Bash to DEB Package Converter

A utility script that converts bash scripts into Debian (.deb) packages for easy installation and distribution.

## Features

- 🚀 Convert any bash script to a proper Debian package
- 📦 Automatic package structure generation
- 🔧 Configurable installation paths and metadata
- 🎯 Smart script naming (separates package name from script name)
- ✨ Proper dependency handling
- 🧹 Clean uninstallation support
- 🎨 Colorized output for better user experience

## Prerequisites

Install the required tools:

```bash
sudo apt-get install dpkg-dev fakeroot
```

## Usage

### Basic Usage

```bash
./To_DEB.sh -s script.sh -n package-name
```

### Full Example

```bash
./To_DEB.sh \
  -s fakeap.sh \
  -n fakeap-tool \
  -v 2.1.0 \
  -d "WiFi Access Point creation tool" \
  -m "user@example.com" \
  -S fakeap
```

This creates a package named `fakeap-tool` that installs a script named `fakeap`.

## Command Line Options

### Required Options

| Option | Description |
|--------|-------------|
| `-s, --script FILE` | Path to the bash script to convert |
| `-n, --name NAME` | Package name (lowercase, no spaces) |

### Optional Options

| Option | Description | Default |
|--------|-------------|---------|
| `-v, --version VERSION` | Package version | `1.0.0` |
| `-d, --description DESC` | Package description | `"Converted bash script"` |
| `-m, --maintainer EMAIL` | Maintainer email | `"$(whoami) <$(whoami)@localhost>"` |
| `-D, --depends DEPS` | Dependencies (comma-separated) | None |
| `-p, --path PATH` | Install path | `/usr/local/bin` |
| `-a, --arch ARCH` | Architecture | `all` |
| `-o, --output DIR` | Output directory | `./deb_packages` |
| `-S, --script-name NAME` | Name for installed script | Auto-derived from package name |
| `-h, --help` | Show help message | - |

## Smart Script Naming

The script automatically derives clean script names from package names:

- `fakeap.deb` → `fakeap`
- `my-tool.deb` → `my-tool`
- `awesome-script` → `awesome-script`
- `network-tool` → `network` (removes `-tool` suffix)

You can override this with the `-S` option:

```bash
./To_DEB.sh -s script.sh -n complex-package-name -S simple-name
```

## Package Installation

After creating the package:

```bash
# Install the package
sudo dpkg -i ./deb_packages/package-name_1.0.0_all.deb

# Run your script
script-name

# Remove the package
sudo dpkg -r package-name
```

## Examples

### Simple Conversion

```bash
./To_DEB.sh -s backup.sh -n backup-tool
```

Creates: `backup-tool_1.0.0_all.deb`, installs script as `backup`

### Advanced Configuration

```bash
./To_DEB.sh \
  -s monitoring.sh \
  -n system-monitor \
  -v 3.2.1 \
  -d "System monitoring utility" \
  -m "admin@company.com" \
  -D "curl,jq,systemd" \
  -p "/usr/bin" \
  -S sysmon
```

Creates: `system-monitor_3.2.1_all.deb`, installs script as `sysmon` in `/usr/bin`

### Network Tool Example

```bash
./To_DEB.sh \
  -s fakeap.sh \
  -n fakeap \
  -v 1.5.0 \
  -d "Create fake WiFi access points for testing" \
  -m "security@example.com" \
  -D "hostapd,dnsmasq"
```

## Package Structure

Generated packages include:

- **Control file**: Package metadata and dependencies
- **Postinst script**: Makes installed script executable
- **Prerm script**: Cleanup during removal
- **Your script**: Installed to specified path

## Validation

The script validates:

- ✅ Package name format (lowercase, alphanumeric + `-`, `.`, `+`)
- ✅ Script file existence
- ✅ Required tools availability
- ✅ Proper shebang in script (adds if missing)

## Troubleshooting

### Common Issues

**Missing tools error:**
```bash
sudo apt-get install dpkg-dev fakeroot
```

**Permission denied:**
```bash
chmod +x To_DEB.sh
```

**Invalid package name:**
- Use lowercase letters only
- No spaces or special characters except `-`, `.`, `+`
- Must start with alphanumeric character

### Package Information

View package details:
```bash
dpkg-deb --info package.deb
dpkg-deb --contents package.deb
```

## Output

The script provides colorized output:

- 🔵 **INFO**: General information
- 🟢 **SUCCESS**: Operations completed successfully
- 🟡 **WARNING**: Non-critical issues
- 🔴 **ERROR**: Critical errors

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with various scripts
5. Submit a pull request

## License

This project is open source. Feel free to modify and distribute.