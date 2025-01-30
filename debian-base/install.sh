#!/bin/bash

# Determine the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the full paths to the source files
APT_PACKAGES="$SCRIPT_DIR/packages/apt-packages.sh"
FLATPAKS="$SCRIPT_DIR/packages/flatpaks.sh"
SNAPS="$SCRIPT_DIR/packages/snaps.sh"

# Check if source files exist before sourcing
for file in "$APT_PACKAGES" "$FLATPAKS" "$SNAPS"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: $file not found. Exiting." 1>&2
        exit 1
    fi
done

# Source the files
source "$APT_PACKAGES"
source "$FLATPAKS"
source "$SNAPS"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Ensure non-interactive apt installs (for automated environments)
export DEBIAN_FRONTEND=noninteractive  # Ensures no prompts during package installation

# Log file
LOG_FILE="/var/log/install_log.txt"
exec > >(tee -i "$LOG_FILE")
exec 2>&1

# Downloading files
web_files=(
	###	Programming
	"https://github.com/usebruno/bruno/releases/download/v1.38.1/bruno_1.38.1_x86_64_linux.AppImage"
)

# Function to download files
download_files() {
	if ! command -v wget &> /dev/null; then
    echo "wget is required but not installed. Aborting."
    exit 1
	fi
	echo "Downloading files..."
	for webfile in "${web_files[@]}"; do
		echo "===== Downloading $webfile ..."
		wget "$webfile" -O "$(basename "$webfile")"
		if [ $? -eq 0 ]; then
            echo "Download successful: $webfile"
        else
            echo "Download failed: $webfile"
        fi
    done
}

# Main script execution
# Update System
echo "Updating System..."
read -p "Proceed with system update and upgrade? (Y/n): " confirm
confirm=${confirm:-y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Skipping system update."
else
    if ! apt update; then
        echo "System update failed. Skipping upgrade."
    else
        if ! apt upgrade -y; then
            echo "System upgrade failed. Continuing with installations..."
        else
            echo "System update and upgrade completed successfully."
        fi
    fi
fi

# User confirmation
read -p "Proceed to installations? (Y/n): " confirm
confirm=${confirm:-y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# Calling functions
install_apt_packages
install_flatpaks
install_snaps
download_files

# Ensure curl is installed before using it
if ! command -v curl &> /dev/null; then  # Check for curl
  echo "Curl is required but not installed. Installing curl..."
  apt install curl -y
fi
# Starship
curl -sS https://starship.rs/install.sh | sh

# Cleanup
echo "Cleaning up..."
apt autoremove -y
apt clean

echo "All installations are complete."
# Log File
echo "The log file can be found in /var/log/install_log.txt)"
