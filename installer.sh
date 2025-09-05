#!/bin/bash


# Color
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

clear

# Check root access
if [ "$EUID" -ne 0 ]; then
  echo "Use root access!"
  exit
fi

# Check dependencies
CHECK_DEPENDENCIES() {
  echo "Checking dependencies..."
  if ! dpkg -l | grep -qw "libguestfs-tools"; then
    echo "Dependency not found."
    echo "Installing dependencies..."
    apt install -y libguestfs-tools

    if [ $? -eq 0 ]; then
      echo "Dependencies successfully installed."
    else
      echo "Failed to install dependencies. Please check your network connection."
      exit 1
    fi
  else
    echo "Dependencies are already installed."
  fi
}

# Recheck dependencies
CHECK_DEPENDENCIES
sleep 1
clear

# ACSII Banner
echo -e "${CYAN}"
echo "#######               #                               #####                "
echo "#     # #####   ####  #       # #    # #    # #    # #     # ######  ####  "
echo "#     # #    # #      #       # ##   # #    #  #  #  #       #      #    # "
echo "#     # #    #  ####  #       # # #  # #    #   ##    #####  #####  #      "
echo "#     # #####       # #       # #  # # #    #   ##         # #      #      "
echo "#     # #      #    # #       # #   ## #    #  #  #  #     # #      #    # "
echo "####### #       ####  ####### # #    #  ####  #    #  #####  ######  ####  "
echo -e "${RESET}"


# Menu
echo -e "${YELLOW}=====================================${RESET}"
echo -e "${GREEN}        Cloud-Init Installer        ${RESET}"
echo -e "${YELLOW}=====================================${RESET}"
echo -e "${BLUE}Please select for installation${RESET}"
echo -e "${YELLOW}=====================================${RESET}"
echo -e "${CYAN}1.${RESET} Choose Available OS"
echo -e "${CYAN}2.${RESET} Custom OS (Your Own Image)"
echo -e "${CYAN}3.${RESET} Exit"
echo -e "${YELLOW}=====================================${RESET}"

