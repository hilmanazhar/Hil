# Laporan Praktikum Sistem Operasi

## Deskripsi
Tugas ini bertujuan untuk menganalisis file log akses website Rudi dan mengolahnya menggunakan script Bash. Ada tiga bagian utama dalam tugas ini:

1. **Menampilkan total request per IP dan jumlah dari setiap status code.**
2. **Mencari pengguna yang mengalami error dan menyimpan log aktivitas mereka.**
3. **Menentukan siapa yang menemukan error status code 500 terbanyak.**

---

## Langkah-langkah Pengerjaan

### 1. Menampilkan Total Request per IP dan Jumlah Status Code
#### Command:
```bash
./rudi-a.sh
```
#### Script `rudi-a.sh`
```bash
#!/bin/bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr > ip_count.txt
awk '{print $9}' access.log | sort | uniq -c | sort -nr > status_count.txt
echo "Total request per IP:"
cat ip_count.txt
echo "Jumlah setiap status code:"
cat status_count.txt
```
#### Hasil Output:
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

### 2. Mencari Pengguna yang Mengalami Error dan Membuat Backup Log
#### Command:
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
#### Hasil Output:
```
Masukkan Tanggal (MM/DD/YYYY): 01/01/2025
Masukkan IP Address (192.168.1.3): 3
Pengguna saat itu adalah Caca
Log Aktivitas Caca telah disimpan di /backup/Caca_01012025_215820.log
```

---

### 3. Menentukan Teman yang Menemukan Status Code 500 Terbanyak
#### Command:
```bash
./rudi-c.sh
```
#### Script `rudi-c.sh`
```bash
#!/bin/bash
echo "Siapa yang menemukan error Status Code 500 terbanyak?"
awk '$9 == 500 {print $1}' access.log | sort | uniq -c | sort -nr | head -n 1
```
#### Hasil Output:
```
Siapa yang menemukan error Status Code 500 terbanyak?
   9773 192.168.1.2
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

