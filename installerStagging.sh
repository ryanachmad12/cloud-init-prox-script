#!/usr/bin/env bash
# CrynSec Proxmox Cloud-Init Installer

set -Eeuo pipefail

readonly VERSION="2.0.0"
readonly PROJECT="CrynSec Cloud-Init Installer"
readonly CACHE_DIR="/var/lib/vz/images"

# OS|VERSION|CODENAME|FILENAME|URL|FORMAT
IMAGES=(
  "Ubuntu|20.04|Focal Fossa|focal-server-cloudimg-amd64.img|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img|raw"
  "Ubuntu|22.04|Jammy Jellyfish|jammy-server-cloudimg-amd64.img|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|raw"
  "Ubuntu|24.04|Noble Numbat|noble-server-cloudimg-amd64.img|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|raw"
  "Debian|10|Buster|debian-10-generic-amd64.qcow2|https://cdimage.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2|qcow2"
  "Debian|11|Bullseye|debian-11-generic-amd64.qcow2|https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|qcow2"
  "Debian|12|Bookworm|debian-12-generic-amd64.qcow2|https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|qcow2"
  "Debian|13|Trixie|debian-13-generic-amd64.qcow2|https://cdimage.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2|qcow2"
  "Arch|Latest|Rolling|Arch-Linux-x86_64-cloudimg.qcow2|https://mirror.citrahost.com/archlinux/images/latest/Arch-Linux-x86_64-cloudimg.qcow2|qcow2"
)

DRY_RUN=0
VERBOSE=0
VM_CREATED=0
SNIPPET_PATH=""
SSH_KEY_FILE=""

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

usage() {
  printf 'Usage: %s [--dry-run] [--verbose] [--help] [--version]\n' "${0##*/}"
  printf 'Interactive Proxmox Cloud-Init VM creator by CrynSec.\n'
}

log() { printf '%b[INFO]%b %s\n' "$BLUE" "$RESET" "$*"; }
ok() { printf '%b[ OK ]%b %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%b[WARN]%b %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die() { printf '%b[FAIL]%b %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }
banner() {
  printf '%b' "$CYAN"
  printf '  ____ ____  __   _   _ ____  _____ ____\n'
  printf ' / ___|  _ \\ \\ / / | \ | / ___|| ____/ ___|\n'
  printf '| |   | |_) \\ \\ V /  |  \\| \\___ \\|  _|| |\n'
  printf '| |___|  _ <   | |   | |\\  |___) | |__| |___\n'
  printf ' \\____|_| \\_\\  |_|   |_| \\_|____/|_____\\____|\n'
  printf '%b' "$RESET"
}
section() { printf '\n%b== %s ==%b\n' "$CYAN" "$*" "$RESET"; }

run() {
  if (( DRY_RUN )); then
    printf '%b[DRY]%b' "$YELLOW" "$RESET"
    printf ' %q' "$@"
    printf '\n'
  else
    (( VERBOSE )) && printf '+ %q ' "$@" && printf '\n'
    "$@"
  fi
}

cleanup() {
  local status=$?
  [[ -n "$SSH_KEY_FILE" ]] && rm -f -- "$SSH_KEY_FILE"
  if (( status != 0 )); then
    if (( VM_CREATED && ! DRY_RUN )); then
      warn "Creation failed; removing incomplete VM ${VMID:-unknown}."
      qm destroy "$VMID" --purge 1 >/dev/null 2>&1 || warn "Could not remove VM $VMID; inspect it with qm config $VMID."
    fi
    [[ -n "$SNIPPET_PATH" ]] && rm -f -- "$SNIPPET_PATH"
  fi
  exit "$status"
}
trap cleanup EXIT

