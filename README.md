# AP KTP - Sistem Kartu Tanda Penduduk untuk QBCore

`ap_ktp` adalah script FiveM untuk framework QBCore yang menghadirkan sistem Kartu Tanda Penduduk (KTP) yang imersif dan fungsional untuk server roleplay kamu. Script ini memungkinkan pemain untuk memiliki, menunjukkan, dan mengelola KTP mereka, serta memberikan peran khusus bagi petugas pemerintah (seperti polisi atau dukcapil) untuk membuat dan memperpanjang KTP warga.

## Fitur Utama

*   **UI KTP**: Background KTP bisa diganti-ganti dan menampilkan informasi seperti NIK, Nama, TTL, Foto Diri, Pekerjaan, dan masa berlaku.
*  **Auto Update**: Jika pemain merubah pekerjaan atau data lain maka di KTP akan ikut berubah 
*   **Lihat & Tunjukkan**: Pemain dapat melihat KTP sendiri atau menunjukkannya ke pemain terdekat. 
*   **Interaksi NPC Petugas**: Petugas dengan job yang telah ditentukan dapat berinteraksi dengan NPC untuk membuka menu layanan kependudukan.
*   **Pembuatan oleh Petugas**: Petugas dapat membuatkan KTP baru untuk pemain lain dengan memasukkan ID, URL foto, dan tanggal kadaluarsa.
*   **Perpanjangan oleh Petugas**: Petugas dapat memperpanjang masa berlaku KTP pemain dengan biaya yang dapat dikonfigurasi.
*   **Sistem Masa Berlaku**: KTP memiliki tanggal kadaluarsa. Jika sudah lewat, status di KTP akan berubah menjadi "KADALUARSA".
*   **Konfigurasi Mudah**: Biaya, pekerjaan yang diizinkan, dan lokasi NPC dapat diatur dengan mudah melalui `config.lua`.
*   **Penyimpanan Data **: Semua data KTP disimpan di `metadata` 
*   **Command Admin**: Dilengkapi command `/resetktp [id]` untuk mereset data KTP pemain jika diperlukan.

## Dependensi

*   [qb-core](https://github.com/qbcore-framework/qb-core)
*   [qb-menu](https://github.com/qbcore-framework/qb-menu)
*   [qb-input](https://github.com/qbcore-framework/qb-input)
*   [qb-target](https://github.com/qbcore-framework/qb-target)

## Instalasi

1.  **Unduh Script**: Unduh file script ini dari repository GitHub.
2.  **Ekstrak & Tempatkan**: Ekstrak file `.zip` dan letakkan folder `ap_ktp` ke dalam direktori `resources` server FiveM kamu (misalnya di dalam folder `[qb]`).
3.  **Tambahkan Item**: Buka file `qb-core/shared/items.lua` dan tambahkan item berikut:

    ```lua
    ['ktp'] = {
        name = 'ktp',
        label = 'Kartu Tanda Penduduk',
        weight = 10,
        type = 'item',
        image = 'ktp.png', -- Pastikan kamu punya gambar ini di qb-inventory/html/images/
        unique = true,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = 'Kartu identitas resmi sebagai warga negara.'
    },
    ```
    *Jangan lupa untuk menambahkan gambar `ktp.png` ke dalam folder `qb-inventory/html/images/`.*

4.  **Konfigurasi**: Buka `config.lua` di dalam folder `ap_ktp` dan sesuaikan pengaturan sesuai kebutuhan server kamu:
    *   `Config.AllowedJobs`: Tentukan pekerjaan mana saja yang dapat berperan sebagai petugas.
    *   `Config.Locations`: Atur lokasi spawn NPC petugas.
    *   Atur biaya dan pengaturan lainnya.

5.  **Ensure Script**: Tambahkan baris berikut ke dalam file `server.cfg` kamu, pastikan posisinya **setelah** semua dependensi (qb-core, qb-menu, dll).

    ```cfg
    ensure ap_ktp
    ```

6.  **Restart Server**: Restart server FiveM kamu dan script siap digunakan!
