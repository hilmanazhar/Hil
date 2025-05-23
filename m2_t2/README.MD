
# Laporan Praktikum Sistem Operasi

# task 2 - Organize and Analyze Anthony's Favorite Films

## Penjelasan Soal
Anthony sedang menonton film-film favorit dari Netflix, namun koleksinya semakin menumpuk seiring waktu. Dia memutuskan untuk membuat sistem agar film-film tersebut lebih terorganisir dan mudah diakses. Program ini dibuat dengan tujuan untuk membantu Anthony mengelola koleksi filmnya dengan fitur-fitur berikut:

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
    
    FILE* log_file = fopen("log.txt", "w");
    if (log_file) fclose(log_file);
    
    args1 = (ThreadArgs*)malloc(sizeof(ThreadArgs));
    args1->data = data;
    args1->type = "Abjad";
    
    args2 = (ThreadArgs*)malloc(sizeof(ThreadArgs));
    args2->data = data;
    args2->type = "Tahun";
    
    pthread_create(&thread1, NULL, organizeByFirstLetter, (void*)args1);
    pthread_create(&thread2, NULL, organizeByYear, (void*)args2);
    
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
    time_t now;
    struct tm *tm_info;
    char filename[30];
    
    time(&now);
    tm_info = localtime(&now);
    strftime(filename, 30, "report_%d%m%Y.txt", tm_info);
    
    FILE* report_file = fopen(filename, "w");
    if (!report_file) {
        perror("Gagal membuat file report");
        return;
    }
    
    char countries[1000][MAX_COUNTRY];
    int country_count = 0;
        
    for (int i = 0; i < country_count; i++) {
        int before_2000 = 0;
        int after_2000 = 0;
                
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
