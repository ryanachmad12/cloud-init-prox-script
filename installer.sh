#!/bin/bash

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

# Main Menu
echo "====================="
echo "     OpsLinuxSec     "
echo "====================="
echo "Please select for installation"
echo "====================="
echo "     OpsLinuxSec     "
echo "====================="
echo "1. Choose Available OS"
echo "2. Custom OS (Your Own Image)"
echo "3. Exit"
read -e -p "Your choice: " CHOICE

case $CHOICE in
  1)
    clear
    echo "====================="
    echo "     OpsLinuxSec     "
    echo "====================="
    echo "Select Distro:"
    echo "1. Ubuntu"
    echo "2. Debian"
    echo "3. Exit"
    read -e -p "Your choice: " DISTRO
    case $DISTRO in
      1)
        clear
        echo "=========================="
        echo "    CHOOSE VERSION   "
        echo "      UBUNTU         "
        echo "=========================="
        echo "1. 20.04 "
        echo "2. 22.04 "
        echo "3. 24.04 "
        echo "4. Exit  "
        read -e -p "Your choice:" CHOICE_DISTRO 
        case $CHOICE_DISTRO in
          1)
            FINAL_CHOICE="/var/lib/vz/images/focal-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Ubuntu 20.04 ISO and rename the file to 'focal-server-cloudimg-amd64.img'"
              read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
              case $DOWNLOAD_CHOICE in
                yes|y)
                  echo "Downloading Ubuntu 20.04 ISO..."
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
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Ubuntu 22.04 ISO and rename the file to 'jammy-server-cloudimg-amd64.img'"
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
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Ubuntu 24.04 ISO and rename the file to 'noble-server-cloudimg-amd64.img'"
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
        echo "=========================="
        echo "    CHOOSE VERSION   "
        echo "      Debian         "
        echo "=========================="
        echo "1. Buster "
        echo "2. Bullseye "
        echo "3. Bookworm "
        echo "4. Exit  "
        read -e -p "Your choice:" CHOICE_DISTRO 
        case $CHOICE_DISTRO in
          1)
            FINAL_CHOICE="/var/lib/vz/images/debian-10-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Debian 10 (Buster) ISO and rename the file to 'debian-10-generic-amd64.qcow2'"
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
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Debian 11 (Bullseye) ISO and rename the file to 'debian-11-generic-amd64.qcow2'"
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
              echo "File not found at $FINAL_CHOICE."
              echo "Please download the Debian 12 (Bookworm) ISO and rename the file to 'debian-12-generic-amd64.qcow2'"
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

qemu-img resize "$FINAL_CHOICE" "${DISK_SIZE}G"
# Check if command was successful
if [ $? -ne 0 ]; then
  echo "Failed to resize disk. Please check your storage capacity."
  exit 1
else
  echo "Disk size successfully resized to ${DISK_SIZE}G."
fi

# Check if VMID is already used
CHECK_VM_IF_EXISTS() {
  if qm list | grep -w "$VMID" > /dev/null; then
    echo "VM with ID $VMID already exists. Please use a different VMID."
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

echo "VM $VMID successfully created with name $NAME."


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
echo "Please set this VM as a template for continuous cloning."
echo "VM with ID $VMID successfully created and configured."
echo "Please configure the network in the VM settings as needed."
