#!/bin/bash

# Packages
dnf_packages=(
	### System
	"timeshift"
	### Utils
	"gzip"
	"bat"
	"fzf"
	"ripgrep"
	"fd-find"
	"vifm"
	"gnome-tweaks"
	"piper"
	### Office
	#"pdfarranger"
	### Programming
	"git"
	"neovim"
	### Midia
	"vlc"
	"celluloid"
	"transmission"
	#"transmission-gtk"
	### Compatibility
	"wine"
	"winetricks"
)

# Function to install DNF packages
install_dnf_packages() {
	echo "Installing packages..."
	for pkg in "${dnf_packages[@]}"; do
		if ! rpm -q "$pkg" &>/dev/null; then
			echo "===== Installing $pkg... ====="
			dnf install -y "$pkg" || { echo "Failed to install $pkg"; exit 1; }
		else
			echo "$pkg is already installed."
		fi
	done
	echo "All specified packages have been installed."
}
