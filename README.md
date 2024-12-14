# VM Dengan Cloud Init installer script simple

**CLOUD INIT INSTALLER** adalah sebuah script installer yang memungkinkan Anda untuk dengan mudah mengonfigurasi dan menginstal berbagai OS pada Proxmox Virtual Environment (PVE) dengan sistem **CLOUD INIT**. Jika ISO yang diinginkan tidak tersedia di direktori `/var/lib/vz/images/`, script ini akan otomatis mengunduhnya untuk Anda.

## Prasyarat

Pastikan sistem Anda sudah memiliki dependensi berikut:
- **wget**: untuk mengunduh ISO
- **Proxmox VE**: untuk menjalankan VM
- **Root**: tools ini membutuh akses root

### Memeriksa dan Menginstal Dependencies
script ini akan memeriksa apakah dependencies yang diperlukan sudah terinstal. Jika belum, maka dependencies akan diinstal otomatis.

## Langkah Penggunaan

1. **Unduh dan Persiapkan script**
   
   Clone repository dan pastikan file ini dapat dieksekusi:
   ```bash
   https://github.com/ryanachmad12/cloud-init-prox-script
   cd cloud-init-prox-script
   chmod +x installer.sh
   ```

2. **Jalankan script Installer**
   
   Jalankan script dengan perintah:
   ```bash
   bash installer.sh
   ```

### Proses Installasi

Saat menjalankan script, berikut adalah proses yang akan dijalani:

1. **Memeriksa Dependencies**
   
   script akan memeriksa apakah dependencies yang diperlukan sudah terinstal.

   ```bash
   Memeriksa dependencies...
   Dependencies sudah terinstal.
   ```

2. **Pilih OS yang Tersedia**

   Setelah dependencies diperiksa, Anda akan melihat menu utama:

   ```
   =======================================
           INSTALLER CLOUDINIT
   =======================================
   Silahkan dipilih untuk penginstalan
   =======================================
           INSTALLER CLOUDINIT
   =======================================
   1. Pilih OS Yang Tersedia
   2. Custom OS (Image Sendiri berupa link)
   3. Exit
   Pilihan Anda: 
   ```

   - **Pilih 1** untuk memilih OS yang sudah tersedia.
   - **Pilih 2** untuk menggunakan link download yang Anda miliki.
   - **Pilih 3** untuk keluar dari installer.

3. **Pilih Distro OS**

   Setelah memilih "Pilih OS Yang Tersedia", Anda akan diminta untuk memilih distro:

   ```
   =====================================
           INSTALLER CLOUDINIT
   =====================================
   Pilih Distro:
   1. Ubuntu
   2. Debian
   3. Exit
   Pilihan Anda:
   ```

   - Pilih distro yang Anda inginkan, misalnya **Ubuntu**.

4. **Pilih Versi Ubuntu**

   Setelah memilih distro Ubuntu, pilih versi yang diinginkan:

   ```
   ==============================
           PILIH VERSI
             UBUNTU
   ==============================
   1. 20.04
   2. 22.04
   3. 24.04
   4. Exit
   Pilihan Anda:
   ```

   Pilih versi yang sesuai, misalnya **1** untuk Ubuntu 20.04.

5. **Periksa Ketersediaan Image**

   Jika file ISO tidak ditemukan atau berbeda nama di direktori `/var/lib/vz/images/`, script akan menampilkan pesan berikut dan menanyakan apakah Anda ingin mengunduhnya:

   ```
   File tidak ditemukan di /var/lib/vz/images/focal-server-cloudimg-amd64.img.
   Silakan unduh ISO untuk versi Ubuntu 20.04 dan ganti nama file menjadi focal-server-cloudimg-amd64.img
   Apakah Anda ingin mengunduhnya? (yes/no):
   ```

   - Pilih **yes** untuk mengunduh ISO atau **no** untuk mengubah nama manual.

6. **Resize Disk dan Pengaturan VM**

   Setelah ISO tersedia, Anda akan diminta untuk menentukan ukuran disk dan ID VM. Berikut adalah langkah-langkahnya:

   ```
   Masukkan ukuran disk yang diinginkan (GB): 6
   Image resized.
   Ukuran disk berhasil diubah menjadi 6G.
   ```

   Kemudian, jika VM sudah ada, Anda akan diminta untuk memasukkan ID VM yang berbeda.

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

**SCRIPT INI** memudahkan proses instalasi dan konfigurasi sistem operasi di Proxmox. Dengan pengunduhan otomatis dan pengaturan VM, Anda bisa menghemat waktu dalam manajemen virtualisasi.


### Penjelasan:
1. **Instruksi Umum**: Descriptsi cara penggunaan dan langkah-langkah menjalankan script.
2. **Proses Instalasi dan Pengaturan**: Detil langkah yang akan diambil oleh script, termasuk pemilihan OS, pengunduhan ISO, resizing disk, dan pembuatan VM.
3. **Dependencies**: script akan memastikan dependensi yang diperlukan terinstal sebelum melanjutkan.
4. **Pilih Distro dan Versi**: Menyediakan pilihan untuk memilih distro (Ubuntu/Debian) dan versi OS yang akan digunakan.
5. **Pengunduhan ISO**: Mengunduh ISO otomatis jika file belum ada di sistem.
6. **Pembuatan dan Konfigurasi VM**: Menentukan konfigurasi VM, termasuk disk, ID VM, memori, dan core.
