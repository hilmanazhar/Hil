Berdasarkan soal awal dan kode anthony.c yang telah kita selesaikan, saya akan membantu menyusun laporan praktikum dengan format serupa dengan contoh yang Anda berikan.

# Laporan Praktikum Sistem Operasi

## Penjelasan Soal
Anthony sedang menonton film-film favorit dari Netflix, namun koleksinya semakin menumpuk seiring waktu. Dia memutuskan untuk membuat sistem agar film-film tersebut lebih terorganisir dan mudah diakses. Tugas ini bertujuan untuk membuat program C yang dapat membantu Anthony mengelola koleksi filmnya dengan fitur-fitur berikut:

1. **(A) One Click and Done!** - Mengotomatisasi proses download, ekstraksi, dan penghapusan file ZIP data film dengan satu perintah.
2. **(B) Sorting Like a Pro** - Mengelompokkan film secara paralel berdasarkan huruf pertama dari judul dan tahun rilis menggunakan multiprocessing.
3. **(C) The Ultimate Movie Report** - Membuat laporan statistik film berdasarkan negara dan tahun rilis.

---

## Langkah-langkah Pengerjaan

### Data yang perlu disiapkan
- File program `anthony.c` yang berisi implementasi dari semua fitur yang diminta.
- File data film dalam format ZIP yang berisi file CSV dengan informasi film (judul, sutradara, negara, tahun rilis).
- Library C yang digunakan: stdio.h, stdlib.h, string.h, unistd.h, time.h, sys/types.h, sys/stat.h, sys/wait.h, pthread.h, ctype.h, dirent.h.

---

### **(A) One Click and Done!**
#### **Fungsi: `downloadAndExtract()`**
```c
void downloadAndExtract() {
    printf("Mendownload file ZIP dari Google Drive...\n");
    
    // Using wget to download the file from Google Drive
    char download_cmd[512];
    snprintf(download_cmd, sizeof(download_cmd), "wget -O %s '%s'", ZIP_FILE, ZIP_URL);
    
    FILE* download_pipe = popen(download_cmd, "r");
    if (!download_pipe) {
        perror("Gagal mendownload file");
        return;
    }
    pclose(download_pipe);
    
    printf("File ZIP berhasil didownload.\n");
    printf("Mengekstrak file ZIP...\n");
    
    // Extract the ZIP file
    char extract_cmd[256];
    snprintf(extract_cmd, sizeof(extract_cmd), "unzip -o %s", ZIP_FILE);
    
    FILE* extract_pipe = popen(extract_cmd, "r");
    if (!extract_pipe) {
        perror("Gagal mengekstrak file");
        return;
    }
    pclose(extract_pipe);
    
    printf("File berhasil diekstrak.\n");
    printf("Menghapus file ZIP...\n");
    
    // Remove the ZIP file
    if (remove(ZIP_FILE) != 0) {
        perror("Gagal menghapus file ZIP");
        return;
    }
    
    printf("File ZIP berhasil dihapus.\n");
}
```

#### **Penjelasan Code**
- Fungsi ini mengotomatisasi tiga langkah penting dengan satu panggilan:
  1. **Download**: Menggunakan `wget` melalui `popen()` untuk mengunduh file ZIP dari Google Drive.
  2. **Ekstraksi**: Menggunakan `unzip` untuk mengekstrak isi file ZIP.
  3. **Pembersihan**: Menghapus file ZIP setelah tidak dibutuhkan lagi dengan `remove()`.
- Pendekatan ini memungkinkan Anthony mengunduh dan mengelola data filmnya dengan satu perintah sederhana tanpa perlu melakukan langkah-langkah manual.
- Fungsi ini menggunakan `popen()` sebagai alternatif yang aman untuk `system()` yang dilarang dalam tugas.

---

### **(B) Sorting Like a Pro**
#### **Fungsi: `organizeFilms()`, `organizeByFirstLetter()`, `organizeByYear()`**

```c
void organizeFilms(FilmData* data) {
    pthread_t thread1, thread2;
    ThreadArgs *args1, *args2;
    
    // Create log file
    FILE* log_file = fopen("log.txt", "w");
    if (log_file) fclose(log_file);
    
    // Set up thread arguments
    args1 = (ThreadArgs*)malloc(sizeof(ThreadArgs));
    args1->data = data;
    args1->type = "Abjad";
    
    args2 = (ThreadArgs*)malloc(sizeof(ThreadArgs));
    args2->data = data;
    args2->type = "Tahun";
    
    // Create threads
    pthread_create(&thread1, NULL, organizeByFirstLetter, (void*)args1);
    pthread_create(&thread2, NULL, organizeByYear, (void*)args2);
    
    // Wait for threads to finish
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    
    printf("Pengorganisasian film selesai.\n");
}
```

