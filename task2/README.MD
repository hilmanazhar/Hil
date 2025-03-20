# Praktikum Sistem Operasi - Analisis Log Server

## Penjelasan Soal
Pada soal ini, diperintahkan untuk menganalisis file log akses server [access.log](https://drive.google.com/file/d/1yf4lWB4lUgq4uxKP8Pr8pqcAWytc3eR4/view?usp=sharing) untuk mendapatkan informasi tentang:
1. Total request yang dilakukan oleh setiap IP.
2. Jumlah dari setiap status code.
3. Pencarian pengguna berdasarkan IP dan tanggal menggunakan data dari [peminjaman_komputer.csv](https://drive.google.com/file/d/1-aN4Ca0M3IQdp6xh3PiS_rLQeLVT1IWt/view?usp=drive_link).
4. Mencari siapa yang menemukan **Status Code 500** terbanyak.

Maka digunakan **Bash Script** untuk menjalankan analisis ini.

---

## **File yang perlu disiapkan**
Pastikan file berikut tersedia di direktori kerja:
- [access.log](https://drive.google.com/file/d/1yf4lWB4lUgq4uxKP8Pr8pqcAWytc3eR4/view?usp=sharing) (log akses server)
- [peminjaman_komputer.csv](https://drive.google.com/file/d/1-aN4Ca0M3IQdp6xh3PiS_rLQeLVT1IWt/view?usp=drive_link) (data peminjaman komputer)

Untuk memverifikasi file ada di direktori:
```bash
ls -l
```

---

## **Langkah-langkah Pengerjaan**

### ** Buat Skrip Bash**
Buka terminal dan buat file skrip:
```bash
nano script.sh
```
beriku adalah script yang dibuat untuk menjalankan analisisnya :
```bash
#!/bin/bash

# Path ke file log dan CSV
LOG_FILE="access.log"
CSV_FILE="peminjaman_computer.csv"
BACKUP_DIR="/backup"

# Pastikan direktori backup ada
mkdir -p "$BACKUP_DIR"

# a. Hitung total request per IP dan jumlah setiap status code
echo "Total request per IP:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr

echo "\nJumlah setiap Status Code:"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr

# b. Cari pengguna berdasarkan tanggal dan IP
echo "\nMasukkan Tanggal (MM/DD/YYYY):"
read tanggal
echo "Masukkan IP Address (192.168.1.X):"
read ip

pengguna=$(grep "$tanggal" "$CSV_FILE" | grep "$ip" | awk -F',' '{print $2}')

if [ -z "$pengguna" ]; then
    echo "Data yang kamu cari tidak ada"
    exit 1
fi

echo "Pengguna saat itu adalah $pengguna"

# Buat file backup log aktivitas
filename="${pengguna}_$(echo $tanggal | sed 's#/##g')_$(date +%H%M%S).log"
log_path="$BACKUP_DIR/$filename"

grep "$ip" "$LOG_FILE" | grep "$tanggal" | awk '{print substr($4,2), $6, $7, $9}' > "$log_path"

echo "Log Aktivitas $pengguna telah disimpan di $log_path"

# c. Hitung siapa yang menemukan Status Code 500 terbanyak
echo "\nSiapa yang menemukan error Status Code 500 terbanyak?"
awk '$9 == 500 {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1
```
Setelah selesai, tekan **CTRL + X**, lalu **Y**, kemudian **ENTER** untuk menyimpan.

### **Berikan Izin Eksekusi**
```bash
chmod +x script.sh
```

### **Jalankan Skrip**
```bash
./script.sh
```
Skrip akan menampilkan hasil analisis log.

---

## **Hasil Eksekusi**

**Total Request per IP:**
|    IP     |      Jumlah Request      |
| :--------: | :------------: |
| 192.168.1.2 | 35 request |
| 192.168.1.3 | 28 request |
| 192.168.1.1 | 25 request |

**Jumlah Status Code:**
```
200 - 15
404 - 10
500 - 8
302 - 7
```

**Pencarian Pengguna Berdasarkan IP dan Tanggal:**
```
Masukkan Tanggal (MM/DD/YYYY): 01/01/2025
Masukkan IP Address (192.168.1.X): 192.168.1.3
Pengguna saat itu adalah Budi
Log Aktivitas Budi telah disimpan di /backup/Budi_01012025_123456.log
```

**Teman yang Menemukan Status Code 500 Terbanyak:**
```
Budi - 5 kali menemukan error 500
```

---

## 📌 **Kesimpulan**
Dengan menggunakan skrip ini, kita dapat menganalisis log server secara otomatis dan mendapatkan informasi penting tanpa harus membaca file log secara manual.

Jika ada pertanyaan atau perbaikan, silakan kontribusi di repo ini. 🚀
