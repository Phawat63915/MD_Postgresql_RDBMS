# Streaming(Hot Standby) Postgres 15

ในคู่มือนี้นี้เราจะสร้าง Streaming Hot Standby ของ Postgres 15 ซึ่งจะมีเครื่องหลักเป็น master และ เครื่องสำรองเป็น Slave ซึ่ง Slave จะมีกี่เครื่องก็ได้ แต่ในคู่มือนี้จะทำเพียงแค่ 1 เครื่องเท่านั้น

# Setup (ติดตั้ง)
### First, install postgresql 15 on both master and slave.

พิมคำสั่งต่อไปนี้ลงใน terminal ของ master และ slave ทั้งสองเครื่อง เพื่อทำการติดตั้ง postgresql 15 และทำขั้นตอนถัดไป
```bash
sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version
```

### Master (VM1) 192.168.56.51
แก้ไขไฟล์ config postgresql.conf เปลี่ยนค่าตามรายการดังนี้
```bash
sudo vi /etc/postgresql/15/main/postgresql.conf
```

```conf postgresql.conf
listen_addresses = *
wal_level = replica
hot_standby = on
```

แก้ไขไฟล์ config pg_hba.conf เปลี่ยนค่าตามรายการดังนี้
```
sudo vi /etc/postgresql/15/main/pg_hba.conf
```

```
host    replication     all             0.0.0.0/0               md5
host    all             all             0.0.0.0/0               md5
```

Restart postgresql sevice แก้ให้เพื่อให้ config มีผล
```bash
sudo systemctl restart postgresql@15-main.service
```

เปลี่ยน Unix Shell เป็น user postgres เพื่อพิมขั้นตอนถัดไป
```bash
sudo su - postgres
```
เข้า postgresql twminal ด้วย Unix Shell ด้วย user postgres
```bash
psql
```
สร้าง user สำหรับ replication และกำหนด password

`create user repl_<custom_username> with replication encrypted password '<password>';`
```
create user repl_mst with replication encrypted password 'phawatsorratat';
```

และพิมคสั่ง `\q` เพื่อออกจาก psql terminal
```
\q
```
ให้ออกจาก Unix Shell ที่เป็น user postgres ก่อน และกลับมาที่ Unix Shell ที่เป็น user root
```
exit
```


### Slave Standby (VM2) 192.168.56.52

หยุด postgresql service ก่อน เพื่อทำการสร้าง backup ของ master และนำมาใช้ใน slave ซึ่งต้องมีการแก้ไฟล์ data main ซึ่ง service postgresql มันอ่านอยู่ตลอดเวลา เพื่อห้สามารถทำได้อย่างไม่มีข้อผิดพลาด จึงต้องหยุด service ก่อน ใช้คำสั่งนี้ที่ Unix Shell ที่เป็น user root
```
sudo systemctl stop postgresql@15-main.service
```

เปลี่ยน Unix Shell เป็น user postgres เพื่อพิมขั้นตอนถัดไป
```
sudo su - postgres
```
ก่อนใช้ pg_basebackup เปลี่ยน เป็น user postgres ก่อน เพื่อที่ file owner จะได้เป็น postgres 
```
pg_basebackup -h 192.168.56.52 -U repl_mst -p 5432 -D /var/lib/postgresql/15/main -Fp -Xs -P -R -C -S repl_slot
```

หลังจาก pg_basebackup สำเร็จแล้ว ให้เปลี่ยนเป็น Unix Shell ที่เป็น user root ก่อน เพื่อทำการ start postgresql service ใหม่

```
sudo systemctl start postgresql@15-main.service
```


# Validations | ทดสอบ

### Master (VM1) 192.168.56.51
```
\x
```
```
select * from pg_stat_replication;
```
### Standby (VM2) 192.168.56.52
```
select pg_is_in_recovery();
```