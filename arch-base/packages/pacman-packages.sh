#!/bin/bash

# Packages
pacman_packages=(
	### System
	"timeshift"
	### Utils
	"gzip"
	"bat"
	"fzf"
	"ripgrep"
	"fd"
	"vifm"
	"gnome-tweaks"
	"piper"
	### Office
	#"pdfarranger"
	### Programming
	"git"
	"neovim"
	### Media
	"vlc"
	"celluloid"
	"transmission-gtk"
	### Compatibility
	"wine"
	"winetricks"
)

# Function to install pacman packages
install_pacman_packages() {
	echo "Installing packages..."
	for pkg in "${pacman_packages[@]}"; do
		if ! pacman -Qs "$pkg" &>/dev/null; then
			echo "===== Installing $pkg... ====="
			pacman -S --noconfirm "$pkg" || { echo "Failed to install $pkg"; exit 1; }
		else
			echo "$pkg is already installed."
		fi
	done
	echo "All specified packages have been installed."
}
