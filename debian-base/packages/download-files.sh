#!/bin/bash

# Downloading files
web_files=(
	###	App Images
	"https://github.com/usebruno/bruno/releases/download/v1.38.1/bruno_1.38.1_x86_64_linux.AppImage"
	"https://github.com/xpipe-io/xpipe/releases/latest/download/xpipe-portable-linux-x86_64.AppImage"
)

# Function to download files
download_files() {
	if ! command -v wget &> /dev/null; then
		echo "wget is required but not installed. Aborting."
		exit 1
	fi
	
	# Determine the original user's home directory when running as root
	USER_HOME="${SUDO_USER:-$USER}"
	
	# Define the Downloads directory
	download_dir="/home/$USER_HOME/Downloads"
	
	# Ensure the Downloads directory exists
	if [ ! -d "$download_dir" ]; then
		echo "Downloads directory does not exist. Aborting."
		exit 1
	fi
	
	echo "Downloading Files to $download_dir..."

	for webfile in "${web_files[@]}"; do
		# Get the basename of the file (file name without path)
		filename=$(basename "$webfile")
		# Define the full path to the file in the Downloads directory
		filepath="$download_dir/$filename"
		
		# Download the file to the Downloads directory
		echo "===== Downloading $webfile to $filepath ..."
		wget "$webfile" -O "$filepath"
		
		if [ $? -eq 0 ]; then
			echo "Download successful: $webfile"
		else
			echo "Download failed: $webfile"
		fi
	done
}

