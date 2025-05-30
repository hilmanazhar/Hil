## task 2 - Organize and Analyze Anthony's Favorite Films
### Penjelasan Soal
Anthony sedang asyik menonton film favoritnya dari Netflix, namun seiring berjalannya waktu, koleksi filmnya semakin menumpuk. Ia pun memutuskan untuk membuat sistem agar film-film favoritnya bisa lebih terorganisir dan mudah diakses. Dalam tugas ini, kami diminta untuk membantu Anthony dengan membuat program C untuk mengorganisir dan menganalisis film-film Netflix favorit Anthony melalui 3 fitur utama:

1. **(A) One Click and Done!** - Mengotomatisasi proses download, ekstraksi, dan pembersihan file ZIP yang berisi data film-film Netflix.
2. **(B) Sorting Like a Pro** - Mengelompokkan film secara paralel berdasarkan huruf pertama judul dan tahun rilis menggunakan multithreading.
3. **(C) The Ultimate Movie Report** - Membuat laporan statistik film berdasarkan negara yang menunjukkan jumlah film sebelum dan setelah tahun 2000.

---

### a. One Click and Done!
pertama kita perlu membuat file `.c` bernama anthony.c 

(fungsi downloadAndExtract)
1. Menggunakan `wget` melalui `popen()` untuk mengunduh file ZIP dari Google Drive.
2. Memverifikasi keberhasilan download dengan memeriksa keberadaan file ZIP.
3. Menggunakan `unzip` untuk mengekstrak isi file, menampilkan output ekstraksi ke konsol.
4. Mencari dan memeriksa keberadaan file CSV di berbagai lokasi.
5. Menghapus file ZIP yang sudah diekstrak menggunakan `remove()`.

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
    
    if (access(ZIP_FILE, F_OK) != 0) {
        printf("Error: File ZIP tidak ditemukan setelah download.\n");
        return;
    }
    
    printf("Mengekstrak file ZIP...\n");
    
    char extract_cmd[512];
    char output[4096];
    
    snprintf(extract_cmd, sizeof(extract_cmd), "unzip -o %s", ZIP_FILE);
    
    FILE* extract_pipe = popen(extract_cmd, "r");
    if (!extract_pipe) {
        perror("Gagal mengekstrak file");
        return;
    }
    
    while (fgets(output, sizeof(output), extract_pipe) != NULL) {
        printf("%s", output);
    }
    
    pclose(extract_pipe);
    
    printf("File berhasil diekstrak.\n");
    
    listFilesInDirectory(".");
    
    struct stat st = {0};
    if (stat(EXTRACTED_FOLDER, &st) == 0) {
        listFilesInDirectory(EXTRACTED_FOLDER);
    } else {
        printf("Folder '%s' tidak ditemukan setelah ekstraksi.\n", EXTRACTED_FOLDER);
    }
    
    printf("Menghapus file ZIP...\n");
    
    if (remove(ZIP_FILE) != 0) {
        perror("Gagal menghapus file ZIP");
        return;
    }
    
    printf("File ZIP berhasil dihapus.\n");
}
```

#### contoh output:
```
=== Anthony's Netflix Film Manager ===
1. Download File
2. Mengelompokkan Film
3. Membuat Report
4. Exit
Pilihan: 1
Mendownload file ZIP dari Google Drive...
File ZIP berhasil didownload.
Mengekstrak file ZIP...
File berhasil diekstrak.
Menghapus file ZIP...
File ZIP berhasil dihapus.
```
---
### b. Sorting Like a Pro
(fungsi organizeFilms, organizeByFirstLetter, organizeByYear)
1. Membuat fungsi `organizeFilms()` yang menggunakan multithreading untuk menjalankan dua proses pengorganisasian secara paralel.
2. Fungsi `organizeByFirstLetter()` mengelompokkan film berdasarkan huruf pertama judulnya:
   - Membuat folder "judul/" dan file A-Z.txt, 0-9.txt, dan #.txt
   - Mengidentifikasi huruf pertama dari judul film menggunakan `isalpha()` dan `isdigit()`
   - Menyimpan film dengan karakter khusus (termasuk tanda kutip, karakter non-ASCII) ke #.txt
3. Fungsi `organizeByYear()` mengelompokkan film berdasarkan tahun rilis.
4. Mencatat setiap aktivitas pengorganisasian ke file log.txt dengan timestamp.

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

#### contoh output:
```
=== Anthony's Netflix Film Manager ===
1. Download File
2. Mengelompokkan Film
3. Membuat Report
4. Exit
Pilihan: 2
Current working directory: /home/user/project
Mencoba membuka file: netflixData.csv
File ditemukan di: netflixData.csv
Berhasil membaca 5332 film dari file CSV.
Pengorganisasian berdasarkan huruf pertama selesai.
Pengorganisasian berdasarkan tahun selesai.
Pengorganisasian film selesai.
```
---
### c. The Ultimate Movie Report
(fungsi generateReport)
1. Membuat nama file laporan dengan format report_ddmmyyyy.txt menggunakan `strftime()`.
2. Menemukan semua negara unik dalam data film dengan algoritma pencarian.
3. Untuk setiap negara, menghitung:
   - Jumlah film yang dirilis sebelum tahun 2000
   - Jumlah film yang dirilis pada atau setelah tahun 2000
4. Menyimpan hasil statistik ke file laporan dengan format yang rapi.

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
    
    for (int i = 0; i < data->count; i++) {
        int found = 0;
        for (int j = 0; j < country_count; j++) {
            if (strcmp(data->films[i].country, countries[j]) == 0) {
                found = 1;
                break;
            }
        }
        
        if (!found) {
            strcpy(countries[country_count], data->films[i].country);
            country_count++;
        }
    }
    
    for (int i = 0; i < country_count; i++) {
        int before_2000 = 0;
        int after_2000 = 0;
        
        for (int j = 0; j < data->count; j++) {
            if (strcmp(data->films[j].country, countries[i]) == 0) {
                if (data->films[j].release_year < 2000) {
                    before_2000++;
                } else {
                    after_2000++;
                }
            }
        }
        
        fprintf(report_file, "%d. Negara: %s\n", i+1, countries[i]);
        fprintf(report_file, "Film sebelum 2000: %d\n", before_2000);
        fprintf(report_file, "Film setelah 2000: %d\n\n", after_2000);
    }
    
    fclose(report_file);
    printf("Report berhasil dibuat: %s\n", filename);
}
```

