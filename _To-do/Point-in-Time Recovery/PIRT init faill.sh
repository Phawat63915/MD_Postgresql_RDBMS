# Install pg

sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version




# create directory for archive logs
sudo -H -u postgres mkdir /var/lib/postgresql/pg_log_archive

# enable archive logging
sudo vi /etc/postgresql/15/main/postgresql.conf

  wal_level = replica
  archive_mode = on # (change requires restart)
  archive_command = 'test ! -f /var/lib/postgresql/pg_log_archive/%f && cp %p /var/lib/postgresql/pg_log_archive/%f'

# restart cluster
sudo systemctl restart postgresql@15-main.service

# create database with some data
sudo su - postgres
psql -c "create database test;"
psql test -c "
create table posts (
  id integer,
  title character varying(100),
  content text,
  published_at timestamp without time zone,
  type character varying(100)
);

insert into posts (id, title, content, published_at, type) values
(100, 'Intro to SQL', 'Epic SQL Content', '2018-01-01', 'SQL'),
(101, 'Intro to PostgreSQL', 'PostgreSQL is awesome!', now(), 'PostgreSQL');
"

# archive the logs
psql -c "select pg_switch_wal();" # pg_switch_xlog(); for versions < 10

# backup database
pg_basebackup -v -Ft -D ./db_file_backup

# stop DB and destroy data
sudo systemctl stop postgresql@15-main.service
rm /var/lib/postgresql/15/main/* -r
ls /var/lib/postgresql/15/main/

# restore
tar xvf /var/lib/postgresql/db_file_backup/base.tar -C /var/lib/postgresql/15/main/
tar xvf /var/lib/postgresql/db_file_backup/pg_wal.tar -C /var/lib/postgresql/15/main/pg_wal/

# add recovery.conf
sudo vi /etc/postgresql/15/main/postgresql.conf

  restore_command = 'cp /var/lib/postgresql/pg_log_archive/%f %p'

# start DB
sudo systemctl start postgresql@15-main.service

# verify restore was successful
sudo su - postgres
psql test -c "select * from posts;"

##################### Do PITR to a Specific Time ###############################

# backup database and gzip

# /var/lib/postgresql/

pg_basebackup -v -Ft -X none -D - > db_file_backup.tar
pg_basebackup -v -Ft -X none -D ./db_file_backup2

# wait
psql test -c "insert into posts (id, title, content, type) values
(102, 'Intro to SQL Where Clause', 'Easy as pie!', 'SQL'),
(103, 'Intro to SQL Order Clause', 'What comes first?', 'SQL');"
2023-02-11 10:27:32 UTC
# archive the logs
psql -c "select pg_switch_wal();" # pg_switch_xlog(); for versions < 10

# stop DB and destroy data
sudo systemctl stop postgresql@15-main.service
rm /var/lib/postgresql/15/main/* -r
ls /var/lib/postgresql/15/main/

# restore
# tar -xvf /var/lib/postgresql/db_file_backup.tar -C /var/lib/postgresql/15/main/
tar xvf /var/lib/postgresql/db_file_backup2/base.tar -C /var/lib/postgresql/15/main/
tar xvf /var/lib/postgresql/db_file_backup2/pg_wal.tar -C /var/lib/postgresql/15/main/pg_wal/



# add recovery.conf
sudo vi /etc/postgresql/15/main/postgresql.conf

  restore_command = 'cp /var/lib/postgresql/pg_log_archive/%f %p'
  recovery_target_time = '2018-02-22 15:20:00 EST'

  2023-02-10 09:20:57 UTC

# start DB
sudo systemctl start postgresql@15-main.service

# verify restore was successful
psql test -c "select * from posts;"
tail -n 100 /var/log/postgresql/postgresql-10-main.log

# complete and enable database restore
psql -c "select pg_wal_replay_resume();"