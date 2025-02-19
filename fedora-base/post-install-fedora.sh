#!/bin/bash

# Determine the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the full paths to the source files
DNF_PACKAGES="$SCRIPT_DIR/fedora-base/packages/dnf-packages.sh"
FLATPAKS="$SCRIPT_DIR/fedora-base/packages/flatpaks.sh"
SNAPS="$SCRIPT_DIR/fedora-base/packages/snaps.sh"
FILES="$SCRIPT_DIR/fedora-base/packages/download-files.sh"
FONTS="$SCRIPT_DIR/fedora-base/packages/fonts.sh"

# Check if source files exist before sourcing
for file in "$DNF_PACKAGES" "$FLATPAKS" "$SNAPS" "$FILES" "$FONTS"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: $file not found. Exiting." 1>&2
        exit 1
    fi
done

# Source the files
source "$DNF_PACKAGES"
source "$FLATPAKS"
source "$SNAPS"
source "$FILES"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./post-install-fedora.sh" 2>&1
  exit 1
fi

# Log file
LOG_FILE="/var/log/install_log.txt"
exec > >(tee -i "$LOG_FILE")
exec 2>&1

# Main script execution
echo -e "\n========================================================================="
echo "For troubleshooting, the log file can be found in /var/log/install_log.txt"
echo "========================================================================="
# Update System
echo -e "\nUpdating System..."
read -p "Proceed with system update and upgrade?(Y/n): " confirm
confirm=${confirm:-y}

[[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "Skipping system update."; exit 0; }

# Attempt system upgrade
dnf upgrade -y || echo "System upgrade failed, but proceeding with installations..."
echo "System update and upgrade completed successfully."

# User confirmation
read -p "Proceed to installations?(Y/n): " confirm
confirm=${confirm:-y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# Calling functions
install_dnf_packages
install_flatpaks
install_snaps
download_files
source "$FONTS"

# Ensure curl is installed before using it
if ! command -v curl &> /dev/null; then  # Check for curl
  echo "Curl is required but not installed. Installing curl..."
  dnf install curl -y
fi

# Starship
curl -sS https://starship.rs/install.sh | sh

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

echo -e "\nSetting up git configs..."

# Prompt the user for Git user details
read -p "Enter your Git user name (e.g., John Doe): " GIT_USER_NAME
read -p "Enter your Git email (e.g., test@email.com): " GIT_USER_EMAIL
read -p "Enter your default Git branch (e.g., main): " GIT_DEFAULT_BRANCH
read -p "Enter your preferred Git editor (e.g., vim): " GIT_EDITOR

# List of configurations to set
declare -A git_configs=(
    ["user.name"]="$GIT_USER_NAME"
    ["user.email"]="$GIT_USER_EMAIL"
    ["init.defaultBranch"]="$GIT_DEFAULT_BRANCH"
    ["core.editor"]="$GIT_EDITOR"
    ["color.ui"]="auto"
)

# Apply configurations using a loop
for config in "${!git_configs[@]}"; do
    git config --global "$config" "${git_configs[$config]}"
done

# Verify the applied git configs
git config --list

# Cleanup
echo -e "\nCleaning up..."
#dnf autoremove -y
#dnf clean

echo -e "\nAll installations are complete."
# Log File
echo -e "\nThe log file can be found in /var/log/install_log.txt for review"
