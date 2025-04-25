#task 2 - Organize and Analyze Anthony's Favorite Films
## Penjelasan Soal
Anthony sedang asyik menonton film favoritnya dari Netflix, namun seiring berjalannya waktu, koleksi filmnya semakin menumpuk. Ia pun memutuskan untuk membuat sistem agar film-film favoritnya bisa lebih terorganisir dan mudah diakses. Dalam tugas ini, kami diminta untuk membantu Anthony dengan membuat program C untuk mengorganisir dan menganalisis film-film Netflix favorit Anthony melalui 3 fitur utama:

1. **(A) One Click and Done!** - Mengotomatisasi proses download, ekstraksi, dan pembersihan file ZIP yang berisi data film-film Netflix.
2. **(B) Sorting Like a Pro** - Mengelompokkan film secara paralel berdasarkan huruf pertama judul dan tahun rilis menggunakan multithreading.
3. **(C) The Ultimate Movie Report** - Membuat laporan statistik film berdasarkan negara yang menunjukkan jumlah film sebelum dan setelah tahun 2000.

---

## Langkah-langkah Pengerjaan

### Data yang perlu disiapkan
- Program `anthony.c` yang berisi implementasi dari semua fitur yang diminta
- File data film dalam format CSV yang diunduh dari file ZIP di Google Drive
- Library yang dibutuhkan:
  - stdio.h, stdlib.h, string.h, unistd.h, time.h - Untuk manajemen file dan waktu
  - sys/types.h, sys/stat.h, sys/wait.h - Untuk operasi sistem
  - pthread.h - Untuk implementasi multithreading
  - ctype.h - Untuk fungsi penanganan karakter
  - dirent.h - Untuk membaca direktori

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

#### **Penjelasan Code**
- **Download File:**
  - Menggunakan `wget` melalui fungsi `popen()` untuk mengunduh file ZIP dari URL Google Drive
  - Menggunakan `snprintf()` untuk membuat string perintah yang aman
  - Memeriksa keberhasilan download dengan fungsi `access()`

- **Ekstraksi File:**
  - Menggunakan perintah `unzip -o` untuk mengekstrak file ZIP
  - Parameter `-o` digunakan untuk menimpa file yang sudah ada jika diperlukan
  - Menampilkan output dari proses ekstraksi ke konsol

- **Debugging dan Verifikasi:**
  - Menggunakan fungsi `listFilesInDirectory()` untuk melihat isi direktori saat ini
  - Memeriksa keberadaan folder extracted dan menampilkan isinya jika ada

- **Pembersihan:**
  - Menghapus file ZIP yang sudah diekstrak menggunakan fungsi `remove()`
  - Memberikan pesan error jika penghapusan gagal

---

### **(B) Sorting Like a Pro**
#### **Fungsi: `organizeFilms()`, `organizeByFirstLetter()`, `organizeByYear()` dan fungsi tambahan**

