#!/bin/bash

# Determine the directory of the current script
SCRIPT=$(dirname "$(realpath "$0")")

# Determined distro script
DEBIAN="$SCRIPT/debian-base/post-install-debian.sh"
FEDORA="$SCRIPT/fedora-base/post-install-fedora.sh"
ARCH="$SCRIPT/arch-base/post-install-arch.sh"

# Enable case-insensitive globbing
shopt -s nocaseglob

# Function to display the menu
show_menu() {
  echo "What is the base Linux distro of your installed system?"
  echo -e "\n1) Debian/Ubuntu\n2) Fedora\n3) Arch\n4) Exit\n"
}

handle_selection() {
  case $1 in
    1|Debian|Ubuntu)
    	echo -e "\nYou are currently running $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2) which is a Debian/Ubuntu base distro."
    	read -p "Is this correct?(Y/n): " confirm
			confirm=${confirm:-y}
			if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    		echo "Script aborted."
    		exit 1
			fi
			echo -e "\nExecuting Debian/Ubuntu specific script..."
			source "$DEBIAN"
      ;;
    2|Fedora)
    	echo -e "\nYou are currently running $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2) which is a Fedora base distro."
    	read -p "Is this correct?(Y/n): " confirm
			confirm=${confirm:-y}
			if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    		echo "Script aborted."
    		exit 1
			fi
			echo -e "\nExecuting Fedora specific script..."
			source "$FEDORA"
      ;;
    3|Arch)
    	echo -e "\nYou are currently running $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2) which is an Arch base distro."
    	read -p "Is this correct?(Y/n): " confirm
			confirm=${confirm:-y}
			if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    		echo "Script aborted."
    		exit 1
			fi
			echo -e "\nExecuting Arch specific script..."
			source "$ARCH"
      ;;
    4|Exit)
      echo -e "\nExit script"
      exit 0
      ;;
    *)
      echo -e "\nInvalid option, please try again.\n"
      return 1
      ;;
  esac
  return 0
}

# Main loop
while true; do
  show_menu
  read -p "Please enter you selection: " user_input

  handle_selection "$user_input" && break
done