confirm() {
  local prompt=$1 answer
  read -r -p "$prompt [Y/n]: " answer
  [[ -z "$answer" || "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

require_proxmox() {
  [[ $EUID -eq 0 ]] || die "Run this installer as root."
  local command
  for command in qm pvesh pvesm qemu-img wget ip; do
    command -v "$command" >/dev/null 2>&1 || die "Required command not found: $command"
  done
}

is_positive_integer() { [[ $1 =~ ^[1-9][0-9]*$ ]]; }
is_valid_name() { [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]]; }
is_valid_filename() { [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.(img|qcow2|raw)$ ]]; }
is_valid_packages() { [[ -z $1 || $1 =~ ^[A-Za-z0-9][A-Za-z0-9+._-]*(,[A-Za-z0-9][A-Za-z0-9+._-]*)*$ ]]; }
is_valid_ipv4() {
  local ip=$1 octet
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS=. read -r -a octet <<< "$ip"
  (( octet[0] <= 255 && octet[1] <= 255 && octet[2] <= 255 && octet[3] <= 255 ))
}

select_image() {
  local -a oses=() matches=()
  local entry os version codename filename format choice i

  for entry in "${IMAGES[@]}"; do
    IFS='|' read -r os version codename filename _ format <<< "$entry"
    for i in "${oses[@]:-}"; do [[ $i == "$os" ]] && continue 2; done
    oses+=("$os")
  done

  section "Cloud Image"
  printf '  0) Custom image\n'
  for i in "${!oses[@]}"; do printf '  %d) %s\n' "$((i + 1))" "${oses[i]}"; done
  while :; do
    read -r -p "Select operating system: " choice
    [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#oses[@]} )) && break
    warn "Select a listed number."
  done
  (( choice == 0 )) && { select_custom_image; return; }
  SELECTED_OS=${oses[choice - 1]}

  for entry in "${IMAGES[@]}"; do
    IFS='|' read -r os version codename filename _ format <<< "$entry"
    [[ $os == "$SELECTED_OS" ]] && matches+=("$entry")
  done
  for i in "${!matches[@]}"; do
    IFS='|' read -r os version codename filename _ format <<< "${matches[i]}"
    printf '  %d) %s (%s) [%s]\n' "$((i + 1))" "$version" "$codename" "$format"
  done
  while :; do
    read -r -p "Select version: " choice
    [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#matches[@]} )) && break
    warn "Select a listed number."
  done
  IFS='|' read -r OS_NAME OS_VERSION OS_CODENAME IMAGE_FILENAME IMAGE_URL IMAGE_FORMAT <<< "${matches[choice - 1]}"
}

select_custom_image() {
  OS_NAME="Custom" OS_VERSION="Custom" OS_CODENAME="User supplied"
  while :; do
    read -r -p "Cloud image URL: " IMAGE_URL
    [[ -n $IMAGE_URL && $IMAGE_URL =~ ^https://[^[:space:]]+$ ]] && break
    warn "Enter a non-empty HTTPS URL."
  done
  while :; do
    read -r -p "Filename (for example image.qcow2): " IMAGE_FILENAME
    is_valid_filename "$IMAGE_FILENAME" && break
    warn "Use a filename ending in .img, .raw, or .qcow2 (no path separators)."
  done
  while :; do
    read -r -p "Image format [qcow2]: " IMAGE_FORMAT
    IMAGE_FORMAT=${IMAGE_FORMAT:-qcow2}
    [[ $IMAGE_FORMAT == raw || $IMAGE_FORMAT == qcow2 ]] && break
    warn "Format must be raw or qcow2."
  done
}

cache_image() {
  local image_path="$CACHE_DIR/$IMAGE_FILENAME" answer
  run mkdir -p -- "$CACHE_DIR"
  if [[ -s $image_path ]]; then
    read -r -p "Cached image $IMAGE_FILENAME exists. Reuse it? [Y/n]: " answer
    if [[ -z $answer || $answer =~ ^[Yy]([Ee][Ss])?$ ]]; then
      ok "Reusing cached image: $image_path"
      IMAGE_PATH=$image_path
      return
    fi
    warn "Re-downloading $IMAGE_FILENAME."
  elif [[ -e $image_path ]]; then
    warn "Removing incomplete or empty cached image: $image_path"
    run rm -f -- "$image_path"
  fi
  log "Downloading $IMAGE_URL"
  run wget --https-only --show-progress -O "$image_path.part" "$IMAGE_URL"
  if (( ! DRY_RUN )); then
    [[ -s $image_path.part ]] || die "Download is empty or incomplete."
    qemu-img info "$image_path.part" >/dev/null || die "Downloaded file is not a readable QEMU image."
  fi
  run mv -- "$image_path.part" "$image_path"
  IMAGE_PATH=$image_path
  ok "Cached image: $IMAGE_PATH"
}

select_storage() {
  local name status
  STORAGE_OPTIONS=()
  section "VM Storage"
  pvesh get "/nodes/$(hostname)/storage" --content images || die "Could not list image-capable storage."
  while read -r name _ status _; do
    [[ $name == Name || -z $name ]] && continue
    [[ $status == active ]] && STORAGE_OPTIONS+=("$name")
  done < <(pvesm status -content images 2>/dev/null)
  (( ${#STORAGE_OPTIONS[@]} )) || die "No active storage accepts VM images."
  while :; do
    read -r -p "Target storage: " STORAGE
    for name in "${STORAGE_OPTIONS[@]}"; do [[ $STORAGE == "$name" ]] && return; done
    warn "Choose an active storage shown above."
  done
}

select_bridge() {
  local bridge
  local -a bridges=()
  section "Network"
  while read -r _ bridge _; do
    bridge=${bridge%:}
    [[ $bridge == fwbr* ]] || bridges+=("$bridge")
  done < <(ip -o link show type bridge 2>/dev/null)
  (( ${#bridges[@]} )) || die "No network bridges found."
  printf 'Available bridges:\n'
  for bridge in "${bridges[@]}"; do
    printf '  %s\n' "$bridge"
  done
  while :; do
    read -r -p "Network bridge [vmbr0]: " BRIDGE
    BRIDGE=${BRIDGE:-vmbr0}
    ip link show dev "$BRIDGE" >/dev/null 2>&1 && break
    warn "Bridge $BRIDGE does not exist on this host."
    confirm "Use it anyway (for a bridge created before VM start)?" && break
  done
}

configure_vm() {
  local default_name answer
  section "VM Configuration"
  while :; do
    read -r -p "VM ID (minimum 100): " VMID
    if ! is_positive_integer "$VMID" || (( VMID < 100 )); then
      warn "VM ID must be a number of at least 100."
      continue
    fi
    qm status "$VMID" >/dev/null 2>&1 && { warn "VM ID $VMID already exists."; continue; }
    break
  done
  default_name=$(printf '%s-%s' "${OS_NAME,,}" "${OS_VERSION,,}" | tr -cd 'A-Za-z0-9._-')
  while :; do
    read -r -p "VM name [$default_name]: " VM_NAME
    VM_NAME=${VM_NAME:-$default_name}
    is_valid_name "$VM_NAME" && break
    warn "Use 1-63 letters, digits, dots, underscores, or hyphens; start with a letter or digit."
  done
  while :; do read -r -p "CPU sockets [1]: " CPU_SOCKETS; CPU_SOCKETS=${CPU_SOCKETS:-1}; [[ $CPU_SOCKETS == 1 || $CPU_SOCKETS == 2 ]] && break; warn "Sockets must be 1 or 2."; done
  while :; do read -r -p "CPU cores [2]: " CPU_CORES; CPU_CORES=${CPU_CORES:-2}; is_positive_integer "$CPU_CORES" && break; warn "Cores must be a positive integer."; done
  TOTAL_VCPU=$((CPU_SOCKETS * CPU_CORES))
  printf '%s sockets x %s cores = %s vCPU\n' "$CPU_SOCKETS" "$CPU_CORES" "$TOTAL_VCPU"
  while :; do read -r -p "Memory in MB [2048]: " MEMORY; MEMORY=${MEMORY:-2048}; is_positive_integer "$MEMORY" && break; warn "Memory must be a positive integer."; done
  DISK_SIZE=20
  CPU_TYPE=kvm64
  BALLOON=$MEMORY
  NUMA=0
  BIOS=seabios
  MACHINE=q35
  IOTHREAD=1
  DISCARD=on
  SSD=1
  ONBOOT=0
  START_VM=0
}

configure_cloud_init() {
  local answer key
  section "Cloud-Init"
  read -r -p "Guest hostname [$VM_NAME]: " CI_HOSTNAME; CI_HOSTNAME=${CI_HOSTNAME:-$VM_NAME}
  is_valid_name "$CI_HOSTNAME" || die "Invalid hostname."
  while :; do read -r -p "Default guest user [clouduser]: " CI_USER; CI_USER=${CI_USER:-clouduser}; [[ $CI_USER =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] && break; warn "Enter a valid Linux user name."; done
  read -r -s -p "Guest password (leave blank to omit): " CI_PASSWORD; printf '\n'
  read -r -p "SSH public key (paste one line, optional): " key
  if [[ -n $key ]]; then
    [[ $key =~ ^(ssh-|ecdsa-|sk-) ]] || die "SSH key must begin with a recognized public-key type."
    SSH_KEY_FILE=$(mktemp)
    printf '%s\n' "$key" > "$SSH_KEY_FILE"
  fi
  confirm "Allow SSH password authentication?" && SSH_PASSWORD_AUTH=1 || SSH_PASSWORD_AUTH=0
  printf '  1) DHCP\n  2) Static IPv4\n'
  while :; do read -r -p "Network mode [1]: " answer; answer=${answer:-1}; [[ $answer == 1 || $answer == 2 ]] && break; warn "Select 1 or 2."; done
  if [[ $answer == 1 ]]; then
    IP_CONFIG="ip=dhcp"
    GATEWAY=""
  else
    while :; do read -r -p "IPv4 address with CIDR (for example 192.0.2.10/24): " IP_ADDRESS; [[ $IP_ADDRESS =~ ^(.+)/([0-9]|[12][0-9]|3[0-2])$ ]] && is_valid_ipv4 "${BASH_REMATCH[1]}" && break; warn "Enter a valid IPv4 address and CIDR prefix."; done
    while :; do read -r -p "IPv4 gateway: " GATEWAY; is_valid_ipv4 "$GATEWAY" && break; warn "Enter a valid IPv4 gateway."; done
    IP_CONFIG="ip=$IP_ADDRESS,gw=$GATEWAY"
  fi
  read -r -p "DNS servers (space-separated, optional): " DNS
  [[ -z $DNS || $DNS =~ ^[0-9a-fA-F:.[:space:]]+$ ]] || die "DNS may contain only IP addresses separated by spaces."
  read -r -p "DNS search domain (optional): " SEARCH_DOMAIN
  [[ -z $SEARCH_DOMAIN || $SEARCH_DOMAIN =~ ^[A-Za-z0-9.-]+$ ]] || die "Invalid search domain."
  confirm "Enable Proxmox QEMU Guest Agent channel?" && QGA_ENABLED=1 || QGA_ENABLED=0
  read -r -p "Additional packages (comma-separated, optional): " ADDITIONAL_PACKAGES
  is_valid_packages "$ADDITIONAL_PACKAGES" || die "Packages must be comma-separated package names."
}

create_cloud_init_snippet() {
  local snippet_storage filename package_yaml="" package
  [[ $QGA_ENABLED == 1 || -n $ADDITIONAL_PACKAGES || $SSH_PASSWORD_AUTH == 0 ]] || return 0
  if (( DRY_RUN )); then
    CI_CUSTOM="local:snippets/crynsec-${VMID}-user.yaml"
    return
  fi
  local -a snippets=()
  while read -r line; do
    [[ $line == Name* || -z $line ]] && continue
    snippets+=("${line%% *}")
  done < <(pvesm status -content snippets 2>/dev/null || true)
  (( ${#snippets[@]} )) || die "Cloud-Init user-data is required but no snippets storage is configured. Add 'snippets' content to a directory storage."
  snippet_storage=${snippets[0]}
  filename="crynsec-${VMID}-user.yaml"
  SNIPPET_PATH=$(pvesm path "$snippet_storage:snippets/$filename") || die "Could not resolve snippets storage path."
  run mkdir -p -- "$(dirname "$SNIPPET_PATH")"
  {
    printf '#cloud-config\n'
    printf 'hostname: %s\nmanage_etc_hosts: true\n' "$CI_HOSTNAME"
    [[ $SSH_PASSWORD_AUTH == 0 ]] && printf 'ssh_pwauth: false\n'
    if [[ $QGA_ENABLED == 1 || -n $ADDITIONAL_PACKAGES ]]; then
      printf 'packages:\n'
      [[ $QGA_ENABLED == 1 ]] && printf '  - qemu-guest-agent\n'
      IFS=, read -r -a package_yaml <<< "$ADDITIONAL_PACKAGES"
      for package in "${package_yaml[@]:-}"; do [[ -n $package ]] && printf '  - %s\n' "$package"; done
    fi
    [[ $QGA_ENABLED == 1 ]] && printf 'runcmd:\n  - [systemctl, enable, --now, qemu-guest-agent]\n'
  } > "$SNIPPET_PATH"
  CI_CUSTOM="$snippet_storage:snippets/$filename"
}

preview() {
  section "Configuration Preview"
  printf 'VM: %s (%s)\nImage: %s %s (%s), %s\nStorage: %s | Disk: %s GB\nCPU: %s sockets x %s cores = %s vCPU | Memory: %s MB\nNetwork: %s via %s\nQGA: Proxmox channel %s; guest installation %s\n' \
    "$VMID" "$VM_NAME" "$OS_NAME" "$OS_VERSION" "$OS_CODENAME" "$IMAGE_FORMAT" "$STORAGE" "$DISK_SIZE" "$CPU_SOCKETS" "$CPU_CORES" "$TOTAL_VCPU" "$MEMORY" "$IP_CONFIG" "$BRIDGE" \
    "$([[ $QGA_ENABLED == 1 ]] && printf enabled || printf disabled)" "$([[ $QGA_ENABLED == 1 ]] && printf 'via Cloud-Init' || printf 'not requested')"
}

find_imported_disk() {
  local line
  while IFS= read -r line; do
    if [[ $line =~ ^unused[0-9]+:\ ([^,]+) ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
      return
    fi
  done < <(qm config "$VMID")
  return 1
}

create_vm() {
  local imported_disk
  section "Creating VM"
  run qm create "$VMID" --name "$VM_NAME" --memory "$MEMORY" --balloon "$BALLOON" --sockets "$CPU_SOCKETS" --cores "$CPU_CORES" --cpu "$CPU_TYPE" --numa "$NUMA" --bios "$BIOS" --machine "$MACHINE" --scsihw virtio-scsi-single --net0 "virtio,bridge=$BRIDGE" --onboot "$ONBOOT"
  VM_CREATED=1
  [[ $BIOS == ovmf ]] && run qm set "$VMID" --efidisk0 "$STORAGE:0,efitype=4m,pre-enrolled-keys=1"
  [[ $QGA_ENABLED == 1 ]] && run qm set "$VMID" --agent enabled=1
  run qm importdisk "$VMID" "$IMAGE_PATH" "$STORAGE"
  if (( DRY_RUN )); then
    imported_disk="$STORAGE:vm-$VMID-disk-0"
  else
    imported_disk=$(find_imported_disk) || die "Import completed but no unused disk was found."
  fi
  run qm set "$VMID" --scsi0 "$imported_disk,cache=none,iothread=$IOTHREAD,discard=$DISCARD,ssd=$SSD"
  run qm resize "$VMID" scsi0 "${DISK_SIZE}G"
  run qm set "$VMID" --ide2 "$STORAGE:cloudinit" --boot order=scsi0 --ciuser "$CI_USER" --ipconfig0 "$IP_CONFIG"
  [[ -n $CI_PASSWORD ]] && run qm set "$VMID" --cipassword "$CI_PASSWORD"
  [[ -n $SSH_KEY_FILE ]] && run qm set "$VMID" --sshkeys "$SSH_KEY_FILE"
  [[ -n $DNS ]] && run qm set "$VMID" --nameserver "$DNS"
  [[ -n $SEARCH_DOMAIN ]] && run qm set "$VMID" --searchdomain "$SEARCH_DOMAIN"
  [[ -n ${CI_CUSTOM:-} ]] && run qm set "$VMID" --cicustom "user=$CI_CUSTOM"
  if [[ $START_VM == 1 ]]; then
    run qm start "$VMID"
  fi
}

final_summary() {
  section "VM Created - CrynSec"
  printf 'VM ID: %s\nVM Name: %s\nOperating System: %s %s (%s)\nStorage: %s\nDisk: %s GB\nMemory: %s MB\nCPU Sockets: %s\nCPU Cores: %s\nTotal vCPU: %s\nNetwork Bridge: %s\nQEMU Guest Agent: Proxmox channel %s; guest package %s\nCloud-Init: ide2 configured\n\nInspect: qm config %s\nStart:   qm start %s\n' \
    "$VMID" "$VM_NAME" "$OS_NAME" "$OS_VERSION" "$OS_CODENAME" "$STORAGE" "$DISK_SIZE" "$MEMORY" "$CPU_SOCKETS" "$CPU_CORES" "$TOTAL_VCPU" "$BRIDGE" \
    "$([[ $QGA_ENABLED == 1 ]] && printf enabled || printf disabled)" "$([[ $QGA_ENABLED == 1 ]] && printf 'installed and enabled by Cloud-Init' || printf 'not requested')" "$VMID" "$VMID"
  (( DRY_RUN )) || qm config "$VMID"
}

main() {
  case ${1:-} in
    --help|-h) usage; exit 0 ;;
    --version|-V) printf '%s %s\n' "$PROJECT" "$VERSION"; exit 0 ;;
    --dry-run) DRY_RUN=1 ;;
    --verbose|-v) VERBOSE=1 ;;
    "") ;;
    *) usage; die "Unknown option: $1" ;;
  esac
  banner
  printf '%b%s v%s%b\n' "$CYAN" "$PROJECT" "$VERSION" "$RESET"
  (( DRY_RUN )) && warn "Dry-run prints mutating commands and skips downloading; storage and bridge discovery still query Proxmox."
  require_proxmox
  select_image
  cache_image
  select_storage
  select_bridge
  configure_vm
  configure_cloud_init
  preview
  confirm "Create this VM?" || { log "Cancelled."; exit 0; }
  create_cloud_init_snippet
  create_vm
  final_summary
}

main "$@"
