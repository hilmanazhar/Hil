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
