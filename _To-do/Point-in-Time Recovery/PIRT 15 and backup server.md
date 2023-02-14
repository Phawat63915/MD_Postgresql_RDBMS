# Point-in-Time Recovery Postgres 15 and backup server

ในคู่มือนี้นี้เราจะทำการสำรองข้อมูล Postgres 15 และทำการ Restore ข้อมูลกลับมาในเวลาที่กำหนดไว้

# Manual Setup

> **Note:** ส่วนของการติดตั้ง Postgres 15 และการตั้งค่าให้สามารถทำ Point-in-Time Recovery ได้
## Install Postgres 15 and Setup
#### 1. Install Postgres 15
พิมคำสั่งต่อไปนี้ เพื่อ ติดตั้ง Postgres 15 Database Server ลงบนเครื่อง
```bash
sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version
```

#### 2.สร้างโปเดอร์สำหรับที่จะเก็บข้อมูล backup และ wal archive
โดยใช้คำสั่งด่านล่างนี้ path เราจะเป็น `/var/lib/postgresql` หากพิม `pwd` เพื่อตรวจสอบ path
```
sudo su - postgres
```
หลังจากเป็น user postgres แล้วให้ทำการสร้าง โฟเดอร์สำหรับที่จะเก็บข้อมูล backup และ wal archive และ ls เช็กดูว่า Folder เราถูกสร้างไหม และดูว่าตำแหน่งที่เราสร้าง Folder อยู่ที่ไหน
```bash
mkdir basebackup && mkdir wal_archive && ls && pwd
```
เน้นย้ำว่า Unix user ต้องเป็น postgres ที่สร้าง Folder นี้

ออกจาก Unix Shell user postgres โดยใช้คำสั่ง
```bash
exit
```
เราจะกลับมาที่ Shell User ที่เรา Login เข้ามาในเครื่อง


### 3.ตั้งค่าให้สามารถทำ Point-in-Time Recovery ได้
```bash
sudo vi /etc/postgresql/15/main/postgresql.conf
```
<details><summary>ดูวิธีการแก้ แบบ Step by Step postgresql.conf (ละเอียด)</summary>

โดยหลังจากที่เรา เข้ามาที่ ไฟล์ config แล้วเราจะพบกับ config มากมาย แต่เราจะเลือก config ที่เราต้องการเปลี่ยนค่า โดยในที่นี้เราจะเปลี่ยนค่าในส่วนของ `wal_level`, `archive_mode`, `archive_command`, `archive_timeout` ซึ่งในกรณีนี้ถ้าเราใช้ คำสั่ง `nanp <file_name>` เราจะต้องเลี่ยนหาไกลมากนั้น ใช้  `vi <file_name>` จะดีกว่า

หลังจากเรา เปิด `postgresql.conf` มาแล้ว (โปรดดูตามตัวอย่างด้านล่าง)
- **Step 1**: พิม <kbd>/wal_level</kbd> เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 2**: พิม <kbd>/archive_mode</kbd> เพื่อค้นหาและกด <kbd>Enter</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_mode` จาก `off` เป็น `on` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 3**: พิม <kbd>/archive_command</kbd> เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_command` จาก ` ` เป็น `cp -i %p /var/lib/postgresql/wal_archive/%f` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 4**: พิม <kbd>/archive_timeout</kbd>เพื่อค้นหาและกด <kbd>[ENTER]</kbd> <kbd>[ENTER]</kbd> สองครั้ง กด <kbd>i</kbd> เพื่อเปิดการ Edit ของ vi แล้วลบ `#` ออก เพื่อให้ config นั้นถูกเปิดใช้งาน และเปลี่ยนค่า `archive_timeout` จาก `0` เป็น `60` และกด <kbd>[ESC]</kbd> เพื่อออกจากการ Edit

- **Step 5**: <kbd>[ESC]</kbd> แล้วพิม <kbd>:wq</kbd> เพื่อบันทึกและออกจาก vi


</details>

เปลี่ยนค่า config ใน `postgresql.conf` ตามรายดังนี้
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

โดย เราจะสร้าง Database ชื่อ `test_db1` และสร้าง table ชื่อ `test_table1` และใส่ข้อมูลลงไป และทำการ backup ข้อมูล ลงไป ประมาณ 3 ช่วงเวลา หรือ 3

