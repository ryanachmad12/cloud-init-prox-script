# VM dengan Cloud Init Installer Script

**OpsLinuxSec CLOUD INIT INSTALLER** adalah script installer yang memungkinkan Anda untuk dengan mudah mengonfigurasi dan menginstal berbagai OS pada Proxmox Virtual Environment (PVE) menggunakan **CLOUD INIT**. Jika ISO yang diinginkan tidak tersedia di direktori `/var/lib/vz/images/`, script ini akan otomatis mengunduhnya untuk Anda.

## Prasyarat

Pastikan sistem Anda sudah memiliki dependensi berikut:
- **wget**: untuk mengunduh ISO
- **Proxmox VE**: untuk menjalankan VM
- **Root**: tools ini membutuhkan akses root

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 6px; background-color: #f0fff4;">
  <b>📝 Note:</b> Added Debian <i>Trixie</i> choice to distro menu.
</div>


### Memeriksa dan Menginstal Dependencies

Script ini akan memeriksa apakah dependensi yang diperlukan sudah terinstal. Jika belum, maka dependensi akan diinstal secara otomatis.

## Langkah Penggunaan

1. **Unduh dan Persiapkan Script**
   
   Unduh script dan pastikan file ini dapat dieksekusi:
   ```bash
   wget https://github.com/ryanachmad12/cloud-init-prox-script/raw/refs/heads/main/installer.sh
   chmod +x installer.sh
   ```

2. **Jalankan Script Installer**
   
   Jalankan script dengan perintah berikut:
   ```bash
   bash installer.sh
   ```

### Proses Instalasi

Saat menjalankan script, berikut adalah langkah-langkah yang akan diikuti:

1. **Memeriksa Dependencies**
   
   Script akan memeriksa apakah dependensi yang diperlukan sudah terinstal.

   ```bash
   Memeriksa dependencies...
   Dependencies sudah terinstal.
   ```

2. **Pilih OS yang Tersedia**

   Setelah memeriksa dependensi, Anda akan melihat menu utama:

   ```
   =============================
           OpsLinuxSec
   =============================
   Silakan dipilih untuk penginstalan
   =============================
           OpsLinuxSec
   =============================
   1. Pilih OS Yang Tersedia
   2. Custom OS (Image Sendiri melalui link)
   3. Exit
   Pilihan Anda: 
   ```

   - **Pilih 1** untuk memilih OS yang sudah tersedia.
   - **Pilih 2** untuk menggunakan link download yang Anda miliki.
   - **Pilih 3** untuk keluar dari installer.

3. **Pilih Distro OS**

   Setelah memilih "Pilih OS Yang Tersedia", Anda akan diminta untuk memilih distro:

   ```
   =============================
           OpsLinuxSec
   =============================
   Pilih Distro:
   1. Ubuntu
   2. Debian
   3. Exit
   Pilihan Anda:
   ```

   - Pilih distro yang Anda inginkan, misalnya **Ubuntu**.

4. **Pilih Versi Ubuntu**

   Setelah memilih Ubuntu, pilih versi yang diinginkan:

   ```
   ===========================
           PILIH VERSI
             UBUNTU
   ===========================
   1. 20.04
   2. 22.04
   3. 24.04
   4. Exit
   Pilihan Anda:
   ```

   Pilih versi yang sesuai, misalnya **1** untuk Ubuntu 20.04.

5. **Periksa Ketersediaan Image**

   Jika file ISO tidak ditemukan atau memiliki nama yang berbeda di direktori `/var/lib/vz/images/`, script akan menampilkan pesan ini dan menanyakan apakah Anda ingin mengunduhnya:

   ```
   File tidak ditemukan di /var/lib/vz/images/focal-server-cloudimg-amd64.img.
   Silakan unduh ISO untuk Ubuntu 20.04 dan ganti nama file menjadi focal-server-cloudimg-amd64.img.
   Apakah Anda ingin mengunduhnya? (yes/no):
   ```

   - Pilih **yes** untuk mengunduh ISO atau **no** untuk mengganti nama file secara manual.

6. **Resize Disk dan Pengaturan VM**

   Setelah ISO tersedia, Anda akan diminta untuk menentukan ukuran disk dan ID VM. Berikut adalah langkah-langkahnya:

   ```
   Masukkan ukuran disk yang diinginkan (GB): 6
   Image resized.
   Ukuran disk berhasil diubah menjadi 6G.
   ```

   Jika VM sudah ada, Anda akan diminta untuk memasukkan ID VM yang berbeda.

   ```
   Masukkan VM ID: 123
   VM dengan ID 123 sudah ada. Silakan masukkan ID VM yang berbeda.
   ```

   Jika ID VM belum ada, Anda akan diminta untuk memasukkan informasi lebih lanjut tentang VM, seperti nama VM, ukuran memori, dan jumlah core:

   ```
   Masukkan VM ID: 222
   Masukkan Nama VM: example
   Masukkan ukuran memory (MB): 512
   Masukkan jumlah core (default 1): 
   Aktifkan agent (default 1): 
   VM 222 berhasil dibuat dengan nama example.
   ```

7. **Pilih Target Disk**

   Setelah membuat VM, Anda akan memilih disk target:

   ```
   Target Disk
   ┌────────────────┬───────────┬─────────┬────────┬───────────┬─────────┬────────┬───────────┬───────────┬───────────────┐
   │ content        │ storage   │ type    │ active │ avail     │ enabled │ shared │ total     │ used      │ used_fraction │
   ╞════════════════╪═══════════╪═════════╪════════╪═══════════╪═════════╪════════╪═══════════╪═══════════╪═══════════════╡
   │ rootdir,images │ local-lvm │ lvmthin │ 1      │ 10.10 GiB │ 1       │ 0      │ 11.80 GiB │ 1.70 GiB  │ 14.42%        │
   └────────────────┴───────────┴─────────┴────────┴───────────┴─────────┴────────┴───────────┴───────────┴───────────────┘
   Masukkan target storage (contoh: local-lvm): local-lvm 
   ```

8. **Proses Penyelesaian**

   Setelah konfigurasi selesai, proses pembuatan dan konfigurasi VM akan berjalan otomatis.

   ```
   VM dengan ID 222 berhasil dibuat dan dikonfigurasi.
   Silakan atur jaringan pada pengaturan VM sesuai kebutuhan.
   ```

### Menjadi Template

Setelah VM selesai dibuat, Anda bisa menjadikannya template untuk kloning di masa depan.

## Catatan

- Pastikan Anda memiliki cukup ruang di disk untuk menyimpan ISO dan file VM.
- Pastikan konfigurasi jaringan VM sudah sesuai setelah pembuatan.

---

**OpsLinuxSec** memudahkan proses instalasi dan konfigurasi sistem operasi di Proxmox. Dengan pengunduhan otomatis dan pengaturan VM, Anda bisa menghemat waktu dalam manajemen virtualisasi.
