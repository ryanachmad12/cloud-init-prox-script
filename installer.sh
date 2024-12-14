#!/bin/bash

# Mengecheck akses root
if [ "$EUID" -ne 0 ]; then
  echo "Gunakan akses root!"
  exit
fi

# Check dependencies
CHECK_DEPENDENCIES() {
  echo "Memeriksa dependencies..."
  if ! dpkg -l | grep -qw "libguestfs-tools"; then
    echo "Dependensi dependencies tidak ditemukan."
    echo "Menginstal dependencies..."
    apt install -y libguestfs-tools

    if [ $? -eq 0 ]; then
      echo "Dependencies berhasil diinstal ulang."
    else
      echo "Gagal menginstal dependencies. Silakan periksa koneksi jaringan Anda."
      exit 1
    fi
  else
    echo "Dependencies sudah terinstal."
  fi
}

# Periksa ulang dependencies
CHECK_DEPENDENCIES
sleep 1
clear


# Main Menu
#clear
echo "========================================="
echo "     INSTALLER CLOUDINIT     "
echo "========================================="
echo "Silahkan dipilih untuk penginstalan"
echo "========================================="
echo "     Made By Ryan     "
echo "=========================================="
echo "1. Pilih OS Yang Tersedia"
echo "2. Custom OS (Image Sendiri)"
echo "3. Exit"
read -e -p "Pilihan Anda: " CHOICE

case $CHOICE in
  1)
    clear