โดยจะยกตัวอย่าง 4 ช่วงเวลา ดังนี้ (ช่วงเวลาจะเป็นช่วงเวลาทางการ)
- **15:00:00** เราจะทำการเพิ่มข้อมูลลงไป 10 แถว และทำการ backup ข้อมูล แบบ `pg_basebackup` หรือ แบบ Full Backup ลงไป ใน directory basebackup โดยในช่วงเวลาต่อไปเราจะไม่ได้ backup เลย แต่จะใช้ wal_archive แทน ในการกู้เมื่อฐานข้อมูลล่มเหลว
- **15:30:00** เพิ่มข้อมูล 10 แถว ดังนั้นข้อมูลทั้งหมดจะมี 20 แถว
- **16:00:00** เพิ่มข้อมูล 10 แถว ดังนั้นข้อมูลทั้งหมดจะมี 30 แถว
- **16:30:00** เราจะทำการทำลายข้อมูลทั้งหมด หรือ ทำลาย Database

ช่วงเวลาหลังจากฐานข้อมูลถูกทำลาย
- **23:00:00** เราจะทำการกู้ข้อมูล โดยใช้ Point in Time Recovery ซึ่งช่วงเวลา 15:00:00 และ 15:30:00 และ 16:00:00 เราสามารถย้อนไปกู้ข้อมูลได้ ซึ่งในครั้งนี้เราเราจะย้อนไป เวลา 15:30:00 ซึ่งขณะนั้นข้อมูลเราจะกลับมาเป็น 20 แถว (โดยเราจะเอา BackUp แบบ Full BackUp มาใช้รวมกับ WAL ที่เก็บไว้ใน directory wal_archive ในมารวมกันการกู้ข้อมูล)

> **Tip:** โดยในแต่ละช่วงเวลา เราจะ sql `select now();` เพื่อเช็กเวลาของแต่ละช่วงของเราว่าเรากำลังทำการทดสอบในช่วงเวลาใด โปรดจดเอาไว้


## **15:00:00** (ช่วง 1)

> **Note:** โดยช่วงเวลานี้เราจะทำการเพิ่มข้อมูลลงไป 10 แถว และทำการ backup ข้อมูล แบบ `pg_basebackup` หรือ แบบ Full Backup ลงไป ใน directory basebackup โดยใสนช่วงเวลาต่อไปเราจะไม่ได้ backup เลย

