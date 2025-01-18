#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
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

# Flatpak applications
flatpak_apps=(
    ### Programming
    "rest.insomnia.Insomnia"
    ### Games
    "com.valvesoftware.Steam"
    "net.lutris.Lutris"
    "com.heroicgameslauncher.hgl"
    ### Midia
    "org.gnome.Rhythmbox3"
    "com.spotify.Client"
    ### Art and Drawing
    "org.kde.krita"
    "org.inkscape.Inkscape"
    "org.gimp.GIMP"
    ### Utils
    "com.github.ADBeveridge.Raider" # File Shredder
    "com.rafaelmardojai.Blanket"     
    "com.usebottles.bottles"    
    "io.github.jeffshee.Hidamari"
    "it.mijorus.gearlever"
    "org.qbittorrent.qBittorrent"
    "org.localsend.localsend_app"
    "fr.romainvigier.MetadataCleaner"
    "net.codelogistics.webapps"
    "io.missioncenter.MissionCenter"
    "com.mattjakeman.ExtensionManager"
)

snap_apps=(
	###	Utils
	"shfmt"
)

# Downloading deb and AppImages applications
app_images=(
	###	Programming
	"https://github.com/usebruno/bruno/releases/download/v1.38.1/bruno_1.38.1_x86_64_linux.AppImage"
	"https://stable.dl2.discordapp.net/apps/linux/0.0.80/discord-0.0.80.deb"
)

# Function to install APT packages
install_apt_packages() {
	echo "Installing packages..."
	for pkg in "${apt_packages[@]}"; do
		if ! dpkg -l | grep -q "$pkg"; then
			echo "===== Installing $pkg... ====="
			apt install -y "$pkg" || { echo "Failed to install $pkg"; exit 1; }
		else
			echo "$pkg is already installed."
		fi
	done
	echo "All specified packages have been installed."
}

# Function to install Flatpak applications
install_flatpaks() {
	# Check if flatpak is installed
	if ! command -v flatpak &> /dev/null; then   # Check if flatpak is installed
  	echo "Flatpak is not installed. Installing flatpak..."
  	# Try to install flatpak
		if ! apt install flatpak -y; then
    	echo "Failed to install flatpak. Skipping flatpak apps installation."
    	return
		fi
		if ! flatpak remote-list | grep -q flathub; then
			flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
		fi
	fi
	
	echo "Updating Flatpak repositories..."	
	if ! flatpak update --appstream; then
    echo "Failed to update Flatpak repositories. Skipping app installation."
    return
	fi

	echo "Installing Flatpaks..."
	for app in "${flatpak_apps[@]}"; do
		echo "===== Installing $app... ====="
		flatpak install -y flathub "$app" || { echo "Failed to install $app"; exit 1; }
	done
	echo "All specified Flatpaks have been installed."
}

install_snaps() {
	 # Check if snap is installed
	if ! command -v snap &> /dev/null; then   # Check if snap is installed
  	echo "Snapd is not installed. Installing snapd..."

		# Try to install snapd
		if ! apt install snapd -y; then
			echo "Failed to install snapd. Skipping snap apps installation."
			return
		fi

		# Ensure snapd is started
    if ! systemctl enable --now snapd.socket; then
			echo "Failed to start snapd service. Skipping Snap apps installation."
			return
		fi
	fi
	
	# Ensure snapd is active before continuing
	if ! systemctl is-active --quiet snapd.socket; then  # Ensure snapd service is active
		echo "Starting snapd.socket..."
		systemctl enable --now snapd.socket
	fi
	
	echo "Installing Snaps..."
	for snap in "${snap_apps[@]}"; do
		echo "===== Installing $snap... ====="
		snap install "$snap" || { echo "Failed to install $snap"; exit 1; }
	done
	echo "All specified Snaps have been installed."
}

# Function to download App Images
download_appimages() {
	if ! command -v wget &> /dev/null; then
    echo "wget is required but not installed. Aborting."
    exit 1
	fi
	echo "Downloading App Images..."
	for appimage in "${app_images[@]}"; do
		echo "===== Downloading $appimage ..."
		wget "$appimage" -O "$(basename "$appimage")"
		if [ $? -eq 0 ]; then
            echo "Download successful: $appimage"
        else
            echo "Download failed: $appimage"
        fi
    done
}

# Main script execution
echo "Updating System..."
read -p "Proceed with system update and upgrade? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 1
fi
apt update && apt upgrade -y
# User confirmation
read -p "Proceed to installations? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
	echo "Installation aborted."
	exit 1
fi

# Calling functions
install_apt_packages
install_flatpaks
install_snaps
download_appimages

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