echo "============================="
echo "     INSTALLER CLOUDINIT     "
echo "============================="
echo "Pilih Distro:"
    echo "1. Ubuntu"
    echo "2. Debian"
    echo "3. Exit"
    read -e -p "Pilihan Anda: " DISTRO
    case $DISTRO in
      1)
	clear
	echo "======================="
	echo "	PILIH VERSI   "
	echo "	  UBUNTU      "
	echo "======================="
	echo "1. 20.04 "
	echo "2. 22.04 "
	echo "3. 24.04 "
	echo "4. Exit  "
	read -e -p "Pilihan Anda:" CHOICE_DISTRO 
	case $CHOICE_DISTRO in
    	  1)
	   FINAL_CHOICE="/var/lib/vz/images/focal-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
       	      echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi Ubuntu 20.04 dan ganti nama file menjadi "focal-server-cloudimg-amd64.img""
      		read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
      		case $DOWNLOAD_CHOICE in
        	 yes|y)
          	  echo "Mengunduh ISO Ubuntu 20.04..."
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
        	  ;;
       		 no|n)
          	  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
		 exit 1
          	 ;;
       		 *)
          	  echo "Pilihan tidak valid, keluar."
         	  exit 1
          	  ;;
      		esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
	   ;;
	  2)
	   FINAL_CHOICE="/var/lib/vz/images/jammy-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi Ubuntu 24.04 dan ganti nama file menjadi "jammy-server-cloudimg-amd64.img""
                read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
                case $DOWNLOAD_CHOICE in
                 yes|y)
                  echo "Mengunduh ISO Ubuntu 22.04..."
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
                  ;;
                 no|n)
                  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
		  exit 1
                 ;;
                 *)
                  echo "Pilihan tidak valid, keluar."
                  exit 1
                  ;;
                esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
           ;;
          3)
           FINAL_CHOICE="/var/lib/vz/images/noble-server-cloudimg-amd64.img"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi Ubuntu 24.04 dan ganti nama file menjadi "noble-server-cloudimg-amd64.img""
                read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
                case $DOWNLOAD_CHOICE in
                 yes|y)
                  echo "Mengunduh ISO Ubuntu 24.04..."
                  wget -O $FINAL_CHOICE "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
                  ;;  
                 no|n)
                  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
		  exit 1
                 ;;
                 *)
                  echo "Pilihan tidak valid, keluar."
                  exit 1
                  ;;
                esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
           ;;  
	  4)
	   echo "Exit......."
	   exit 1
	   ;;
	  *)
	   echo "Pilihan tidak valid"
	   exit 1
	   ;;
        esac
	;;
      2)
        clear
        echo "=========================="
        echo "  PILIH VERSI   "
        echo "    Debian      "
        echo "=========================="
        echo "1. Buster "
        echo "2. Bulleyes "
        echo "3. Bookworm "
        echo "4. Exit  "
        read -e -p "Pilihan Anda:" CHOICE_DISTRO 
        case $CHOICE_DISTRO in
          1)
           FINAL_CHOICE="/var/lib/vz/images/debian-10-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi debian 10 (Buster) dan ganti nama file menjadi "debian-10-generic-amd64.qcow2""
                read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
                case $DOWNLOAD_CHOICE in
                 yes|y)  
                  echo "Mengunduh ISO Debian 10 (Buster)..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
                  ;;
                 no|n)
                  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
                 exit 1
                 ;;
                 *)
                  echo "Pilihan tidak valid, keluar."
                  exit 1
                  ;;
                esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
           ;;
          2)
           FINAL_CHOICE="/var/lib/vz/images/debian-11-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi Debian 11 (Bulleyes) dan ganti nama file menjadi "debian-11-generic-amd64.qcow2""
                read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
                case $DOWNLOAD_CHOICE in
                 yes|y)
                  echo "Mengunduh ISO Ubuntu Debian 11 (Bulleyes)..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
                  ;;
                 no|n)
                  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
                  exit 1
                 ;;
                 *)
                  echo "Pilihan tidak valid, keluar."
                  exit 1
                  ;;
                esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
           ;;
          3)
           FINAL_CHOICE="/var/lib/vz/images/debian-12-generic-amd64.qcow2"
            if [ ! -f "$FINAL_CHOICE" ]; then
              echo "File tidak ditemukan di $FINAL_CHOICE."
              echo "Silakan unduh ISO untuk versi Debian 12 (Bookworm) dan ganti nama file menjadi "debian-12-generic-amd64.qcow2""
                read -e -p "Apakah Anda ingin mengunduhnya? (yes/no): " DOWNLOAD_CHOICE
                case $DOWNLOAD_CHOICE in
                 yes|y)
                  echo "Mengunduh ISO Debian 12 (Bookworm)..."
                  wget -O $FINAL_CHOICE "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
                  echo "File telah diunduh dan disalin ke $FINAL_CHOICE."
                  ;;  
                 no|n)
                  echo "Silakan masukkan file ISO yang sesuai dan directory lalu ganti nama menjadi $FINAL_CHOICE."
                  exit 1
                 ;;
                 *)
                  echo "Pilihan tidak valid, keluar."
                  exit 1
                  ;;
                esac
            else
             echo "File ditemukan: $FINAL_CHOICE"
            fi 
           ;;  
          4)
           echo "Exit......."
           exit 1
           ;;
          *)
           echo "Pilihan tidak valid"
           exit 1
           ;;
        esac
        ;;
      3)
	echo "Exit......"
	exit
	;;
      *)
        echo "Pilihan tidak valid. Keluar..."
        exit
        ;;
    esac
    ;;
  2)
   read -e -p "Masukkan link download: " DOWNLOADED
# Fungsi untuk memeriksa apakah ISO sudah ada
CHECK_FILE_HAS_DOWNLOADED() {
  ISO_NAME=$(basename "$DOWNLOADED")  # Mendapatkan nama file dari URL
  FINAL_CHOICE="/var/lib/vz/images/$ISO_NAME"  # Path untuk ISO jika custom os dengan mengambil akhiran link otomatis
  
  if [ -f "$FINAL_CHOICE" ]; then
    echo "ISO untuk $ISO_NAME sudah ada di path $FINAL_CHOICE."
    return 1  # Mengembalikan 1 jika ISO sudah ada
  else
    return 0  # Mengembalikan 0 jika ISO belum ada
  fi
}
 
