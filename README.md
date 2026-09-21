# Cloud-Init Proxmox Script

Script ini dibuat oleh **OpsLinuxSec**, oleh **Ryan Achmad J**, untuk mempermudah pembuatan VM Cloud-Init di Proxmox VE dari cloud image. Semua proses dibuat interaktif supaya pembuatan VM template bisa dilakukan lebih cepat tanpa perlu menjalankan perintah Proxmox satu per satu.

Script ini cocok dipakai saat ingin menyiapkan template Ubuntu, Debian, Arch Linux, atau cloud image milik sendiri. Tetap periksa setiap pilihan sebelum melanjutkan, terutama ukuran disk, VM ID, dan target storage.

## Sebelum Menjalankan

- Jalankan script langsung di host Proxmox VE dengan akses `root`.
- Siapkan koneksi internet jika image atau dependency belum ada di server.
- Pastikan direktori `/var/lib/vz/images/` ruang disk masih cukup.

## Menjalankan

Unduh script terlebih dahulu:

```bash
wget https://raw.githubusercontent.com/ryanachmad12/cloud-init-prox-script/stagging/installer.sh
```

Lalu jalankan sebagai root:

```bash
sudo bash installer.sh
```

## Alur Instalasi

1. Pilih **Choose Available OS** untuk memakai image yang sudah tersedia, atau **Custom OS** jika ingin memakai link image sendiri.
2. Jika memilih image bawaan, pilih distro dan versinya.
3. Isi ukuran disk, VM ID, nama VM, RAM, jumlah core, dan pengaturan QEMU agent.
4. Saat diminta, pilih storage Proxmox sebagai lokasi disk VM.
5. Setelah proses selesai, atur jaringan VM di Proxmox, lalu jadikan VM tersebut sebagai template jika diperlukan.

## Catatan Penting

- Image yang dipilih akan disimpan di `/var/lib/vz/images/`.
- Ukuran disk image diubah langsung oleh script. Pilih ukuran yang sesuai dan buat salinan image jika ingin menyimpan file aslinya.
- Script sudah menambahkan disk Cloud-Init, tetapi pengaturan jaringan dan opsi Cloud-Init lainnya tetap perlu disesuaikan dari Proxmox.
- VM tidak langsung diubah menjadi template. Setelah memastikan konfigurasinya sudah benar, gunakan menu Proxmox atau jalankan:

```bash
qm template <VMID>
```

- Sebelum menjalankan script di server produksi, sebaiknya coba terlebih dahulu di VM atau node uji.
- Pastikan VM ID belum digunakan dan storage tujuan memiliki ruang yang cukup agar proses import tidak gagal di tengah jalan.
- Jika menggunakan **Custom OS**, gunakan link cloud image yang terpercaya dan sesuai dengan arsitektur server Anda.

## License

Distributed under the [MIT License](LICENSE).