#### contoh output:
```
=== Anthony's Netflix Film Manager ===
1. Download File
2. Mengelompokkan Film
3. Membuat Report
4. Exit
Pilihan: 3
Current working directory: /home/user/project
Mencoba membuka file: netflixData.csv
File ditemukan di: netflixData.csv
Berhasil membaca 5332 film dari file CSV.
Report berhasil dibuat: report_25042025.txt
```
---
### Fungsi Tambahan
(fungsi readCSVData, createDirectoryIfNotExists, writeLog, cleanFilmData)
1. Fungsi `readCSVData()`:
   - Mencari file CSV di berbagai lokasi (direktori saat ini, subfolder extracted)
   - Membaca dan parsing data film dari CSV ke struktur data
   - Menangani alokasi memori dan error dengan baik
2. Fungsi `createDirectoryIfNotExists()`: Memastikan direktori yang diperlukan tersedia
3. Fungsi `writeLog()`: Mencatat aktivitas dengan format timestamp yang tepat
4. Fungsi `cleanFilmData()`: Membersihkan memori yang dialokasikan untuk data film

#### contoh output:
```
=== Anthony's Netflix Film Manager ===
1. Download File
2. Mengelompokkan Film
3. Membuat Report
4. Exit
Pilihan: 4
```
program telah selesai dijalankan
