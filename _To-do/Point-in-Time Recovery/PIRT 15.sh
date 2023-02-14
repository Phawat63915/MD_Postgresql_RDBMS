# Install pg

sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version


sudo su - postgres
mkdir basebackup 
mkdir wal_archive




sudo vi /etc/postgresql/15/main/postgresql.conf

#Wal_Level =replica or archive
wal_level = replica
archive_mode=on
archive_command =  'cp -i %p /var/lib/postgresql/wal_archive/%f'
archive_timeout = 60

sudo systemctl restart postgresql@15-main.service


### Normal recovery


sudo -u postgres psql -c "SELECT pg_switch_wal();"


sudo -u postgres pg_basebackup -D /var/lib/postgresql/basebackup -Ft -z -P -Xs
sudo -u postgres pg_basebackup -D /var/lib/postgresql/basebackup -Ft -P




rm -rf /var/lib/postgresql/data/*
sudo -u postgres mkdir /var/lib/postgresql/data/pg_wal


#restoration :


tar -xvf /var/lib/postgresql/basebackup/base.tar -C //var/lib/postgresql/15/main
tar -xvf /var/lib/postgresql/basebackup/pg_wal.tar -C /var/lib/postgresql/15/main/pg_wal




Restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'




### PITR
create database test_db1;


\c test_db1;
create table test_tbl1(id int,name varchar(255));
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; - 10
select now();
SELECT pg_switch_wal();

# 2023-02-12 01:28:57.892384+00


rm -rf /var/lib/postgresql/basebackup/*

pg_basebackup -D /var/lib/postgresql/basebackup -Ft -P




\c test_db1;
insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 20  */
# select now(); /* restore point  2021-09-23 11:03:25 */

select now();  /* restore point  2023-02-12 01:33:06 */




insert into test_tbl1
SELECT generate_series(1,10) AS id, md5(random()::text) AS descr;
select count(1) from test_tbl1; /* 30 recoreds */
select now();  

# 2023-02-12 01:34:00

#  sudo systemctl stop postgresql-15
sudo systemctl stop postgresql@15-main.service

sudo su - postgres
rm -rf /var/lib/postgresql/15/main/*
mkdir /var/lib/postgresql/15/main/pg_wal


tar -xvf /var/lib/postgresql/basebackup/base.tar -C /var/lib/postgresql/15/main
#no need to restore wal file
# 2021-09-23 09:36:21
2023-02-12 01:33:06



sudo su - postgres 
vi /var/lib/postgresql/15/main/recovery.signal 
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 01:33:06' 

sudo vi /etc/postgresql/15/main/postgresql.conf
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p' 
recovery_target_time = '2023-02-12 01:33:06' 


sudo systemctl start postgresql@15-main.service
sudo systemctl stop postgresql@15-main.service
sudo systemctl restart postgresql@15-main.service

# recovery_target_time = '2021-09-23 11:03:25' 


select pg_wal_replay_resume();

\c test_db1;
select count(1) from test_tbl1; /* 20  */