#!/bin/bash

# Packages
apt_packages=(
	### System
	"nala"
	"synaptic"
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
	"pdfarranger"
	### Programming
	"git"
	"neovim"
	### Midia
	"vlc"
	"celluloid"
	"transmission-gtk"
	### Compatibility
	"wine"
	"winetricks"
)

# Function to install APT packages
install_apt_packages() {
	echo "Installing packages..."
	for pkg in "${apt_packages[@]}"; do
		if ! dpkg -l | grep -q "$pkg"; then
			echo "===== Installing $pkg... ====="
			apt install "$pkg" -y || { echo "Failed to install $pkg"; exit 1; }
		else
			echo "$pkg is already installed."
		fi
	done
	echo "All specified packages have been installed."
}
