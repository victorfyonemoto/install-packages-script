#!/bin/bash

# Snap applications
snap_apps=(
	###	Utils
	"shfmt"
)

# Function to install Snap applications
install_snaps() {
	 # Check if snap is installed
	if ! command -v snap &> /dev/null; then   # Check if snap is installed
  	echo "Snapd is not installed. Installing snapd..."

		# Try to install snapd using pacman
		if ! pacman -S snapd --noconfirm; then
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
	
	# Wait for snapd to be seeded (initializing)
	echo "Waiting for snapd to be fully initialized..."
	for i in {1..60}; do  # Wait up to 60 seconds
		if snap list &>/dev/null; then
			echo "Snapd is ready."
			break
		fi
		echo "Waiting for Snapd to initialize... ($i/60)"
		sleep 1
	done

	# If snapd initialization failed
	if ! snap list &>/dev/null; then
		echo "Snapd initialization failed. Skipping Snap apps installation."
		return
	fi
	
	echo "Installing Snaps..."
	for snap in "${snap_apps[@]}"; do
		echo "===== Installing $snap... ====="
		snap install "$snap" || { echo "Failed to install $snap"; exit 1; }
	done
	echo "All specified Snaps have been installed."
}