```c
void createDirectoryIfNotExists(const char* dir) {
    struct stat st = {0};
    if (stat(dir, &st) == -1) {
        mkdir(dir, 0700);
    }
}

void writeLog(const char* type, const char* title) {
    time_t now;
    struct tm *tm_info;
    char timestamp[20];
    
    time(&now);
    tm_info = localtime(&now);
    strftime(timestamp, 20, "[%H:%M:%S]", tm_info);
    
    FILE* log_file = fopen("log.txt", "a");
    if (log_file) {
        fprintf(log_file, "%s Proses mengelompokkan berdasarkan %s: sedang mengelompokkan untuk film %s\n", 
                timestamp, type, title);
        fclose(log_file);
    }
}

void* organizeByFirstLetter(void* args) {
    ThreadArgs* thread_args = (ThreadArgs*)args;
    FilmData* data = thread_args->data;
    
    createDirectoryIfNotExists("judul");
    
    char filename[20];
    
    for (char c = 'A'; c <= 'Z'; c++) {
        sprintf(filename, "judul/%c.txt", c);
        FILE* file = fopen(filename, "w");
        if (file) fclose(file);
    }
    
    for (char c = '0'; c <= '9'; c++) {
        sprintf(filename, "judul/%c.txt", c);
        FILE* file = fopen(filename, "w");
        if (file) fclose(file);
    }
    
    FILE* other_file = fopen("judul/#.txt", "w");
    if (other_file) fclose(other_file);
    
    for (int i = 0; i < data->count; i++) {
        char first_char = data->films[i].title[0];
        if (isalpha(first_char)) {
            first_char = toupper(first_char);
            sprintf(filename, "judul/%c.txt", first_char);
        } else if (isdigit(first_char)) {
            sprintf(filename, "judul/%c.txt", first_char);
        } else {
            strcpy(filename, "judul/#.txt");
        }
        
        FILE* file = fopen(filename, "a");
        if (file) {
            fprintf(file, "%s - %d - %s\n", 
                    data->films[i].title, 
                    data->films[i].release_year, 
                    data->films[i].director);
            fclose(file);
        }
        
        writeLog("Abjad", data->films[i].title);
    }
    
    printf("Pengorganisasian berdasarkan huruf pertama selesai.\n");
    free(thread_args);
    return NULL;
}

void* organizeByYear(void* args) {
    ThreadArgs* thread_args = (ThreadArgs*)args;
    FilmData* data = thread_args->data;
    
    createDirectoryIfNotExists("tahun");
    
    for (int i = 0; i < data->count; i++) {
        char filename[20];
        sprintf(filename, "tahun/%d.txt", data->films[i].release_year);
        
        FILE* file = fopen(filename, "a");
        if (file) {
            fprintf(file, "%s - %d - %s\n", 
                    data->films[i].title, 
                    data->films[i].release_year, 
                    data->films[i].director);
            fclose(file);
        }
        
        writeLog("Tahun", data->films[i].title);
    }
    
    printf("Pengorganisasian berdasarkan tahun selesai.\n");
    free(thread_args);
    return NULL;
}

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
- **Fungsi `createDirectoryIfNotExists()`**:
  - Memeriksa apakah direktori sudah ada menggunakan `stat()`
  - Membuat direktori baru dengan izin 0700 jika belum ada

- **Fungsi `writeLog()`**:
  - Mencatat aktivitas pengorganisasian ke file log.txt
  - Menggunakan `localtime()` dan `strftime()` untuk format waktu
  - Format log: `[jam:menit:detik] Proses mengelompokkan berdasarkan [Abjad/Tahun]: sedang mengelompokkan untuk film [judul_film]`

- **Fungsi `organizeByFirstLetter()`**:
  - Berjalan dalam thread terpisah untuk pengorganisasian berdasarkan huruf pertama
  - Membuat direktori "judul" dan file untuk setiap huruf A-Z, angka 0-9, dan karakter khusus (#)
  - Memeriksa huruf pertama dari tiap judul film:
    - Jika huruf (A-Z, a-z), dikonversi ke huruf kapital dan disimpan ke file yang sesuai
    - Jika angka (0-9), disimpan ke file angka yang sesuai
    - Jika karakter lain (spesial, non-ASCII, tanda kutip), disimpan ke #.txt
  - Mencatat setiap aktivitas ke log.txt

- **Fungsi `organizeByYear()`**:
  - Berjalan dalam thread terpisah untuk pengorganisasian berdasarkan tahun rilis
  - Membuat direktori "tahun"
  - Mengelompokkan film berdasarkan tahun rilis ke file seperti 1999.txt, 2021.txt, dll
  - Mencatat setiap aktivitas ke log.txt

- **Fungsi `organizeFilms()`**:
  - Fungsi utama yang mengatur proses paralelisasi
  - Membuat dan menginisialisasi file log.txt
  - Menyiapkan argumen untuk thread dengan alokasi memori yang aman
  - Membuat dua thread menggunakan `pthread_create()`:
    1. Thread untuk pengorganisasian berdasarkan huruf pertama judul
    2. Thread untuk pengorganisasian berdasarkan tahun rilis
  - Menunggu kedua thread selesai dengan `pthread_join()`

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

#### **Penjelasan Code**
- **Pembuatan Nama File Laporan**:
  - Menggunakan tanggal saat ini untuk membuat nama file unik: `report_ddmmyyyy.txt`
  - Menggunakan `strftime()` untuk format tanggal yang benar

- **Ekstraksi Negara Unik**:
  - Membuat array untuk menyimpan nama negara unik
  - Iterasi melalui semua film dan memeriksa apakah negara sudah ada di array
  - Menambahkan negara baru ke array jika belum ada

- **Analisis Statistik**:
  - Untuk setiap negara, menghitung jumlah film berdasarkan tahun rilis:
    - Film yang dirilis sebelum tahun 2000
    - Film yang dirilis pada atau setelah tahun 2000 (sesuai klarifikasi bahwa film tahun 2000 masuk hitungan "setelah 2000")

- **Penulisan Laporan**:
  - Menulis hasil ke file dengan format yang rapi:
    ```
    i. Negara: <nama_negara>
    Film sebelum 2000: <jumlah>
    Film setelah 2000: <jumlah>

    i+1. Negara: <nama_negara>
    Film sebelum 2000: <jumlah>
    Film setelah 2000: <jumlah>
    ```

---

### Fungsi Tambahan
#### **Fungsi: `readCSVData()`**

```c
FilmData* readCSVData() {
    FILE* file = NULL;
    char filepath[300];
    
    char cwd[256];
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        printf("Current working directory: %s\n", cwd);
    }
    
    const char* possible_locations[] = {
        CSV_FILE,                           
        EXTRACTED_FOLDER "/" CSV_FILE,       
        "../" CSV_FILE,                     
        "../" EXTRACTED_FOLDER "/" CSV_FILE,
        "extracted/" CSV_FILE          
    };
    
    int num_locations = sizeof(possible_locations) / sizeof(possible_locations[0]);
    
    for (int i = 0; i < num_locations; i++) {
        printf("Mencoba membuka file: %s\n", possible_locations[i]);
        file = fopen(possible_locations[i], "r");
        if (file) {
            printf("File ditemukan di: %s\n", possible_locations[i]);
            strcpy(filepath, possible_locations[i]);
            break;
        }
    }
    
    if (!file) {
        printf("Mencari file CSV di direktori saat ini dan subdirektori...\n");
        perror("Gagal membuka file CSV");
        return NULL;
    }
    
    int line_count = 0;
    char line[MAX_LINE];
    
    fgets(line, MAX_LINE, file);
    
    while (fgets(line, MAX_LINE, file) != NULL) {
        line_count++;
    }
    
    rewind(file);
    
    fgets(line, MAX_LINE, file);
    
    FilmData* data = (FilmData*)malloc(sizeof(FilmData));
    if (!data) {
        perror("Gagal mengalokasikan memori");
        fclose(file);
        return NULL;
    }
    
    data->count = line_count;
    data->films = (Film*)malloc(line_count * sizeof(Film));
    if (!data->films) {
        perror("Gagal mengalokasikan memori untuk film");
        free(data);
        fclose(file);
        return NULL;
    }
    
    int i = 0;
    while (fgets(line, MAX_LINE, file) != NULL && i < line_count) {
        char* token;
        token = strtok(line, ",");
        if (token) strncpy(data->films[i].title, token, MAX_TITLE - 1);
        
        token = strtok(NULL, ",");
        if (token) strncpy(data->films[i].director, token, MAX_DIRECTOR - 1);
        
        token = strtok(NULL, ",");
        if (token) strncpy(data->films[i].country, token, MAX_COUNTRY - 1);
        
        token = strtok(NULL, ",");
        if (token) data->films[i].release_year = atoi(token);
        
        i++;
    }
    
    fclose(file);
    printf("Berhasil membaca %d film dari file CSV.\n", data->count);
    return data;
}
```

#### **Penjelasan Code**
- **Pencarian File CSV**:
  - Mencoba beberapa kemungkinan lokasi file CSV
  - Menampilkan direktori kerja saat ini untuk debugging
  - Memberikan pesan ketika file ditemukan

- **Menghitung Jumlah Film**:
  - Melewati header file CSV
  - Menghitung jumlah baris (film) dalam file

- **Alokasi Memori**:
  - Mengalokasikan memori untuk struktur FilmData
  - Mengalokasikan memori untuk array film
  - Penanganan error jika alokasi gagal

- **Parsing Data CSV**:
  - Membaca file CSV baris per baris
  - Memproses setiap token dengan `strtok()` untuk memisahkan data berdasarkan koma
  - Menyimpan data ke struktur Film (judul, sutradara, negara, tahun rilis)

#### **Fungsi: `main()`**

```c
int main() {
    int choice;
    FilmData* filmData = NULL;
    
    while (1) {
        printf("\n=== Anthony's Netflix Film Manager ===\n");
        printf("1. Download File\n");
        printf("2. Mengelompokkan Film\n");
        printf("3. Membuat Report\n");
        printf("4. Exit\n");
        printf("Pilihan: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                downloadAndExtract();
                break;
            case 2:
                if (filmData) {
                    cleanFilmData(filmData);
                }
                filmData = readCSVData();
                if (filmData) {
                    organizeFilms(filmData);
                }
                break;
            case 3:
                if (!filmData) {
                    filmData = readCSVData();
                }
                if (filmData) {
                    generateReport(filmData);
                }
                break;
            case 4:
                if (filmData) {
                    cleanFilmData(filmData);
                }
                return 0;
            default:
                printf("Pilihan tidak valid. Silakan coba lagi.\n");
        }
    }
    
    return 0;
}
```

#### **Penjelasan Code**

- **Pilihan Program**:
  - Pilihan 1: Menjalankan fungsi download dan ekstraksi
  - Pilihan 2: Membaca data CSV dan mengelompokkan film
  - Pilihan 3: Membuat laporan statistik (membaca data jika belum)
  - Pilihan 4: Membersihkan memori dan keluar dari program

---
