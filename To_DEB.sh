#!/bin/bash

# Bash to DEB Package Converter
# This script converts a bash script into a Debian package

set -e  # Exit on any error

# Default values
SCRIPT_FILE=""
PACKAGE_NAME=""
VERSION="1.0.0"
DESCRIPTION="Converted bash script"
MAINTAINER="$(whoami) <$(whoami)@localhost>"
DEPENDS=""
INSTALL_PATH="/usr/local/bin"
ARCHITECTURE="all"
SECTION="utils"
PRIORITY="optional"
OUTPUT_DIR="./deb_packages"
TEMP_DIR="/tmp/deb_build_$$"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 -s SCRIPT_FILE -n PACKAGE_NAME [OPTIONS]"
    echo ""
    echo "Required options:"
    echo "  -s, --script FILE        Path to the bash script to convert"
    echo "  -n, --name NAME          Package name (lowercase, no spaces)"
    echo ""
    echo "Optional options:"
    echo "  -v, --version VERSION    Package version (default: 1.0.0)"
    echo "  -d, --description DESC   Package description"
    echo "  -m, --maintainer EMAIL   Maintainer email"
    echo "  -D, --depends DEPS       Dependencies (comma-separated)"
    echo "  -p, --path PATH          Install path (default: /usr/local/bin)"
    echo "  -a, --arch ARCH          Architecture (default: all)"
    echo "  -o, --output DIR         Output directory (default: ./deb_packages)"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -s my_script.sh -n my-package -v 1.2.3 -d 'My awesome script'"
}

# Function to log messages
log() {
    local level=$1
    shift
    local message="$@"
    
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}

# Function to validate package name
validate_package_name() {
    local name=$1
    if [[ ! $name =~ ^[a-z0-9][a-z0-9+.-]*$ ]]; then
        log "ERROR" "Invalid package name. Must be lowercase, start with alphanumeric, and contain only lowercase letters, digits, plus, minus, and periods."
        return 1
    fi
    return 0
}

# Function to check if required tools are installed
check_dependencies() {
    local missing_tools=()
    
    if ! command -v dpkg-deb &> /dev/null; then
        missing_tools+=("dpkg-deb")
    fi
    
    if ! command -v fakeroot &> /dev/null; then
        missing_tools+=("fakeroot")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log "ERROR" "Missing required tools: ${missing_tools[*]}"
        log "INFO" "Install with: sudo apt-get install dpkg-dev fakeroot"
        return 1
    fi
    
    return 0
}

# Function to create DEBIAN directory structure
create_debian_structure() {
    local build_dir=$1
    local debian_dir="$build_dir/DEBIAN"
    
    mkdir -p "$debian_dir"
    mkdir -p "$build_dir$INSTALL_PATH"
    
    # Create control file
    cat > "$debian_dir/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: $SECTION
Priority: $PRIORITY
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

    # Add dependencies if specified
    if [ -n "$DEPENDS" ]; then
        echo "Depends: $DEPENDS" >> "$debian_dir/control"
    fi
    
    # Create postinst script to make the installed script executable
    cat > "$debian_dir/postinst" << 'EOF'
#!/bin/bash
set -e

# Make the installed script executable
chmod +x INSTALL_PATH_PLACEHOLDER/SCRIPT_NAME_PLACEHOLDER

# Update alternatives if installing to a common path
if [ "INSTALL_PATH_PLACEHOLDER" = "/usr/bin" ] || [ "INSTALL_PATH_PLACEHOLDER" = "/usr/local/bin" ]; then
    echo "Script installed to INSTALL_PATH_PLACEHOLDER/SCRIPT_NAME_PLACEHOLDER"
fi

exit 0
EOF

    # Replace placeholders in postinst
    sed -i "s|INSTALL_PATH_PLACEHOLDER|$INSTALL_PATH|g" "$debian_dir/postinst"
    sed -i "s|SCRIPT_NAME_PLACEHOLDER|$PACKAGE_NAME|g" "$debian_dir/postinst"
    
    # Make postinst executable
    chmod 755 "$debian_dir/postinst"
    
    # Create prerm script for cleanup
    cat > "$debian_dir/prerm" << 'EOF'
#!/bin/bash
set -e

# Remove alternatives if they were set
if [ "$1" = "remove" ]; then
    echo "Removing PACKAGE_NAME_PLACEHOLDER..."
fi

exit 0
EOF

    # Replace placeholders in prerm
    sed -i "s|PACKAGE_NAME_PLACEHOLDER|$PACKAGE_NAME|g" "$debian_dir/prerm"
    
    # Make prerm executable
    chmod 755 "$debian_dir/prerm"
}

# Function to copy and prepare the script
prepare_script() {
    local build_dir=$1
    local target_script="$build_dir$INSTALL_PATH/$PACKAGE_NAME"
    
    # Copy the script to the target location
    cp "$SCRIPT_FILE" "$target_script"
    
    # Make sure it's executable
    chmod 755 "$target_script"
    
    # Ensure it has a proper shebang
    if ! head -n 1 "$target_script" | grep -q "^#!"; then
        log "WARNING" "Script doesn't have a shebang. Adding #!/bin/bash"
        sed -i '1i#!/bin/bash' "$target_script"
    fi
}

# Function to build the package
build_package() {
    local build_dir=$1
    local output_file="$OUTPUT_DIR/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # Build the package
    log "INFO" "Building package..."
    fakeroot dpkg-deb --build "$build_dir" "$output_file"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Package created: $output_file"
        
        # Display package info
        log "INFO" "Package information:"
        dpkg-deb --info "$output_file"
        
        return 0
    else
        log "ERROR" "Failed to build package"
        return 1
    fi
}

# Function to cleanup temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--script)
            SCRIPT_FILE="$2"
            shift 2
            ;;
        -n|--name)
            PACKAGE_NAME="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -d|--description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -m|--maintainer)
            MAINTAINER="$2"
            shift 2
            ;;
        -D|--depends)
            DEPENDS="$2"
            shift 2
            ;;
        -p|--path)
            INSTALL_PATH="$2"
            shift 2
            ;;
        -a|--arch)
            ARCHITECTURE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$SCRIPT_FILE" ] || [ -z "$PACKAGE_NAME" ]; then
    log "ERROR" "Missing required parameters"
    usage
    exit 1
fi

# Check if script file exists
if [ ! -f "$SCRIPT_FILE" ]; then
    log "ERROR" "Script file not found: $SCRIPT_FILE"
    exit 1
fi

# Validate package name
if ! validate_package_name "$PACKAGE_NAME"; then
    exit 1
fi

# Check dependencies
if ! check_dependencies; then
    exit 1
fi

# Start the conversion process
log "INFO" "Starting conversion of $SCRIPT_FILE to DEB package..."
log "INFO" "Package name: $PACKAGE_NAME"
log "INFO" "Version: $VERSION"
log "INFO" "Install path: $INSTALL_PATH"

# Create temporary build directory
mkdir -p "$TEMP_DIR"

# Create the debian package structure
log "INFO" "Creating package structure..."
create_debian_structure "$TEMP_DIR"

# Prepare the script
log "INFO" "Preparing script..."
prepare_script "$TEMP_DIR"

# Build the package
if build_package "$TEMP_DIR"; then
    log "SUCCESS" "Conversion completed successfully!"
    log "INFO" "You can install the package with: sudo dpkg -i $OUTPUT_DIR/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
else
    log "ERROR" "Conversion failed!"
    exit 1
fi