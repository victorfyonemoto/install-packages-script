#!/bin/bash

# Flatpak applications
flatpak_apps=(
    ### Programming
    "rest.insomnia.Insomnia"
    ### Games
    "com.valvesoftware.Steam"
    "net.lutris.Lutris"
    "com.heroicgameslauncher.hgl"
    ### Media
    "org.gnome.Rhythmbox3"
    "com.spotify.Client"
    "io.github.celluloid_player.Celluloid"
    ### Art and Drawing
    "org.kde.krita"
    "org.inkscape.Inkscape"
    "org.gimp.GIMP"
    ### Utils
    "com.github.ADBeveridge.Raider" # File Shredder  
    "com.usebottles.bottles"    
    "io.github.jeffshee.Hidamari"
    "it.mijorus.gearlever"
    "org.qbittorrent.qBittorrent"
    "org.localsend.localsend_app"
    "com.mattjakeman.ExtensionManager"
)

# Function to install Flatpak applications
install_flatpaks() {
	# Check if flatpak is installed
	if ! command -v flatpak &> /dev/null; then   # Check if flatpak is installed
  	echo "Flatpak is not installed. Installing flatpak..."
  	# Install flatpak using pacman
		if ! pacman -S flatpak --noconfirm; then
    	echo "Failed to install flatpak. Skipping flatpak apps installation."
    	return
		fi
		if ! flatpak remote-list | grep -q flathub; then
			echo "Flathub not found. Adding Flathub repository..."
			flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
		fi
	fi
	
	# Update Flatpak repositories
	echo "Updating Flatpak repositories..."
	if ! flatpak update --appstream; then
    echo "Failed to update Flatpak repositories. Skipping app installation."
    return
	fi

	# Install Flatpak applications
	echo "Installing Flatpaks..."
	for app in "${flatpak_apps[@]}"; do
		echo "===== Installing $app... ====="
		flatpak install -y flathub "$app" || { echo "Failed to install $app"; exit 1; }
	done
	echo "All specified Flatpaks have been installed."
}