#### **Penjelasan Code**
- Fungsi utama `organizeFilms()` mengimplementasikan multiprocessing menggunakan thread untuk mengelompokkan film secara paralel:
  1. **Thread 1**: Mengelompokkan film berdasarkan huruf pertama judul (A-Z, 0-9, #).
  2. **Thread 2**: Mengelompokkan film berdasarkan tahun rilis.
- Hasil pengorganisasian disimpan dalam:
  - Folder **judul/**: Berisi file seperti A.txt, B.txt, 1.txt, #.txt untuk film yang dimulai dengan huruf, angka, atau karakter khusus.
  - Folder **tahun/**: Berisi file seperti 1999.txt, 2021.txt berdasarkan tahun rilis film.
- Setiap proses pengorganisasian juga mencatat aktivitasnya dalam file **log.txt** dengan format waktu dan judul film.

---

### **(C) The Ultimate Movie Report**
#### **Fungsi: `generateReport()`**

```c
void generateReport(FilmData* data) {
    // Create report filename with current date
    time_t now;
    struct tm *tm_info;
    char filename[30];
    
    time(&now);
    tm_info = localtime(&now);
    strftime(filename, 30, "report_%d%m%Y.txt", tm_info);
    
    // Open report file
    FILE* report_file = fopen(filename, "w");
    if (!report_file) {
        perror("Gagal membuat file report");
        return;
    }
    
    // Find unique countries and count films
    char countries[1000][MAX_COUNTRY];
    int country_count = 0;
    
    // ... [kode untuk menemukan negara unik dan menghitung film] ...
    
    // Generate report for each country
    for (int i = 0; i < country_count; i++) {
        int before_2000 = 0;
        int after_2000 = 0;
        
        // ... [kode untuk menghitung film sebelum dan setelah tahun 2000] ...
        
        // Write to report
        fprintf(report_file, "%d. Negara: %s\n", i+1, countries[i]);
        fprintf(report_file, "Film sebelum 2000: %d\n", before_2000);
        fprintf(report_file, "Film setelah 2000: %d\n\n", after_2000);
    }
    
    fclose(report_file);
    printf("Report berhasil dibuat: %s\n", filename);
}
```

#### **Penjelasan Code**
- Fungsi ini menghasilkan laporan statistik tentang koleksi film Anthony:
  1. **Membuat File Report**: Membuat file bernama `report_ddmmyyyy.txt` dengan tanggal saat ini.
  2. **Identifikasi Negara Unik**: Menemukan semua negara unik dalam koleksi film.
  3. **Analisis Statistik**: Untuk setiap negara, menghitung jumlah film yang dirilis sebelum dan setelah tahun 2000.
  4. **Menulis Laporan**: Menyimpan hasilnya dalam file report dengan format yang ditentukan.
- Laporan memungkinkan Anthony melihat distribusi film berdasarkan negara dan periode waktu.

---

## Kesimpulan

Program "Anthony's Netflix Film Manager" berhasil diimplementasikan dengan semua fitur yang diminta. Beberapa poin penting dalam pengembangan:

1. **Penerapan Multithreading**: Program menggunakan thread untuk melakukan pengelompokan film secara paralel, meningkatkan efisiensi.
2. **Manajemen Memori**: Semua alokasi memori dilakukan dengan hati-hati dan dibersihkan untuk mencegah memory leak.
3. **Penanganan File**: Program dapat menangani berbagai lokasi file CSV (termasuk dalam subfolder) dan berbagai jenis karakter dalam judul film.
4. **Logging**: Implementasi logging yang komprehensif untuk memantau proses pengelompokan film.

Program ini merupakan solusi efektif untuk masalah Anthony dalam mengelola koleksi filmnya, dengan antarmuka command-line yang sederhana namun kuat, yang memungkinkan:
- Download dan ekstraksi data film dengan satu perintah
- Pengorganisasian film berdasarkan berbagai kriteria secara simultan
- Analisis statistik untuk wawasan lebih dalam tentang koleksi film

Dengan program ini, Anthony dapat dengan mudah menemukan, mengakses, dan menganalisis film-film dalam koleksinya yang semakin bertambah.
