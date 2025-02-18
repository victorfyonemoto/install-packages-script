#!/bin/bash

# Fonts
NerdFontUrls=(
	"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
	"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraMono.zip"
	"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip"
	 "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
)

# Determine the original user's home directory when running as root
USER_HOME="${SUDO_USER:-$USER}"

# Set up directories in the user's home directory
DOWNLOAD_DIR="/home/$USER_HOME/tmp/nerd-fonts"

# User's font installation directory (for Linux, this is ~/.local/share/fonts)
INSTALL_DIR="/usr/share/fonts"

# Ensure necessary directories exist
mkdir -p "$DOWNLOAD_DIR" || { echo "Failed to create download directory"; exit 1; }
mkdir -p "$INSTALL_DIR" || { echo "Failed to create install directory"; exit 1; }

# Ensure necessary tools are installed
command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed"; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "unzip is required but not installed"; exit 1; }

# Function to download, extract, and move fonts
download_and_install_font() {
	local font_file
	local font_family
	local font_zip

	# Assign values
	font_file=$(basename "$url")
	font_family=$(echo "$font_file" | cut -d'.' -f1)
	font_zip="$DOWNLOAD_DIR/$font_file"

	echo "Downloading font: $url"
	if ! wget -q "$url" -O "$font_zip"; then
		echo "Error: Failed to download $url"
		return 1
	fi

	echo "Extracting font: $font_file"
	# Create a temporary directory specific to this font family
	local family_dir="$DOWNLOAD_DIR/$font_family"

	# Ensure the family directory exists
	mkdir -p "$family_dir"

	# Automatically overwrite existing files without asking
	if ! unzip -qo "$font_zip" -d "$family_dir"; then
		echo "Error: Failed to extract $font_file"
		return 1
	fi

	echo "Moving font family '$font_family' to $INSTALL_DIR"
	# Move the entire family folder to the installation directory
	mv -t "$INSTALL_DIR" "$family_dir"

	# Clean up the downloaded zip and extracted files
	rm -f "$font_zip"
	rm -rf "$family_dir"
}

# Loop through each URL and download & install the fonts
for url in "${NerdFontUrls[@]}"; do
    download_and_install_font "$url" || { echo "Error installing font $url"; exit 1; }
done

# Rebuild font cache
fc-cache -fv

rm -r /home/$USER_HOME/tmp/

echo "All fonts have been installed successfully!"
