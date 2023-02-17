# Point-in-Time Recovery Postgres 15

ในคู่มือนี้นี้เราจะสร้าง Streaming Hot Standby ของ Postgres 15 ซึ่งจะมีเครื่องหลักเป็น master และ เครื่องสำรองเป็น standby ซึ่ง standby จะมีกี่เครื่องก็ได้ แต่ในคู่มือนี้จะทำเพียงแค่ 1 เครื่องเท่านั้น

# Setup
### First, install postgresql 15 on both master and slave.

พิมคำสั่งต่อไปนี้ลงใน terminal ของ master และ slave ทั้งสองเครื่อง เพื่อทำการติดตั้ง postgresql 15 และทำขั้นตอนถัดไป
```bash
sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version
```

### Master (VM1) 192.168.56.51
sudo vi /etc/postgresql/12/main/postgresql.conf

listen_addresses = *
wal_level = replica
hot_standby = on

sudo su - postgres

create user repl_mst with replication encrypted password 'phawatsorratat';

sudo vi /etc/postgresql/12/main/pg_hba.conf
host    replication     all             0.0.0.0/0               md5
host    all             all             0.0.0.0/0               md5

sudo systemctl restart postgresql@12-main.service


### Standby (VM2) 192.168.56.52

sudo systemctl stop postgresql@12-main.service

sudo su - postgres

pg_basebackup -h 192.168.56.52 -U repl_mst -p 5432 -D /var/lib/postgresql/12/main -Fp -Xs -P -R -C -S repl_slot

sudo systemctl start postgresql@12-main.service

# Validations

### Master (VM1) 192.168.56.51
\x
select * from pg_stat_replication;

### Standby (VM2) 192.168.56.52
select pg_is_in_recovery();