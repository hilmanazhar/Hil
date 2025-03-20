#!/bin/bash
echo "Siapa yang menemukan error Status Code 500 terbanyak?"
awk '$9 == 500 {print $1}' access.log | sort | uniq -c | sort -nr | head -n 1
