# Bash to DEB Package Converter

A comprehensive bash script that automatically converts any bash script into a proper Debian package (.deb) with all necessary metadata and installation scripts.

## 🚀 Features

- **Automatic DEB package creation** from bash scripts
- **Proper Debian package structure** with control files
- **Flexible installation paths** and package configuration
- **Dependency management** support
- **Post-installation scripts** for proper setup
- **Input validation** and error handling
- **Colored output** for better user experience
- **Clean temporary file management**

## 📋 Prerequisites

Before using this script, ensure you have the required tools installed:

```bash
sudo apt-get install dpkg-dev fakeroot
```

## 🔧 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/bash-to-deb-converter.git
cd bash-to-deb-converter
```

2. Make the script executable:
```bash
chmod +x bash_to_deb.sh
```

## 📖 Usage

### Basic Usage

```bash
./bash_to_deb.sh -s your_script.sh -n package-name
```

### Advanced Usage

```bash
./bash_to_deb.sh -s backup_tool.sh -n backup-tool \
  -v 2.1.0 \
  -d "Automated backup utility for system files" \
  -m "Your Name <your.email@example.com>" \
  -D "rsync, gzip, tar" \
  -p "/usr/bin" \
  -a "amd64" \
  -o "./packages"
```

### Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--script` | `-s` | **Required.** Path to the bash script to convert | - |
| `--name` | `-n` | **Required.** Package name (lowercase, no spaces) | - |
| `--version` | `-v` | Package version | `1.0.0` |
| `--description` | `-d` | Package description | `"Converted bash script"` |
| `--maintainer` | `-m` | Maintainer email | `"$(whoami) <$(whoami)@localhost>"` |
| `--depends` | `-D` | Dependencies (comma-separated) | - |
| `--path` | `-p` | Install path for the script | `/usr/local/bin` |
| `--arch` | `-a` | Target architecture | `all` |
| `--output` | `-o` | Output directory for .deb file | `./deb_packages` |
| `--help` | `-h` | Show help message | - |

## 📁 Package Structure

The script creates a proper Debian package with the following structure:

```
package_name_version_arch.deb
├── DEBIAN/
│   ├── control          # Package metadata
│   ├── postinst         # Post-installation script
│   └── prerm            # Pre-removal script
└── usr/local/bin/       # Default install location
    └── package-name     # Your converted script
```

## 🎯 Examples

### Example 1: Simple Script Conversion

```bash
# Convert a backup script
./bash_to_deb.sh -s backup.sh -n my-backup-tool
```

**Output:** `./deb_packages/my-backup-tool_1.0.0_all.deb`

### Example 2: Production-Ready Package

```bash
# Create a production package with full metadata
./bash_to_deb.sh \
  -s system-monitor.sh \
  -n system-monitor \
  -v 1.2.3 \
  -d "Real-time system monitoring tool with alerts" \
  -m "DevOps Team <devops@company.com>" \
  -D "curl, jq, bc" \
  -p "/usr/bin" \
  -a "amd64"
```

**Output:** `./deb_packages/system-monitor_1.2.3_amd64.deb`

### Example 3: Custom Installation Path

```bash
# Install to a custom location
./bash_to_deb.sh \
  -s admin-tools.sh \
  -n admin-tools \
  -p "/opt/admin/bin" \
  -d "Administrative utilities collection"
```

## 📦 Installing the Generated Package

Once your DEB package is created, install it using:

```bash
# Install the package
sudo dpkg -i ./deb_packages/package-name_version_arch.deb

# Install dependencies if needed
sudo apt-get install -f
```

## 🗑️ Removing the Package

```bash
# Remove the package
sudo dpkg -r package-name

# Remove package and configuration files
sudo dpkg --purge package-name
```

## ✅ Package Validation

The script performs several validation checks:

- **Package name format** - Ensures Debian naming conventions
- **Script existence** - Verifies the source script exists
- **Required tools** - Checks for `dpkg-deb` and `fakeroot`
- **Shebang presence** - Adds `#!/bin/bash` if missing
- **File permissions** - Sets proper executable permissions

## 🔍 Package Information

After creation, you can inspect your package:

```bash
# View package information
dpkg-deb --info package-name_version_arch.deb

# List package contents
dpkg-deb --contents package-name_version_arch.deb

# Extract package contents
dpkg-deb --extract package-name_version_arch.deb extracted/
```

## 🐛 Troubleshooting

### Common Issues

1. **"Missing required tools"**
   ```bash
   sudo apt-get install dpkg-dev fakeroot
   ```

2. **"Invalid package name"**
   - Package names must be lowercase
   - Use hyphens instead of spaces
   - Start with alphanumeric characters

3. **"Permission denied"**
   ```bash
   chmod +x bash_to_deb.sh
   ```

4. **"Script file not found"**
   - Check the path to your bash script
   - Ensure the file exists and is readable

### Debug Mode

For troubleshooting, you can check the temporary build directory before cleanup by modifying the script to comment out the cleanup trap.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Debian packaging guidelines and best practices
- The Debian maintainer community for documentation
- Contributors to the dpkg-deb toolchain

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/bash-to-deb-converter/issues) section
2. Create a new issue with detailed information
3. Include your system information and the exact command used

---

**Made with ❤️ for the Linux community**