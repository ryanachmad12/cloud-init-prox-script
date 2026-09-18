# CrynSec Proxmox Cloud-Init Installer

A single Bash script for creating Proxmox VMs from cloud images. It downloads or reuses a cached image, imports it, attaches the imported disk, and resizes the VM disk afterwards. Cached base images are never modified.

## Features

- Central image database: Ubuntu 20.04/22.04/24.04, Debian 10-13, and Arch Latest
- Custom RAW or QCOW2 cloud images with a URL, filename, and format
- Validated VM ID, name, CPU sockets/cores, memory, disk size, storage, bridge, and image inputs
- Proxmox storage and bridge selection, VirtIO networking, SCSI disk, Cloud-Init drive, and boot order
- DHCP or static IPv4, DNS/search domain, default user, password, SSH key, and SSH password authentication setting
- Optional QEMU Guest Agent channel plus guest installation through Cloud-Init
- Sensible defaults for disk, CPU type, ballooning, BIOS, machine type, and disk options
- `--dry-run`, `--verbose`, `--help`, and `--version`

## Requirements

- Proxmox VE host
- Root access
- `qm`, `pvesm`, `pvesh`, `qemu-img`, `wget`, and `ip` (provided by a normal Proxmox host)
- A Proxmox storage with `images` content enabled
- A storage with `snippets` content enabled only when using QGA installation, additional packages, or disabled SSH password auth

## Install And Run

```bash
wget https://raw.githubusercontent.com/ryanachmad12/cloud-init-prox-script/main/installer.sh
chmod +x installer.sh
sudo ./installer.sh
```

The installer is interactive by default. Use `sudo ./installer.sh --help` for options. `--dry-run` shows commands that would modify Proxmox and skips downloading, while still reading Proxmox storage and network information for the interactive prompts.

## Supported Images

| OS | Version | Codename | Format |
| --- | --- | --- | --- |
| Ubuntu | 20.04 | Focal Fossa | RAW |
| Ubuntu | 22.04 | Jammy Jellyfish | RAW |
| Ubuntu | 24.04 | Noble Numbat | RAW |
| Debian | 10 | Buster | QCOW2 |
| Debian | 11 | Bullseye | QCOW2 |
| Debian | 12 | Bookworm | QCOW2 |
| Debian | 13 | Trixie | QCOW2 |
| Arch | Latest | Rolling | QCOW2 |

To add a supported image, add one `OS|VERSION|CODENAME|FILENAME|URL|FORMAT` entry to the `IMAGES` array in `installer.sh`. The menus use that database; no distro-specific install paths exist.

## Image Cache And Disk Flow

Downloaded images are cached in `/var/lib/vz/images`. Existing non-empty images can be reused or re-downloaded. Downloads use a `.part` file and are checked with `qemu-img info` before entering the cache.

```text
cloud image cache -> qm importdisk -> attach as scsi0 -> qm resize
```

The original cloud image is not resized. Both RAW and QCOW2 images use the same import flow.

## VM Resources

The CPU prompts configure the VM topology, not physical host sockets:

```text
CPU Sockets [1]: 2
CPU Cores [2]: 4
2 sockets x 4 cores = 8 vCPU
```

Memory defaults to 2048 MB and disk size is 20 GB. VM IDs must be numeric, at least 100, and unused. Names allow letters, digits, `.`, `_`, and `-`.

## Cloud-Init, SSH, And Networking

The installer creates an `ide2` Cloud-Init drive and supports:

- A hostname, default user (`clouduser`), and default password (`clouduser`)
- Optional replacement password and SSH public key
- SSH password authentication toggle
- DHCP or static IPv4 with gateway
- Optional DNS servers and search domain

For static networking, provide an address in CIDR form, such as `192.0.2.10/24`.

### QEMU Guest Agent

Enabling the option configures the Proxmox QGA channel with `--agent enabled=1`. It does not itself install software inside the guest. The installer also creates a Cloud-Init user-data snippet that installs and enables `qemu-guest-agent` in the guest. Therefore this option requires a snippets-capable Proxmox storage.

The same snippet mechanism is used for optional comma-separated packages, for example:

```text
nginx,curl,htop,vim
```

Leave the packages prompt blank to keep the guest minimal.

## Example

```text
CrynSec Cloud-Init Installer v2.0.0
CrynSec | Proxmox cloud-image VM creator

Select operating system: 1
Select version: 3
Target storage: local-lvm
Network bridge [vmbr0]:
VM ID (minimum 100): 200
VM name [ubuntu-24.04]: web-01
CPU sockets [1]: 1
CPU cores [2]: 2
1 sockets x 2 cores = 2 vCPU
Memory in MB [2048]: 4096
Disk size in GB [20]: 40
```

On success, the script prints the VM configuration summary, `qm config <VMID>`, and the `qm start <VMID>` command.

## Troubleshooting

- Ensure the selected storage appears in `pvesm status -content images`.
- Ensure the selected bridge exists, or explicitly accept use of a bridge that will be created later.
- If Cloud-Init packages or QGA setup fails before VM creation, configure `snippets` content on a directory storage in Proxmox.
- Check the image URL and internet access when downloads fail. Remove an incomplete cache file in `/var/lib/vz/images` if needed.
- Inspect a created VM with `qm config <VMID>` and its guest Cloud-Init logs after boot.

## License

[MIT](LICENSE)
