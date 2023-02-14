# https://pgpedia.info/r/recovery.conf.html
# ทำได้แค่ postgresql 0-11 หรือต่ำกว่า ใหม่อย่าง 15 ไม่ได้

# https://www.postgresql.org/docs/10/static/continuous-archiving.html


# Install postgresql 10

sudo apt-cache search postgresql | grep postgresql && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null && sudo apt update -y && sudo apt install -y postgresql-10 && sudo systemctl enable postgresql && sudo systemctl start postgresql && systemctl status postgresql && psql --version



# create directory for archive logs
sudo -H -u postgres mkdir /var/lib/postgresql/pg_log_archive

# enable archive logging
sudo vi /etc/postgresql/10/main/postgresql.conf

  wal_level = replica
  archive_mode = on # (change requires restart)
  archive_command = 'test ! -f /var/lib/postgresql/pg_log_archive/%f && cp %p /var/lib/postgresql/pg_log_archive/%f'

# restart cluster
sudo systemctl restart postgresql@10-main

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
pg_basebackup -Ft -D /var/lib/postgresql/db_file_backup

# stop DB and destroy data
sudo systemctl stop postgresql@10-main
rm /var/lib/postgresql/10/main/* -r
ls /var/lib/postgresql/10/main/

# restore
tar xvf /var/lib/postgresql/db_file_backup/base.tar -C /var/lib/postgresql/10/main/
tar xvf /var/lib/postgresql/db_file_backup/pg_wal.tar -C /var/lib/postgresql/10/main/pg_wal/

# add recovery.conf
vi /var/lib/postgresql/10/main/recovery.conf

  restore_command = 'cp /var/lib/postgresql/pg_log_archive/%f %p'

# start DB
sudo systemctl start postgresql@10-main

# verify restore was successful
psql test -c "select * from posts;"

##################### Do PITR to a Specific Time ###############################

# backup database and gzip
pg_basebackup -Ft -X none -D - | gzip > /var/lib/postgresql/db_file_backup.tar.gz

# wait
psql test -c "insert into posts (id, title, content, published_at, type) values
(101, 'Intro to PostgreSQL', 'PostgreSQL is awesome!', now(), 'PostgreSQL');"


# archive the logs
psql -c "select pg_switch_wal();" # pg_switch_xlog(); for versions < 10

# stop DB and destroy data
sudo systemctl stop postgresql@10-main
rm /var/lib/postgresql/10/main/* -r
ls /var/lib/postgresql/10/main/

# restore
tar xvfz /var/lib/postgresql/db_file_backup.tar.gz -C /var/lib/postgresql/10/main/

# add recovery.conf
vi /var/lib/postgresql/10/main/recovery.conf

restore_command = 'cp /var/lib/postgresql/pg_log_archive/%f %p'
recovery_target_time = '2017-02-22 15:20:00'

recovery_target_time = '2023-02-11 11:54:19.772138'

# case 2
timedatectl

restore_command = 'cp /var/lib/postgresql/pg_log_archive/%f %p'
recovery_target_time = '2022-02-11 11:45:40 UTC'

# start DB
sudo systemctl start postgresql@10-main

# verify restore was successful
psql test -c "select * from posts;"
tail -n 100 /var/log/postgresql/postgresql-10-main.log

# complete and enable database restore
psql -c "select pg_wal_replay_resume();"












# Other

# select * from current_timestamp;