read -e -p "Your choice: " CHOICE                                        
case $CHOICE in
  1)
    clear
    # Menu Distro
    echo -e "${YELLOW}╔════════════════════╗${RESET}"
    echo -e "${YELLOW}║${RESET}    ${CYAN}OpsLinuxSec${RESET}     ${YELLOW}║${RESET}"
    echo -e "${YELLOW}╚════════════════════╝${RESET}"
    echo -e "${GREEN}Select Distro:${RESET}"
    echo -e "${BLUE}1.${RESET} Ubuntu"
    echo -e "${BLUE}2.${RESET} Debian"
    echo -e "${BLUE}3.${RESET} Exit"
    echo -e "${YELLOW}──────────────────────${RESET}"

    read -e -p "Your choice: " DISTRO
    case $DISTRO in
      1)
        clear
	echo -e "${YELLOW}╔══════════════════════════════════════╗${RESET}"
	echo -e "${YELLOW}║        CHOOSE UBUNTU VERSION         ║${RESET}"
	echo -e "${YELLOW}╠════╦═══════════╦═════════════════════╣${RESET}"
	echo -e "${YELLOW}║ No ║ Version   ║ Codename            ║${RESET}"
	echo -e "${YELLOW}╠════╬═══════════╬═════════════════════╣${RESET}"
	echo -e "${YELLOW}║ 1  ║ 20.04 LTS ║ Focal Fossa         ║${RESET}"
	echo -e "${YELLOW}║ 2  ║ 22.04 LTS ║ Jammy Jellyfish     ║${RESET}"
	echo -e "${YELLOW}║ 3  ║ 24.04 LTS ║ Noble Numbat        ║${RESET}"
	echo -e "${YELLOW}║ 4  ║ Exit      ║ Exit Interrupt      ║${RESET}"
	echo -e "${YELLOW}╚════╩═══════════╩═════════════════════╝${RESET}"

	read -e -p "Your choice: " CHOICE_DISTRO 
       case $CHOICE_DISTRO in
          1)
            FINAL_CHOICE="/var/lib/vz/images/focal-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Ubuntu 20.04 ISO and rename the file to 'focal-server-cloudimg-amd64.img'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo -e "${YELLOW}Downloading Ubuntu 20.04 ISO...${RESET}"
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                  ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;
          2)
            FINAL_CHOICE="/var/lib/vz/images/jammy-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Ubuntu 22.04 ISO and rename the file to 'jammy-server-cloudimg-amd64.img'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Ubuntu 22.04 ISO..."
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                  ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;
          3)
            FINAL_CHOICE="/var/lib/vz/images/noble-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Ubuntu 24.04 ISO and rename the file to 'noble-server-cloudimg-amd64.img'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Ubuntu 24.04 ISO..."
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;  
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;  
          4)
            echo "Exiting..."
            exit 1
            ;;
          *)
            echo "Invalid choice"
            exit 1
            ;;
        esac
      ;;
      2)
        clear
	echo -e "${YELLOW}╔══════════════════════════════════════╗${RESET}"
	echo -e "${YELLOW}║         CHOOSE DEBIAN VERSION        ║${RESET}"
	echo -e "${YELLOW}╠════╦═══════════╦═════════════════════╣${RESET}"
	echo -e "${YELLOW}║ No ║ Version   ║ Codename            ║${RESET}"
	echo -e "${YELLOW}╠════╬═══════════╬═════════════════════╣${RESET}"
	echo -e "${YELLOW}║ 1  ║ 10        ║ Buster              ║${RESET}"
	echo -e "${YELLOW}║ 2  ║ 11        ║ Bullseye            ║${RESET}"
	echo -e "${YELLOW}║ 3  ║ 12        ║ Bookworm            ║${RESET}"
	echo -e "${YELLOW}║ 4  ║ 13        ║ Trixie              ║${RESET}"
	echo -e "${YELLOW}║ 5  ║ Exit      ║ Exit Interrupt      ║${RESET}"
	echo -e "${YELLOW}╚════╩═══════════╩═════════════════════╝${RESET}"

	read -e -p "Your choice: " CHOICE_DISTRO
        case $CHOICE_DISTRO in
          1)
            FINAL_CHOICE="/var/lib/vz/images/debian-10-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Debian 10 (Buster) ISO and rename the file to 'debian-10-generic-amd64.qcow2'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)  
                  echo "Downloading Debian 10 (Buster) ISO..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                  ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;
          2)
            FINAL_CHOICE="/var/lib/vz/images/debian-11-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Debian 11 (Bullseye) ISO and rename the file to 'debian-11-generic-amd64.qcow2'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Debian 11 (Bullseye) ISO..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                  ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;
          3)
            FINAL_CHOICE="/var/lib/vz/images/debian-12-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Debian 12 (Bookworm) ISO and rename the file to 'debian-12-generic-amd64.qcow2'"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Debian 12 (Bookworm) ISO..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;  
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi 
          ;;
          4)
            FINAL_CHOICE="/var/lib/vz/images/debian-13-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
              echo -e "${GREEN}Please download the Debian 13 (Trixie) ISO and rename the file to 'debian-13-generic-amd64.qcow2'${RESET}"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Debian 13 (Trixie) ISO..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
                  echo "File downloaded and saved to $FINAL_CHOICE."
                  ;;
                no|n)
                  echo "Please input the correct ISO file and directory, then rename it to $FINAL_CHOICE."
                  exit 1
                  ;;
                *)
                  echo "Invalid choice, exiting."
                  exit 1
                  ;;
              esac
            else
              echo "File found: $FINAL_CHOICE"
            fi
          ;;
          5)
            echo "Exiting..."
            exit 1
            ;;
          *)
            echo "Invalid choice"
            exit 1
            ;;
        esac
        ;;
      3)
        echo "Exiting..."
        exit
        ;;
      *)
        echo "Invalid choice. Exiting..."
        exit
        ;;
    esac
    ;;
  2)
    read -e -p "Enter the download link: " DOWNLOADED
    # Function to check if the ISO has already been downloaded
    CHECK_FILE_HAS_DOWNLOADED() {
      ISO_NAME=$(basename "$DOWNLOADED")  # Get file name from URL
      FINAL_CHOICE="/var/lib/vz/images/$ISO_NAME"  # Path for custom OS image
      
      if [ -f "$FINAL_CHOICE" ]; then
        echo "ISO for $ISO_NAME already exists at $FINAL_CHOICE."
        return 1  # Return 1 if ISO already exists
      else
        return 0  # Return 0 if ISO doesn't exist
      fi
    }
   
    # Call function inside variable to check file in path
    CHECK_FILE_HAS_DOWNLOADED

    # If ISO doesn't exist, download using wget
    if [ $? -eq 0 ]; then
      echo "ISO not found. Downloading ISO $ISO_NAME..."
      wget -O "$FINAL_CHOICE" "$DOWNLOADED"  # Download ISO to the specified path

      if [ $? -eq 0 ]; then
        echo "ISO successfully downloaded: $FINAL_CHOICE"
      else
        echo "Failed to download ISO from the link: $DOWNLOADED"
        exit 1  # Exit if download fails
      fi
    else
      # If ISO already exists, continue to resize disk
      echo "Using existing ISO: $FINAL_CHOICE"
    fi
    ;;
  3)
    echo "Exiting..."
    exit
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit
    ;;
