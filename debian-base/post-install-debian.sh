#!/bin/bash

# Determine the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the full paths to the source files
APT_PACKAGES="$SCRIPT_DIR/debian-base/packages/apt-packages.sh"
FLATPAKS="$SCRIPT_DIR/debian-base/packages/flatpaks.sh"
SNAPS="$SCRIPT_DIR/debian-base/packages/snaps.sh"
FILES="$SCRIPT_DIR/debian-base/packages/download-files.sh"
FONTS="$SCRIPT_DIR/debian-base/packages/fonts.sh"

# Check if source files exist before sourcing
for file in "$APT_PACKAGES" "$FLATPAKS" "$SNAPS" "$FILES" "$FONTS"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: $file not found. Exiting." 1>&2
        exit 1
    fi
done

# Source the files
source "$APT_PACKAGES"
source "$FLATPAKS"
source "$SNAPS"
source "$FILES"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./post-instal-debian.sh" 2>&1
  exit 1
fi

# Ensure non-interactive apt installs (for automated environments)
export DEBIAN_FRONTEND=noninteractive  # Ensures no prompts during package installation

username=$(id -u -n 1000)
builddir=$(pwd)

# Log file
LOG_FILE="/var/log/install_log.txt"
exec > >(tee -i "$LOG_FILE")
exec 2>&1

# Main script execution
echo -e "\n========================================================================="
echo "For troubleshooting, the log file can be found in /var/log/install_log.txt"
echo "========================================================================="
# Update System
echo "Updating System..."
read -p "Proceed with system update and upgrade?(Y/n): " confirm
confirm=${confirm:-y}
[[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "Skipping system update."; exit 0; }

# Attempt system update
apt update || { echo "System update failed. Skipping upgrade."; exit 1; }

# Attempt system upgrade
apt upgrade -y || echo "System upgrade failed. Continuing with installations..."

echo "System update and upgrade completed successfully."

# User confirmation
read -p "Proceed to installations?(Y/n): " confirm
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
source "$FONTS"

# Ensure curl is installed before using it
if ! command -v curl &> /dev/null; then  # Check for curl
  echo "Curl is required but not installed. Installing curl..."
  apt install curl -y
fi

# Starship
curl -sS https://starship.rs/install.sh | sh

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Cleanup
echo "Cleaning up..."
apt autoremove -y
apt clean

echo -e "\nAll installations are complete."
# Log File
echo -e "\nThe log file can be found in /var/log/install_log.txt for review"
