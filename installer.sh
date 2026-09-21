#!/bin/bash

# Color Var
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

IMAGE_DATABASE=(
  "ubuntu20.04|20.04 LTS|Focal Fossa|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  "ubuntu22.04|22.04 LTS|Jammy Jellyfish|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  "ubuntu24.04|24.04 LTS|Noble Numbat|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  "debian10|10|Buster|https://cdimage.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2"
  "debian11|11|Bullseye|https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  "debian12|12|Bookworm|https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  "debian13|13|Trixie|https://cdimage.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  "arch|Latest|-|https://mirror.citrahost.com/archlinux/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
)

validate_image_row() {
  local row="$1" name version codename url extra
  IFS='|' read -r name version codename url extra <<< "$row"

  if [[ -z "$name" || -z "$version" || -z "$codename" || -z "$url" || -n "$extra" || "$row" != "$name|$version|$codename|$url" || ! "$name" =~ ^[[:alnum:].-]+$ || ! "$url" =~ ^https?://[^[:space:]]+$ ]]; then
    echo "Malformed image database entry: $row" >&2
    return 1
  fi
}

validate_image_database() {
  local row name version codename url extra seen_name
  local -a seen_names=()

  if [ "${#IMAGE_DATABASE[@]}" -eq 0 ]; then
    echo "Image database is empty." >&2
    return 1
  fi

  for row in "${IMAGE_DATABASE[@]}"; do
    validate_image_row "$row" || return 1
    IFS='|' read -r name version codename url extra <<< "$row"
    for seen_name in "${seen_names[@]}"; do
      if [ "$name" = "$seen_name" ]; then
        echo "Duplicate image database entry: $name" >&2
        return 1
      fi
    done
    seen_names+=("$name")
  done
}

get_image_info() {
  local requested_name="$1" row name version codename url extra

  for row in "${IMAGE_DATABASE[@]}"; do
    IFS='|' read -r name version codename url extra <<< "$row"
    if [ "$name" = "$requested_name" ]; then
      validate_image_row "$row" || return 1
      printf '%s\n' "$row"
      return 0
    fi
  done

  echo "Unknown image: $requested_name" >&2
  return 1
}

load_image_info() {
  local row

  row=$(get_image_info "$1") || return 1
  IFS='|' read -r IMAGE_NAME IMAGE_VERSION IMAGE_CODENAME IMAGE_URL <<< "$row"
}

get_image_distro() {
  local name="$1" version="$2" short_version distro

  short_version=${version%% *}
  if [[ "${name,,}" == *"${short_version,,}" ]]; then
    distro=${name:0:${#name}-${#short_version}}
    distro=${distro%-}
    distro=${distro%.}
  else
    distro=$name
  fi
  printf '%s\n' "$distro"
}

format_distro_name() {
  local distro="$1" word output=""
  local -a words

  distro=${distro//-/ }
  distro=${distro//./ }
  read -r -a words <<< "$distro"
  for word in "${words[@]}"; do
    output+="${output:+ }${word^}"
  done
  printf '%s\n' "$output"
}

get_image_display_name() {
  local distro_label

  distro_label=$(format_distro_name "$(get_image_distro "$IMAGE_NAME" "$IMAGE_VERSION")")
  if [ "$IMAGE_CODENAME" = "-" ]; then
    printf '%s ISO\n' "${distro_label^^}"
  elif [[ "$IMAGE_VERSION" == *" "* ]]; then
    printf '%s %s ISO\n' "$distro_label" "${IMAGE_VERSION%% *}"
  else
    printf '%s %s (%s) ISO\n' "$distro_label" "$IMAGE_VERSION" "$IMAGE_CODENAME"
  fi
}

get_image_download_message() {
  local distro_label

  distro_label=$(format_distro_name "$(get_image_distro "$IMAGE_NAME" "$IMAGE_VERSION")")
  if [ "$IMAGE_CODENAME" = "-" ]; then
    printf 'Downloading %s ISO (%s) ISO...\n' "$distro_label" "$IMAGE_VERSION"
  else
    printf 'Downloading %s...\n' "$(get_image_display_name)"
  fi
}

list_distros() {
  local row name version codename url extra distro known_distro
  local -a distros=()

  for row in "${IMAGE_DATABASE[@]}"; do
    IFS='|' read -r name version codename url extra <<< "$row"
    distro=$(get_image_distro "$name" "$version")
    for known_distro in "${distros[@]}"; do
      [ "$distro" = "$known_distro" ] && continue 2
    done
    distros+=("$distro")
  done

  printf '%s\n' "${distros[@]}"
}

list_images() {
  local requested_distro="$1" row name version codename url extra distro

  for row in "${IMAGE_DATABASE[@]}"; do
    IFS='|' read -r name version codename url extra <<< "$row"
    distro=$(get_image_distro "$name" "$version")
    [ "$distro" = "$requested_distro" ] && printf '%s\n' "$name"
  done
}

select_image() {
  local image_display_name file_name

  if ! load_image_info "$1"; then
    echo "Invalid image selection."
    exit 1
  fi
  file_name=$(basename "${IMAGE_URL%%[?#]*}")
  if [ -z "$file_name" ] || [ "$file_name" = "/" ]; then
    echo "Invalid image URL: $IMAGE_URL"
    exit 1
  fi

  FINAL_CHOICE="/var/lib/vz/images/$file_name"
  image_display_name=$(get_image_display_name)

  if [ ! -f "$FINAL_CHOICE" ]; then
    echo -e "${RED}File not found at $FINAL_CHOICE.${RESET}"
    echo -e "${GREEN}Please download the $image_display_name and rename the file to '$file_name'${RESET}"
    read -e -p "Do you want to download it? (yes/no): " DOWNLOAD_CHOICE
    case $DOWNLOAD_CHOICE in
      yes|y)
        get_image_download_message
        wget -O "$FINAL_CHOICE" "$IMAGE_URL"
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
}

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

validate_image_database || exit 1

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
    mapfile -t DISTROS < <(list_distros)
    for i in "${!DISTROS[@]}"; do
      echo -e "${BLUE}$((i + 1)).${RESET} $(format_distro_name "${DISTROS[$i]}")"
    done
    echo -e "${BLUE}$((${#DISTROS[@]} + 1)).${RESET} Exit"
    echo -e "${YELLOW}──────────────────────${RESET}"

    read -e -p "Your choice: " DISTRO
    if ! [[ "$DISTRO" =~ ^[0-9]+$ ]] || [ "$DISTRO" -lt 1 ] || [ "$DISTRO" -gt $((${#DISTROS[@]} + 1)) ]; then
      echo "Invalid choice. Exiting..."
      exit
    fi
    if [ "$DISTRO" -eq $((${#DISTROS[@]} + 1)) ]; then
      echo "Exiting..."
      exit
    fi

    SELECTED_DISTRO="${DISTROS[$((DISTRO - 1))]}"
    mapfile -t IMAGES < <(list_images "$SELECTED_DISTRO")
    clear
    DISTRO_LABEL=$(format_distro_name "$SELECTED_DISTRO")
    MENU_TITLE="CHOOSE ${DISTRO_LABEL^^} VERSION"
    printf -v MENU_LINE "║%*s%s%*s║" "$(((38 - ${#MENU_TITLE}) / 2))" "" "$MENU_TITLE" "$((38 - ((38 - ${#MENU_TITLE}) / 2) - ${#MENU_TITLE}))" ""
    echo -e "${YELLOW}╔══════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}${MENU_LINE}${RESET}"
    echo -e "${YELLOW}╠════╦═══════════╦═════════════════════╣${RESET}"
    echo -e "${YELLOW}║ No ║ Version   ║ Codename            ║${RESET}"
    echo -e "${YELLOW}╠════╬═══════════╬═════════════════════╣${RESET}"
    for i in "${!IMAGES[@]}"; do
      if ! load_image_info "${IMAGES[$i]}"; then
        echo "Invalid image selection."
        exit 1
      fi
      printf -v MENU_LINE "║ %-2s ║ %-9s ║ %-19s ║" "$((i + 1))" "$IMAGE_VERSION" "$IMAGE_CODENAME"
      echo -e "${YELLOW}${MENU_LINE}${RESET}"
    done
    printf -v MENU_LINE "║ %-2s ║ %-9s ║ %-19s ║" "$((${#IMAGES[@]} + 1))" "Exit" "Exit Interrupt"
    echo -e "${YELLOW}${MENU_LINE}${RESET}"
    echo -e "${YELLOW}╚════╩═══════════╩═════════════════════╝${RESET}"

    read -e -p "Your choice: " CHOICE_DISTRO
    if ! [[ "$CHOICE_DISTRO" =~ ^[0-9]+$ ]] || [ "$CHOICE_DISTRO" -lt 1 ] || [ "$CHOICE_DISTRO" -gt $((${#IMAGES[@]} + 1)) ]; then
      echo "Invalid choice"
      exit 1
    fi
    if [ "$CHOICE_DISTRO" -eq $((${#IMAGES[@]} + 1)) ]; then
      echo "Exiting..."
      exit 1
    fi
    select_image "${IMAGES[$((CHOICE_DISTRO - 1))]}"
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
