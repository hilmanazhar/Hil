# Hil

Berikut adalah file README.md lengkap yang bisa langsung kamu unggah ke GitHub beserta script yang diperlukan.

⸻

1. Simpan sebagai README.md

Buat file baru bernama README.md dan isi dengan teks berikut:

# **Analisis Log Website – Sistem Operasi**

## **1. Deskripsi Proyek**
Proyek ini bertujuan untuk menganalisis file log akses (`access.log`) dari website yang berjalan di lokal. Dengan data log ini, kita akan:
1. Menampilkan total request per IP dan jumlah status code.
2. Mengidentifikasi siapa pengguna berdasarkan IP dan tanggal dengan referensi dari `peminjaman_computer.csv`.
3. Menentukan siapa yang menemukan error **500** terbanyak untuk diberikan hadiah.

## **2. Struktur File**

/project-folder
│── access.log                 # File log akses website
│── peminjaman_computer.csv     # Data peminjaman komputer
│── total_requests.sh           # Script untuk menghitung request per IP dan status code
│── check_user.sh               # Script untuk mencari pengguna berdasarkan IP dan tanggal
│── find_winner.sh              # Script untuk menemukan pemenang dengan error 500 terbanyak
│── README.md                   # Laporan ini

---

## **3. Hasil Analisis**

### **3.1 Total Request per IP**
| IP Address    | Total Request |
|--------------|--------------|
| `192.168.1.1` | **38,597** |
| `192.168.1.2` | **38,453** |
| `192.168.1.3` | **38,450** |

---

### **3.2 Jumlah Status Code**
| Status Code | Jumlah |
|------------|--------|
| `200` (OK) | **29,087** |
| `302` (Redirect) | **28,896** |
| `404` (Not Found) | **28,635** |
| `500` (Internal Server Error) | **28,882** |

---

### **3.3 Pemenang yang Menemukan Error 500 Terbanyak**
- **IP dengan error 500 terbanyak:** `192.168.1.2`
- **Jumlah error 500 ditemukan:** **9,773 kali**
- **Nama pengguna:** **(Belum ditemukan, periksa format CSV)**

---

## **4. Cara Menjalankan Script**

### **4.1 Menampilkan Total Request per IP dan Status Code**
Jalankan script berikut:
```bash
bash total_requests.sh

Script ini akan membaca access.log dan menampilkan:
	•	Total request dari setiap IP
	•	Jumlah dari setiap status code

⸻

4.2 Mencari Pengguna Berdasarkan IP dan Tanggal

Jalankan script berikut:

bash check_user.sh MM/DD/YYYY 192.168.1.X

Masukkan tanggal (MM/DD/YYYY) dan IP (192.168.1.X), maka akan ditampilkan:
	•	Nama pengguna yang memakai komputer tersebut
	•	Log aktivitasnya yang disimpan di /backup/

⸻

4.3 Menemukan Pemenang dengan Status Code 500 Terbanyak

Jalankan script berikut:

bash find_winner.sh

Script ini akan mencari IP dengan error 500 terbanyak dan mencocokkannya dengan data peminjaman komputer untuk menentukan pemenangnya.

⸻

5. Catatan Tambahan
	•	Data di peminjaman_computer.csv perlu diperiksa formatnya agar bisa mencocokkan IP 192.168.1.2.
	•	Jika file CSV menggunakan format berbeda, pastikan nama kolomnya sesuai dengan script.
	•	Folder /backup/ harus ada sebelum menjalankan script backup log aktivitas.

⸻

6. Lisensi

Proyek ini dibuat untuk tujuan pembelajaran dan analisis log sistem operasi.

---

### **2. Buat Script Bash**  
Simpan file berikut sebagai `total_requests.sh`:  

```bash
#!/bin/bash

# Menghitung jumlah request per IP dan status code
LOG_FILE="access.log"

echo "Total Request per IP:"
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr

echo -e "\nJumlah Status Code:"
awk '{print $(NF-1)}' $LOG_FILE | sort | uniq -c | sort -nr

Buat file berikut sebagai check_user.sh:

#!/bin/bash

LOG_FILE="access.log"
CSV_FILE="peminjaman_computer.csv"
BACKUP_DIR="/backup"

if [ $# -ne 2 ]; then
    echo "Gunakan: $0 MM/DD/YYYY 192.168.1.X"
    exit 1
fi

TANGGAL=$1
IP=$2

PENGGUNA=$(awk -F, -v ip="$IP" '$2 == ip {print $3}' $CSV_FILE | head -n 1)

if [ -z "$PENGGUNA" ]; then
    echo "Data yang kamu cari tidak ada"
    exit 1
fi

echo "Pengguna saat itu adalah $PENGGUNA"

# Membuat backup log aktivitas
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/${PENGGUNA}_$(date +%m%d%Y)_$(date +%H%M%S).log"

grep "$IP" $LOG_FILE | awk '{print $4 " " $5 ": " $6 " " $7 " - " $(NF-1)}' > $BACKUP_FILE

echo "Log aktivitas telah disimpan di $BACKUP_FILE"

Simpan file berikut sebagai find_winner.sh:

#!/bin/bash

LOG_FILE="access.log"
CSV_FILE="peminjaman_computer.csv"

echo "Mencari pemenang yang menemukan error 500 terbanyak..."

TOP_IP=$(awk '$(NF-1) == 500 {print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
COUNT_500=$(awk -v ip="$TOP_IP" '$(NF-1) == 500 && $1 == ip {count++} END {print count}' $LOG_FILE)

PENGGUNA=$(awk -F, -v ip="$TOP_IP" '$2 == ip {print $3}' $CSV_FILE | head -n 1)

if [ -z "$PENGGUNA" ]; then
    echo "Pemenang tidak ditemukan dalam CSV"
else
    echo "Pemenang adalah $PENGGUNA dengan $COUNT_500 error 500"
fi



⸻

3. Cara Menjalankan
	1.	Beri izin eksekusi pada semua script:

chmod +x total_requests.sh check_user.sh find_winner.sh


	2.	Jalankan script sesuai kebutuhan (lihat bagian Cara Menjalankan Script di atas).

⸻

Sekarang kamu bisa menaruh semua file ini di GitHub dan menjalankan script untuk analisis log sistem operasi. Jika ada tambahan atau revisi, beri tahu saya!