#### 1.Connect to PostgreSQL Server
เปลี่ยน user Unix เป็น user postgres
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
```
หลังจากสร้างฐานข้อมูลแล้ว ให้เราเข้าสู่ฐานข้อมูลที่เราสร้างไว้ โดยใช้คำสั่ง `\c` และใส่ชื่อฐานข้อมูลที่เราต้องการเข้าไป
```sql psql command
\c test_db1;
```
หลังจากเข้าสู่ฐานข้อมูลแล้ว ให้เราสร้าง table ชื่อ `test_tbl1` และ insert ข้อมูลลงไป 10 แถว
```sql
create table test_tbl1(id int,name varchar(255));
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
```
เราสามารถเช็คจำนวนข้อมูลที่เรา insert ลงไปได้ด้วยคำสั่ง `select count(1) from test_tbl1;`
```sql
select count(1) from test_tbl1; /* 10  */
```

<!-- ```sql
select now();
-- 2023-02-12 15:00:01.7 11004+00
``` -->

Archive WAL ไว้ใน directory wal_archive
```sql psql function command PIRT
SELECT pg_switch_wal();
```

<!-- ```bash
rm -rf /var/lib/postgresql/basebackup/*
``` -->

กด `ctrl + d` เพื่อออกจาก postgresql terminal หรือ พิม `\q` เพื่อออกมาจาก postgresql terminal มายัง Unix Shell ที่เป็น user postgres
```sql psql command
\q
```
จากนั้นพิม คำสั่งต่อไปนี้เพื่อทำการสำรองข้อมูลไป ยัง directory basebackup
```bash
pg_basebackup -D /var/lib/postgresql/basebackup -Ft -P
```

## **15:30:00** (ช่วง 2)

> **Note:** เพิ่มข้อมูล 10 แถว ดังนั้นข้อมูลทั้งหมดจะมี 20 แถว

เข้าสู่ postgresql terminal 

```bash
psql
```

และเข้าสู่ฐานข้อมูลที่เราสร้างไว้ โดยใช้คำสั่ง `\c <database_name>` และใส่ชื่อฐานข้อมูลที่เราต้องการเข้าไป

```sql psql command
\c test_db1;
```
เพิ่มข้อมูลลงไป 10 แถว และเช็คจำนวนข้อมูลที่เรา insert ลงไปได้ด้วยคำสั่ง `select count(1) from test_tbl1;`
```sql
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 20  */
```
<!-- select now(); /* restore point  2021-09-23 11:03:25 */ -->



>>>>>> <h1>Restore point</h1> ช่วงเวลาที่ 2
ในส่วนนี้จะเป็นส่วนสำคัญเลย เพราะเราจะจดเวลาที่เราจะย้อนมาที่เวลานี้ ด้วยคำสั่ง `select now();` และจะได้ออกมาเป็นประมาณ `2023-02-12 15:04:30` เราจะได้เอาไปใส่ที่ `recovery_target_time = '2023-02-12 15:04:30'` ใน postgresql.conf เพื่อเอาไว้ให้ Wal_log เล่นถึงแค่เวลานี้
```sql
select now();
-- /* restore point  2023-02-12 15:04:30 */
```


## **16:00:00** (ช่วง 3)

> **Note:** เพิ่มข้อมูล 10 แถว ดังนั้นข้อมูลทั้งหมดจะมี 30 แถว

> **Tip:** โปรดเลือก Databse `test_db1` ก่อนทำการ insert ข้อมูล โดยใช้คำสั่ง `\c test_db1` ซึ่งหากเราไม่ได้ `\q` ออกไปทำอื่น เราสามารถทำต่อได้เลย หรือ เพิกเฉยได้เลย Tip ได้เลย เพราะเราเข้าเมื่อ ช่วง ที่ 2 ไปแล้ว

```sql
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 30 recoreds */
```
<!-- 
```sql
select now();  
``` -->

## **16:30:00** (ช่วง 4) Destroy Database

> Note: เราจะทำการทำลายข้อมูลทั้งหมด หรือ ทำลาย Database
ให้ exit ออก จาก Unix Shell ที่เป็น user postgres ก่อนหากทำมาต่อจากขั้นตอนด้านบน
```bash
exit
```

<!-- 2023-02-12 15:05:15 -->

<!-- sudo systemctl stop postgresql-15 -->

และหยุด postgresql service 
```bash
sudo systemctl stop postgresql@15-main.service
```
เข้าสู่ postgresql terminal โดยใช้ Unix Shell ที่เป็น user postgres
```bash
sudo su - postgres
```
และลบข้อมูลทั้งหมดใน directory `/var/lib/postgresql/15/main/` ทั้งหมด
```bash
rm -rf /var/lib/postgresql/15/main/*
```

## **23:00:00** (ช่วง 5) Restore Database by using Full Backup + Archive WAL

> Note: เราจะทำการ Restore Database กลับมาในช่วง 2 โดยใช้ข้อมูลที่เราได้ทำการ Full Backup ไว้ในช่วง 1 มาต่อ กัน กับ Wal_log ที่เราได้ทำการ Archive ไว้ในช่วง 1 มาต่อ กัน

```bash
mkdir /var/lib/postgresql/15/main/pg_wal
```

```bash
tar -xvf /var/lib/postgresql/basebackup/base.tar -C /var/lib/postgresql/15/main
```

<!-- #no need to restore wal file -->
<!-- 2021-09-23 09:36:21 -->
<!-- 2023-02-12 15:04:30 -->



<!-- sudo su - postgres  -->
```bash
vi /var/lib/postgresql/15/main/recovery.signal 
```
```
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 15:04:30' 
```
```bash
sudo vi /etc/postgresql/15/main/postgresql.conf
```
```
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 15:04:30' 
```

```bash
sudo systemctl start postgresql@15-main.service
sudo systemctl stop postgresql@15-main.service
sudo systemctl restart postgresql@15-main.service
```
<!-- recovery_target_time = '2021-09-23 11:03:25'  -->

```
select pg_wal_replay_resume();
```
```sql
\c test_db1;
```
```sql
select count(1) from test_tbl1; /* 20  */
```