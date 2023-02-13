# Point-in-Time Recovery Postgres 15 and backup server

ในคู่มือนี้นี้เราจะทำการสำรองข้อมูล Postgres 15 และทำการ Restore ข้อมูลกลับมาในเวลาที่กำหนดไว้

# Manual Setup

> **Note:** ส่วนของการติดตั้ง Postgres 15 และการตั้งค่าให้สามารถทำ Point-in-Time Recovery ได้
## Install Postgres 15 and Setup
#### 1. Install Postgres 15
ลงบนเครื่อง
```bash
sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version
```

#### 2.สร้างโปเดอร์สำหรับที่จะเก็บข้อมูล backup และ wal archive
โดยใช้คำสั่งด่านล่างนี้ path เราจะเป็น `/var/lib/postgresql`
```
sudo su - postgres
```
หลังจากเป็น user postgres แล้วให้ทำการสร้าง โฟเดอร์สำหรับที่จะเก็บข้อมูล backup และ wal archive และ ls เช็กดูว่า Folder เราถูกสร้างไหม และดูว่าตำแหน่งที่เราสร้าง Folder อยู่ที่ไหน
```bash
mkdir basebackup && mkdir wal_archive && ls && pwd
```
เน้นย้ำว่าต้องเป็น user postgres ที่สร้าง Folder นี้

ออกจาก user postgres โดยใช้คำสั่ง
```bash
exit
```
เราจะกลับมาที่ user ที่เรา login เข้ามาในเครื่อง


### 3.ตั้งค่าให้สามารถทำ Point-in-Time Recovery ได้
```bash
sudo vi /etc/postgresql/15/main/postgresql.conf
```
โดยหลังจากที่เรา เข้ามาที่ ไฟล์ config แล้วเราจะพบกับ config มากมาย แต่เราจะเลือก config ที่เราต้องการเปลี่ยนค่า โดยในที่นี้เราจะเปลี่ยนค่าในส่วนของ `wal_level`, `archive_mode`, `archive_command`, `archive_timeout` ซึ่งในกรณีนี้ถ้าเราใช้ คำสั่ง `nanp <file_name>` เราจะต้องเลี่ยนหาไกลมากนั้น ใช้  `vi <file_name>` จะดีกว่า

หลังจากเรา เปิด `postgresql.conf` มาแล้ว (โปรดดูตามตัวอย่างด้านล่าง)
- **Step 1**: พิม <kbd>/wal_level</kbd> เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 2**: พิม <kbd>/archive_mode</kbd> เพื่อค้นหาและกด <kbd>Enter</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_mode` จาก `off` เป็น `on` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 3**: พิม <kbd>/archive_command</kbd> เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_command` จาก ` ` เป็น `cp -i %p /var/lib/postgresql/wal_archive/%f` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 4**: พิม <kbd>/archive_timeout</kbd>เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_timeout` จาก `0` เป็น `60` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 5**: <kbd>[ESC]</kbd> แล้วพิม <kbd>:wq</kbd> เพื่อบันทึกและออกจาก vi

```postgresql.conf
wal_level = replica
archive_mode=on
archive_command =  'cp -i %p /var/lib/postgresql/wal_archive/%f'
archive_timeout = 60
```

จากนั้นเราจะทำการ restart postgresql ใหม่ เพื่อให้ config ที่เราเปลี่ยนไป มีผลใช้งาน
```bash
sudo systemctl restart postgresql@15-main.service
```


# Manual Recovery Point-in-Time (PITR)

ตามขั้นตอนดังต่อไปนี้จะเป็นการยกตัวอย่างการทำ Point in Time Recovery 

โดย
- สร้าง Database ชื่อ `test_db1` และ Table ชื่อ `test_table1` และ Insert ข้อมูลลงไป
- สร้าง Database ชื่อ `test_db2` และ Table ชื่อ `test_table2` และ Insert ข้อมูลลงไป


#### 1.Connect to PostgreSQL Server
เปลี่ยน user unix เป็น user postgres
```bash
sudo su - postgres
```

จากนั้นให้เราพิมคำสั่ง `psql` เพื่อเข้าสู่ postgresql terminal
```bash
psql
```
(!) ตาม 2 ขั้นตอนด้านบนจะเป็นวิธีการเข้าสู่ postgresql terminal Database แบบไม่ต้องใส่รหัสผ่าน หรือการเข้าที่ เครื่องที่เป็น Database Server

#### 2.Create Database and Table
เมื่อเข้าสู่ postgresql terminal แล้ว ให้เราสร้าง database ชื่อ `test_db1` และสร้าง table ชื่อ `test_tbl1` และ insert ข้อมูลลงไป 10 แถว
```sql
create database test_db1;


\c test_db1;
create table test_tbl1(id int,name varchar(255));
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; - 10
select now();
SELECT pg_switch_wal();

# 2023-02-12 15:00:01.711004+00


rm -rf /var/lib/postgresql/basebackup/*

pg_basebackup -D /var/lib/postgresql/basebackup -Ft -P




\c test_db1;
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 20  */
# select now(); /* restore point  2021-09-23 11:03:25 */

select now();  /* restore point  2023-02-12 15:04:30 */




insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 30 recoreds */
select now();  

# 2023-02-12 15:05:15

#  sudo systemctl stop postgresql-15
sudo systemctl stop postgresql@15-main.service

sudo su - postgres
rm -rf /var/lib/postgresql/15/main/*
mkdir /var/lib/postgresql/15/main/pg_wal


tar -xvf /var/lib/postgresql/basebackup/base.tar -C /var/lib/postgresql/15/main
#no need to restore wal file
# 2021-09-23 09:36:21
2023-02-12 15:04:30



sudo su - postgres 
vi /var/lib/postgresql/15/main/recovery.signal 
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 15:04:30' 

sudo vi /etc/postgresql/15/main/postgresql.conf
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 15:04:30' 


sudo systemctl start postgresql@15-main.service
sudo systemctl stop postgresql@15-main.service
sudo systemctl restart postgresql@15-main.service

# recovery_target_time = '2021-09-23 11:03:25' 


select pg_wal_replay_resume();

\c test_db1;
select count(1) from test_tbl1; /* 20  */
```