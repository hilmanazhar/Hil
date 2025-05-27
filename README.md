[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/Eu-CByJh)
|    NRP     |      Name      |
| :--------: | :------------: |
| 5025231258 | M. Rizal Febrianto |
| 5025241264 | Muhammad Hilman Azhar |
| 5025241265 | A. Wildan Kevin Assyauqi |

# Praktikum Modul 3 (Module 3 Lab Work)

### Laporan Resmi Praktikum Modul 3 (Module 3 Lab Work Report)

Di suatu pagi hari yang cerah, Budiman salah satu mahasiswa Informatika ditugaskan oleh dosennya untuk membuat suatu sistem operasi sederhana. Akan tetapi karena Budiman memiliki keterbatasan, Ia meminta tolong kepadamu untuk membantunya dalam mengerjakan tugasnya. Bantulah Budiman untuk membuat sistem operasi sederhana!

One sunny morning, Budiman, an Informatics student, was assigned by his lecturer to create a simple operating system. However, due to Budiman's limitations, he asks for your help to assist him in completing his assignment. Help Budiman create a simple operating system!

### Soal 1

> Sebelum membuat sistem operasi, Budiman diberitahu dosennya bahwa Ia harus melakukan beberapa tahap terlebih dahulu. Tahap-tahapan yang dimaksud adalah untuk *mempersiapkan seluruh prasyarat* dan *melakukan instalasi-instalasi* sebelum membuat sistem operasi. Lakukan seluruh tahapan prasyarat hingga [perintah ini](https://github.com/arsitektur-jaringan-komputer/Modul-Sisop/blob/master/Modul3/README-ID.md#:~:text=sudo%20apt%20install%20%2Dy%20busybox%2Dstatic) pada modul!

> Before creating the OS, Budiman was informed by his lecturer that he must complete several steps first. The steps include *preparing all prerequisites* and *installing* before creating the OS. Complete all the prerequisite steps up to [this command](https://github.com/arsitektur-jaringan-komputer/Modul-Sisop/blob/master/Modul3/README-ID.md#:~:text=sudo%20apt%20install%20%2Dy%20busybox%2Dstatic) in the module!

*Answer:*

- *Code:*

  
  sudo apt -y update
  sudo apt -y install qemu-system build-essential bison flex libelf-dev libssl-dev bc grub-common grub-pc libncurses-dev libssl-dev mtools grub-pc-bin xorriso tmux

  mkdir -p osboot
  cd osboot

  wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz
  tar -xvf linux-6.1.1.tar.xz
  rm linux-6.1.1.tar.xz
  cd linux-6.1.1

  make tinyconfig
  make menuconfig

  make -j$(nproc)
  cp arch/x86/boot/bzImage ..

  sudo apt install -y busybox-static
  whereis busybox
  

- *Explanation:*

  put your answer here

- *Screenshot:*

  ![img1](assets/num%201.png)

### Soal 2

> Setelah seluruh prasyarat siap, Budiman siap untuk membuat sistem operasinya. Dosen meminta untuk sistem operasi Budiman harus memiliki directory *bin, dev, proc, sys, tmp,* dan *sisop*. Lagi-lagi Budiman meminta bantuanmu. Bantulah Ia dalam membuat directory tersebut!

> Once all prerequisites are ready, Budiman is ready to create his OS. The lecturer asks that the OS should contain the directories *bin, dev, proc, sys, tmp,* and *sisop*. Help Budiman create these directories!

*Answer:*

- *Code:*

  
  cd ..
  sudo bash
  mkdir -p myramdisk/{bin,dev,proc,sys,tmp,sisop}
  

- *Explanation:*

  put your answer here

- *Screenshot:*

  ![img2](assets/num%202.png)

### Soal 3

> Budiman lupa, Ia harus membuat sistem operasi ini dengan sistem *Multi User* sesuai permintaan Dosennya. Ia meminta kembali kepadamu untuk membantunya membuat beberapa user beserta directory tiap usernya dibawah directory home. Buat pula password tiap user-usernya dan aplikasikan dalam sistem operasi tersebut!

> _Budiman forgot that he needs to create a *Multi User* system as requested by the lecturer. He asks your help again to create several users and their corresponding home directories under the home directory. Also set each user's password and apply them in the OS!_

*Format:* user:pass


root:Iniroot
Budiman:PassBudi
guest:guest
praktikan1:praktikan1
praktikan2:praktikan2


*Answer:*

- *Code:*

  
  cp -a /dev/null myramdisk/dev
  cp -a /dev/tty* myramdisk/dev
  cp -a /dev/zero myramdisk/dev
  cp -a /dev/console myramdisk/dev

  cp /usr/bin/busybox myramdisk/bin
  cd myramdisk/bin
  ./busybox --install .

  cd ..

  mkdir -p home/{Budiman,guest,praktikan1,praktikan2}
  mkdir -p etc
  
  openssl passwd -1 Iniroot
  openssl passwd -1 PassBudi
  openssl passwd -1 guest
  openssl passwd -1 praktikan1
  openssl passwd -1 praktikan2

  nano etc/passwd

  root:$1$Up6B5klH$PHOmTNb8VhC7LAu68BKWp/:0:0:root:/root:/bin/sh
  Budiman:$1$abcdefg$......:1001:100:Budiman:/home/Budiman:/bin/sh
  guest:$1$abcdefg$......:1002:100:guest:/home/guest:/bin/sh
  praktikan1:$1$abcdefg$......:1003:100:praktikan1:/home/praktikan1:/bin/sh
  praktikan2:$1$abcdefg$......:1004:100:praktikan2:/home/praktikan2:/bin/sh

  isi nano passwd
  ganti setelah user: sampai :user
  dengan hasil generate openssl

  
  nano etc/group

  root:x:0:
  users:x:100:Budiman,guest,praktikan1,praktikan2

  
  nano init

  #!/bin/sh
  /bin/mount -t proc none /proc
  /bin/mount -t sysfs none /sys

  while true
  do
    /bin/getty -L tty1 115200 vt100
    sleep 1
  done


  chmod +x init

  find . | cpio -oHnewc | gzip > ../myramdisk.gz
  

- *Explanation:*

  put your answer here

- *Screenshot:*

  ![img3](assets/num%203.png)

### Soal 4

> Dosen meminta Budiman membuat sistem operasi ini memilki *superuser* layaknya sistem operasi pada umumnya. User root yang sudah kamu buat sebelumnya akan digunakan sebagai superuser dalam sistem operasi milik Budiman. Superuser yang dimaksud adalah user dengan otoritas penuh yang dapat mengakses seluruhnya. Akan tetapi user lain tidak boleh memiliki otoritas yang sama. Dengan begitu user-user selain root tidak boleh mengakses ./root. Buatlah sehingga tiap user selain superuser tidak dapat mengakses ./root!

> _The lecturer requests that the OS must have a *superuser* just like other operating systems. The root user created earlier will serve as the superuser in Budiman's OS. The superuser should have full authority to access everything. However, other users should not have the same authority. Therefore, users other than root should not be able to access ./root. Implement this so that non-superuser accounts cannot access ./root!_

*Answer:*

- *Code:*

  ```
  sudo bash
  cd myramdisk/
  
  chown root:root /root
  chmod 700 /root
  ```

- *Explanation:*

1. *Login sebagai root*
    - login sebagai root menggunakan sudo bash, lalu masukkan password root. 
2. *Masuk ke Direktori myramdisk*
    - Pastikan Anda berada di direktori myramdisk

3. *Atur Hak Akses Folder /root*
    - Setelah folder root dibuat, atur supaya hanya user root yang bisa akses: <br>
     chown root:root /root <br>
     chmod 700 /root <br>
     
4. *Cek Akses dari Pengguna Lain*
    - Coba login sebagai user lain dan akses /root: <br>
     misal login dulu menggunakan akun budiman <br>
     cd /root <br>
     
     Harusnya muncul pesan "Permission denied" karena user tersebut bukan root.

- *Screenshot:*

  put your answer here

### Soal 5

> Setiap user rencananya akan digunakan oleh satu orang tertentu. *Privasi dan otoritas tiap user* merupakan hal penting. Oleh karena itu, Budiman ingin membuat setiap user hanya bisa mengakses dirinya sendiri dan tidak bisa mengakses user lain. Buatlah sehingga sistem operasi Budiman dalam melakukan hal tersebut!

> Each user is intended for an individual. *Privacy and authority* for each user are important. Therefore, Budiman wants to ensure that each user can only access their own files and not those of others. Implement this in Budiman's OS!

*Answer:*

- *Code:*

  ```
  sudo bash

  cd myramdisk/home/
  
  chown 1001:100 /Budiman
  chown 1002:100 /guest
  chown 1003:100 /praktikan1
  chown 1004:100 /praktikan2

  chmod 700 /home/Budiman
  chmod 700 /home/guest
  chmod 700 /home/praktikan1
  chmod 700 /home/praktikan2
  ```
    

- *Explanation:*

1. *Masuk sebagai root*
    - login sebagai root dengan sudo bash lalu masukkan password root. 
2. *Masuk ke Direktori myramdisk/home/*
    - Pastikan kamu ada di dalam folder  myramdisk/home/.

3. Atur Hak Akses Folder Home
    - Setel permission folder home masing-masing user ke 700, biar cuma pemilik folder yang bisa buka:
   ```
     chown 1001:100 /Budiman 
     chown 1002:100 /gues
     chown 1003:100 /praktikan1
     chown 1004:100 /praktikan2

     chmod 700 /Budiman
     chmod 700 /guest
     chmod 700 /praktikan1
     chmod 700 /praktikan2
     ```

3. Uji Akses antar User
    - Coba login sebagai Budiman dan akses folder user lain:


     Harusnya muncul "Permission denied", yang artinya folder tersebut gak bisa diakses.

- *Screenshot:*

  put your answer here

### Soal 6

> Dosen Budiman menginginkan sistem operasi yang *stylish*. Budiman memiliki ide untuk membuat sistem operasinya menjadi stylish. Ia meminta kamu untuk menambahkan tampilan sebuah banner yang ditampilkan setelah suatu user login ke dalam sistem operasi Budiman. Banner yang diinginkan Budiman adalah tulisan "Welcome to OS'25" dalam bentuk *ASCII Art*. Buatkanlah banner tersebut supaya Budiman senang! (Hint: gunakan text to ASCII Art Generator)

> _Budiman wants a *stylish* operating system. Budiman has an idea to make his OS stylish. He asks you to add a banner that appears after a user logs in. The banner should say "Welcome to OS'25" in *ASCII Art*. Use a text to ASCII Art generator to make Budiman happy!_ (Hint: use a text to ASCII Art generator)

*Answer:*

- *Code:*

  ```
  apt update
  apt install figlet

  nano /home/Budiman/.bashrc

  echo "Welcome to OS'25" | figlet
  ```

- *Explanation:*

1. Menggunakan Generator ASCII Art
    - Kunjungi situs seperti [Patorjk's Text to ASCII Art Generator](https://patorjk.com/software/taag/) dan masukkan teks "Welcome to OS'25".
    - Pilih gaya ASCII Art dan salin hasilnya.
  atau
    - install figlet dengan cara :
      bash
      sudo apt update
      sudo apt install figlet    

2. *Buat banner pakai figlet*
     - generate banner menggunakan figlet echo "Welcome to OS'25" | figlet
2. *Masukkan hasil text dari figlet tadi ke .bashrc milik budiman*
   nano /home/budiman/.bashrc

   lalu masukkan banner hasil generate menggunakan figlet tadi

3. Cek Banner Saat Login
    - Keluar dari terminal, lalu login lagi sebagai budiman untuk lihat bannernya muncul:

- *Screenshot:*

  put your answer here

### Soal 7

> Melihat perkembangan sistem operasi milik Budiman, Dosen kagum dengan adanya banner yang telah kamu buat sebelumnya. Kemudian Dosen juga menginginkan sistem operasi Budiman untuk dapat menampilkan *kata sambutan* dengan menyebut nama user yang login. Sambutan yang dimaksud berupa kalimat "Helloo %USER" dengan %USER merupakan nama user yang sedang menggunakan sistem operasi. Kalimat sambutan ini ditampilkan setelah user login dan setelah banner. Budiman kembali lagi meminta bantuanmu dalam menambahkan fitur ini.

> _Seeing the progress of Budiman's OS, the lecturer is impressed with the banner you created. The lecturer also wants the OS to display a *greeting message* that includes the name of the user who logs in. The greeting should say "Helloo %USER" where %USER is the name of the user currently using the OS. This greeting should be displayed after user login and after the banner. Budiman asks for your help again to add this feature._

*Answer:*

- *Code:*

  
  nano myramdisk/home/Budiman/.bashrc

  tambahkan:
  USER=$(whoami)
  echo "Helloo $USER"
  

- *Explanation:*

  1. Buka file .bashrc milik Budiman.
  2. lalu tambahkan ini ke file .bashrc tersebut.
     
     USER=$(whoami)
     echo "Helloo $USER"
     

- *Screenshot:*

  ![img7](assets/Num%207.png)

### Soal 8

> Dosen Budiman sudah tua sekali, sehingga beliau memiliki kesulitan untuk melihat tampilan terminal default. Budiman menginisiatif untuk membuat tampilan sistem operasi menjadi seperti terminal milikmu. Modifikasilah sistem operasi Budiman menjadi menggunakan tampilan terminal kalian.

> Budiman's lecturer is quite old and has difficulty seeing the default terminal display. Budiman takes the initiative to make the OS look like your terminal. Modify Budiman's OS to use your terminal appearance!

*Answer:*

- *Code:*

  
  qemu-system-x86_64 \
  -smp 2 \
  -m 256 \
  -nographic \
  -serial mon:stdio \
  -kernel bzImage \
  -initrd myramdisk.gz \
  -append "console=ttyS0" 
  

- *Explanation:*

  1. ubah config bzImage:
    
    CONFIG_SERIAL_8250=y
    CONFIG_SERIAL_8250_CONSOLE=y 
    CONFIG_PRINTK=y
    CONFIG_EARLY_PRINTK=y
    
  2. ubah file init bagian getty dari tty1 ke ttyS0
  3. lalu jalankan menggunakan ini
     
     qemu-system-x86_64 \
      -smp 2 \
      -m 256 \
      -nographic \
      -serial mon:stdio \
      -kernel bzImage \
      -initrd myramdisk.gz \
      -append "console=ttyS0" 
    

- *Screenshot:*

  ![img8](assets/num%208.png)

### Soal 9

> Ketika mencoba sistem operasi buatanmu, Budiman tidak bisa mengubah text file menggunakan text editor. Budiman pun menyadari bahwa dalam sistem operasi yang kamu buat tidak memiliki text editor. Budimanpun menyuruhmu untuk menambahkan *binary* yang telah disiapkan sebelumnya ke dalam sistem operasinya. Buatlah sehingga sistem operasi Budiman memiliki *binary text editor* yang telah disiapkan!

> When trying your OS, Budiman cannot edit text files using a text editor. He realizes that the OS you created does not have a text editor. Budiman asks you to add the prepared *binary* into his OS. Make sure Budiman's OS has the prepared *text editor binary*!

*Answer:*

- *Code:*

  
  which nano

  ldd /usr/bin/nano

  cp /usr/bin/nano myramdisk/usr/bin/
  cp /lib/x86_64-linux-gnu/libncursesw.so.6 myramdisk/lib/
  cp /lib/x86_64-linux-gnu/libtinfo.so.6 myramdisk/lib/
  cp /lib/x86_64-linux-gnu/libc.so.6 myramdisk/lib/

  find . | cpio -oHnewc | gzip > ../myramdisk.gz

  echo $TERM

  find /lib/terminfo /usr/share/terminfo -name 'vt100'

  mkdir -p myramdisk/lib/terminfo/v
  cp /lib/terminfo/v/vt100 myramdisk/lib/terminfo/v/
  

- *Explanation:*

  1. cek nano berada dimana
  2. lalu cek dependensi nano dengan lld <hasil cek nano>
  3. lalu cp sesuai hasi lld tersebut dengan path folder yang sama dari root ke myramdisk
  4. lalu zip myramdisk, jalankan, tes nano
  5. jika tidak bisa kita ke langka selanjutnya, coba cek nilai variabel term, hasil defaultnya pasti 'vt100'
  6. lalu cari file terminfo untuk 'vt100'
  7. habis itu cp file tersebut ke myramdisk dengan path yang sama
  8. setelah itu zip lagi, jalanin, coba nano lagi

- *Screenshot:*

  ![img9-1](assets/num%209-1.png)
  ![img9-2](assets/num%209-2.png)

### Soal 10

> Setelah seluruh fitur yang diminta Dosen dipenuhi dalam sistem operasi Budiman, sudah waktunya Budiman mengumpulkan tugasnya ini ke Dosen. Akan tetapi, Dosen Budiman tidak mau menerima pengumpulan selain dalam bentuk *.iso. Untuk terakhir kalinya, Budiman meminta tolong kepadamu untuk mengubah seluruh konfigurasi sistem operasi yang telah kamu buat menjadi sebuah **file .iso*.

> After all the features requested by the lecturer have been implemented in Budiman's OS, it's time for Budiman to submit his assignment. However, Budiman's lecturer only accepts submissions in the form of *.iso* files. For the last time, Budiman asks for your help to convert the entire configuration of the OS you created into a *.iso file*.

*Answer:*

- *Code:*

  
  mkdir -p mylinuxiso/boot/grub

  cp bzImage mylinuxiso/boot
  cp myramdisk.gz mylinuxiso/boot

  nano grub.cfg

  grub-mkrescue -o mylinux.iso mylinuxiso

  qemu-system-x86_64 \
  -smp 2 \
  -m 256 \
  -nographic \
  -serial mon:stdio \
  -cdrom mylinux.iso 
  

- *Explanation:*

  1. pergi ke dir osboot
  2. buat dir mylinuxiso/boot/grub
  3. copy bzImage dan myramdisk.gz ke mylinuxiso/boot
  4. buat file grub.cfg lalu isi seperti ini:
    
    set timeout=5
    set default=0

    menuentry "MyLinux" {
      linux /boot/bzImage
      initrd /boot/myramdisk.gz
    }
    
  5. buat file ISO bootable
  6. lalu coba jalankan

- *Screenshot:*

  ![img10-1](assets/num%2010-1.png)
  ![img10-2](assets/num%2010-2.png)

---

Pada akhirnya sistem operasi Budiman yang telah kamu buat dengan susah payah dikumpulkan ke Dosen mengatasnamakan Budiman. Kamu tidak diberikan credit apapun. Budiman pun tidak memberikan kata terimakasih kepadamu. Kamupun kecewa tetapi setidaknya kamu telah belajar untuk menjadi pembuat sistem operasi sederhana yang andal. Selamat!

At last, the OS you painstakingly created was submitted to the lecturer under Budiman's name. You received no credit. Budiman didn't even thank you. You feel disappointed, but at least you've learned to become a reliable creator of simple operating systems. Congratulations!