esac

# Resize disk for the chosen OS
read -e -p "Enter the desired disk size (GB): " DISK_SIZE

qemu-img resize --shrink "$FINAL_CHOICE" "${DISK_SIZE}G"
# Check if command was successful
if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to resize disk. Please check log error at bottom.${RESET}"
  echo -e "${RED}And Run again after know the error what need you do${RESET}"
  exit 1
else
  echo -e "${GREEN}Disk size successfully resized to ${DISK_SIZE}G.${RESET}"
fi

# Check if VMID is already used
CHECK_VM_IF_EXISTS() {
  if qm list | grep -w "$VMID" > /dev/null; then
    echo -e "${RED}VM with ID $VMID already exists. Please use a different VMID.${RESET}"
    return 1
  else
    return 0
  fi
}

# Input VMID and validate if it's available
while true; do
  read -e -p "Enter VM ID: " VMID
  CHECK_VM_IF_EXISTS && break
done

# Other inputs
read -e -p "Enter VM name: " NAME
read -e -p "Enter memory size (MB): " MEMORY
read -e -p "Enter number of cores (default 1): " CORE
CORE=${CORE:-1}
read -e -p "Enable agent (default 1): " AGENT
AGENT=${AGENT:-1}

# Create VM
qm create "$VMID" --name "$NAME" \
  --memory "$MEMORY" \
  --cores "$CORE" \
  --agent "$AGENT" \
  --vga serial0 --serial0 socket \
  --net0 virtio,bridge=vmbr0

echo -e "${GREEN}VM $VMID successfully created with name $NAME.${RESET}"


# Get hostname
HOSTNAME=$(cat /etc/hostname)
###############################
# Import Disk
echo "==================="
echo "Target Disk"
pvesh get /nodes/"$HOSTNAME"/storage --content images
read -e -p "Enter target storage (e.g., lvm-harddisk): " DISK
 qm importdisk "$VMID" "$FINAL_CHOICE" "$DISK"

# Configure VM
 qm set "$VMID" --scsihw virtio-scsi-pci --scsi0 "$DISK":vm-${VMID}-disk-0,discard=on,ssd=1
 qm set "$VMID" --boot order=scsi0
 qm set "$VMID" --ide2 "$DISK":cloudinit


# Final sessions
echo -e "${CYAN}Please set this VM as a template for continuous cloning.${RESET}"
echo -e "${CYAN}VM with ID $VMID successfully created and configured.${RESET}"
echo -e "${YELLOW}Please configure the network in the VM settings as needed.${RESET}"
