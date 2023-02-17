
sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version


centos-master - 10.139.0.2 
centos-slave -  10.139.0.3 

yum install nmap
nmap 10.139.0.2

https://www.digitalocean.com/communit...

sudo firewall-cmd --zone=home --change-interface=eth0

sudo firewall-cmd --set-default-zone=home

https://www.digitalocean.com/communit...

sudo yum install postgresql12-server
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl start postgresql-12
sudo systemctl enable postgresql-12


sudo firewall-cmd --zone=home --permanent --add-service=postgresql
sudo firewall-cmd --reload
sudo firewall-cmd --zone=home --list-services

edit pg_hba.conf and postgresql.conf to open port for remote server
restart postgresql


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



slave :
sudo systemctl stop postgresql@12-main.service
sudo su - postgres
pg_basebackup -h 192.168.56.52 -U repl_mst -p 5432 -D /var/lib/postgresql/12/main -Fp -Xs -P -R -C -S repl_slot

sudo systemctl start postgresql@12-main.service

#can delete repl_slot if error
# select pg_drop_replication_slot('repl_slot');

# SELECT pg_is_in_recovery();

validations.
master:
\x
select * from pg_stat_replication;
# select * from pg_current_wal_lsn();

# select * from pg_wal_lsn_diff('0/271D1128','0/271D1128');
# select * from pg_wal_lsn_diff('0/94377B0');
# select round(34/(1024*1024)) MB;
# SELECT pg_walfile_name(pg_current_wal_lsn());

#   ALTER SYSTEM SET synchronous_standby_names TO  '*';
#      restart postgresql
  
#   commit first on standby

slave :
select pg_is_in_recovery();

# select * from pg_last_wal_receive_lsn();

   
  

  # select pg_promote();
  #  bash-4.2$ /usr/pgsql-11/bin/pg_ctl promote -D /var/lib/pgsql/11/data