#!/bin/bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr > ip_count.txt
awk '{print $9}' access.log | sort | uniq -c | sort -nr > status_count.txt
echo "Total request per IP:"
cat ip_count.txt
echo "Jumlah setiap status code:"
cat status_count.txt
