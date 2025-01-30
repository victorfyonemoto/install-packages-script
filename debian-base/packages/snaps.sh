#!/bin/bash

snap_apps=(
	###	Utils
	"shfmt"
)

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