# Call Function di dalam variabel untuk melakukan pengecheckan file didalam path
CHECK_FILE_HAS_DOWNLOADED

# Jika ISO belum ada, unduh menggunakan wget
if [ $? -eq 0 ]; then
  echo "ISO tidak ditemukan. Mengunduh ISO $ISO_NAME..."
  wget -O "$FINAL_CHOICE" "$DOWNLOADED"  # Mengunduh ISO ke path yang ditentukan

  if [ $? -eq 0 ]; then
    echo "ISO berhasil diunduh: $FINAL_CHOICE"
  else
    echo "Gagal mengunduh ISO dari link: $DOWNLOADED"
    exit 1  # Keluar jika download gagal
  fi
else
  # Jika ISO sudah ada, langsung melanjutkan ke bagian resize disk
  echo "Menggunakan ISO yang sudah ada: $FINAL_CHOICE"
fi
    ;;
  3)
    echo "Keluar..."
    exit
    ;;
  *)
    echo "Pilihan tidak valid. Keluar..."
    exit
    ;;
esac

# Mengubah Ukuran Disk Untuk OS Tersebut
read -e -p "Masukkan ukuran disk yang diinginkan (GB): " DISK_SIZE

qemu-img resize "$FINAL_CHOICE" "${DISK_SIZE}G"
# Cek apakah perintah berhasil
if [ $? -ne 0 ]; then
  echo "Gagal mengubah ukuran disk. Cek kembali kapasitas penyimpanan Anda."
  exit 1
else
  echo "Ukuran disk berhasil diubah menjadi ${DISK_SIZE}G."
fi

# Mengecheck Jika VMID Itu Belum Digunakan
CHECK_VM_IF_EXISTS() {
  if qm list | grep -w "$VMID" > /dev/null; then
    echo "VM dengan ID $VMID sudah ada. Silakan masukkan ID VM yang berbeda."
    return 1
  else
    return 0
  fi
}

# Proses input VMID dan Validasi Jika Dengan VMID Tersebut Belum Digunakan
while true; do
  read -e -p "Masukkan VM ID: " VMID
  CHECK_VM_IF_EXISTS && break
done

# Input lainnya
read -e -p "Masukkan Nama VM: " NAME
read -e -p "Masukkan ukuran memory (MB): " MEMORY
read -e -p "Masukkan jumlah core (default 1): " CORE
CORE=${CORE:-1}
read -e -p "Aktifkan agent (default 1): " AGENT
AGENT=${AGENT:-1}

# Buat VM
qm create "$VMID" --name "$NAME" \
  --memory "$MEMORY" \
  --cores "$CORE" \
  --agent "$AGENT" \
  --vga serial0 --serial0 socket \
  --net0 virtio,bridge=vmbr0

echo "VM $VMID berhasil dibuat dengan nama $NAME."


# Get hostname
HOSTNAME=$(cat /etc/hostname)
###############################
# Import Disk
echo "==================="
echo "Target Disk"
pvesh get /nodes/"$HOSTNAME"/storage --content images
#echo "==================="
read -e -p "Masukkan target storage (contoh: lvm-harddisk): " DISK
 qm importdisk "$VMID" "$FINAL_CHOICE" "$DISK"

# Configure VM
 qm set "$VMID" --scsihw virtio-scsi-pci --scsi0 "$DISK":vm-${VMID}-disk-0,discard=on,ssd=1
 qm set "$VMID" --boot order=scsi0
 qm set "$VMID" --ide2 "$DISK":cloudinit


# final sessions
echo "Silahkan Dijadikan template untuk bisa diclonning terus menerus."
echo "VM dengan ID $VMID berhasil dibuat dan dikonfigurasi."
echo "Silakan atur jaringan pada pengaturan VM sesuai kebutuhan."
