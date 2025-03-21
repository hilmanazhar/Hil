# Laporan Praktikum Sistem Operasi


## Penjelasan soal
Rudi membuat website untuk personal branding yang berjalan secara lokal di komputer laboratorium. Karena sering mengalami error, ia meminta bantuan tiga temannya: Andi, Budi, dan Caca untuk mengecek log aksesnya. Praktikum ini bertujuan untuk menganalisis file `access.log` dan `peminjaman_computer.csv` untuk mendapatkan informasi berikut:

1. **(A)** Total request dari setiap IP dan jumlah setiap status code.
2. **(B)** Mencari pengguna komputer berdasarkan tanggal dan IP serta menyimpan log aktivitas.
3. **(C)** Menemukan siapa yang menemukan error `Status Code 500` terbanyak dan menentukan pemenang hadiah.

---

## Langkah-langkah Pengerjaan

### Data yang perlu disiapkan
- Download file yang dibutuhkan:
  - `access.log` (log akses dari website Rudi)
  - `peminjaman_computer.csv` (data peminjaman komputer)
- Pastikan kedua file disimpan dalam direktori yang akan digunakan.
- Tiga file script Bash yang akan dibuat :
  - `rudi-a.sh` → Untuk analisis total request dan status code.
  - `rudi-b.sh` → Untuk mencari pengguna komputer dan menyimpan log aktivitas.
  - `rudi-c.sh` → Untuk menentukan pemenang berdasarkan status code `500`.
---
### **(A) Menampilkan Total Request per IP & Jumlah Status Code**
#### **Script: `rudi-a.sh`**
```bash
#!/bin/bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr > ip_count.txt
awk '{print $9}' access.log | sort | uniq -c | sort -nr > status_count.txt
echo "Total request per IP:"
cat ip_count.txt
echo "Jumlah setiap status code:"
cat status_count.txt
```
#### **Penjelasan Code**

#### **Output Contoh:**
```
Total request per IP:
  38597 192.168.1.1
  38453 192.168.1.2
  38450 192.168.1.3
Jumlah setiap status code:
  29087 200
  28896 302
  28882 500
  28635 404
```
---

### **(B) Mencari Pengguna Berdasarkan IP & Tanggal dan Membuat Backup Log**
#### **Script: `rudi-b.sh`**
```bash
./rudi-b.sh
```
#### Script `rudi-b.sh`
```bash
#!/bin/bash
echo -n "Masukkan Tanggal (MM/DD/YYYY): "
read date
echo -n "Masukkan IP Address (192.168.1.X): "
read ip

user=$(awk -F, -v date="$date" -v ip="$ip" '$1==date && $2==ip {print $3}' peminjaman_computer.csv)

if [ -z "$user" ]; then
    echo "Data yang kamu cari tidak ada"
    exit 1
fi

echo "Pengguna saat itu adalah $user"

mkdir -p /backup
log_file="/backup/${user}_$(echo $date | tr -d '/')_$(date +%H%M%S).log"
grep "$ip" access.log | awk '{print $4 " " $6 " " $7 " " $9}' > "$log_file"
echo "Log Aktivitas $user telah disimpan di $log_file"
```

#### **Penjelasan Code**


#### **Output Contoh:**
```
Masukkan Tanggal (MM/DD/YYYY): 01/01/2025
Masukkan IP Address (192.168.1.3): 3
Pengguna saat itu adalah Caca
Log Aktivitas Caca telah disimpan di /backup/Caca_01012025_215820.log
```
---

### **(C) Menentukan Pemenang dengan Status Code 500 Terbanyak**
#### **Script: `rudi-c.sh`**
#!/bin/bash

LOG_FILE="access.log"
CSV_FILE="peminjaman_computer.csv"

echo "Siapa yang menemukan error Status Code 500 terbanyak?"

# Hitung jumlah Status Code 500 per IP
top_ip=$(grep " 500 " "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 1)

jumlah=$(echo "$top_ip" | awk '{print $1}')
ip_pemenang=$(echo "$top_ip" | awk '{print $2}')

# Konversi IP ke nomor komputer
nomor_komputer=$(echo "$ip_pemenang" | awk -F'.' '{print $4}')

# Cari pengguna berdasarkan nomor komputer
pemenang=$(awk -F',' -v komputer="$nomor_komputer" '$2 == komputer {print $3}' "$CSV_FILE" | head -n 1)

echo "Pemenangnya adalah $pemenang dari komputer $nomor_komputer ($ip_pemenang), menemukan $jumlah error."

#### **Penjelasan Code**

#### **Output Contoh:**
```
Siapa yang menemukan error Status Code 500 terbanyak?
Pemenangnya adalah Andi dari komputer 2 (192.168.1.2), menemukan 9773 error.
```

---

## Kesimpulan

**Total Request per IP:**
|    IP     |      Jumlah Request      |
| :--------: | :------------: |
| 192.168.1.2 | 35 request |
| 192.168.1.3 | 28 request |
| 192.168.1.1 | 25 request |

**Jumlah Status Code:**
|    Status Code     |      Jumlah      |
| :--------: | :------------: |
| 200 | 29087 |
| 302 | 28896 |
| 500 | 28882 |
| 404 | 28635 |



Dengan menggunakan script Bash, kita dapat dengan mudah menganalisis file log dan melakukan berbagai pemrosesan data secara otomatis. Script ini membantu Rudi dalam mengelola data akses websitenya dengan lebih efisien.

