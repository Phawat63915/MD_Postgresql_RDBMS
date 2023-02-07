## Ubuntu

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. เช็คว่ามี PostgreSQL Package ว่าเป็นเวอร์ชั้นที่เราต้องการหรือไม่
```bash
sudo apt-cache search postgresql | grep postgresql
```
2. Setup PostgreSQL 15 Package Repository (หากไม่มีให้เพิ่มเข้าไป)
```bash
 sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
```
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
```
```
sudo apt update -y
```
**Step 2: Install PostgreSQL 15 Database Server and Client**

Latest Version (15.1)
```bash
sudo apt install postgresql postgresql-client -y
```
<details><summary>Other version (1-14)</summary>

15.0
```bash
sudo apt install postgresql-15 postgresql-client-15 -y
```
14.0
```bash
sudo apt install postgresql-14 postgresql-client-14 -y
```
13.4
```bash
sudo apt install postgresql-13 postgresql-client-13 -y
```
12.8
```bash
sudo apt install postgresql-12 postgresql-client-12 -y
```
11.13
```bash
sudo apt install postgresql-11 postgresql-client-11 -y
```
10.18
```bash
sudo apt install postgresql-10 postgresql-client-10 -y
```
9.6.23
```bash
sudo apt install postgresql-9.6 postgresql-client-9.6 -y
```
9.5.27
```bash
sudo apt install postgresql-9.5 postgresql-client-9.5 -y
```
9.4.32
```bash
sudo apt install postgresql-9.4 postgresql-client-9.4 -y
```
9.3.27
```bash
sudo apt install postgresql-9.3 postgresql-client-9.3 -y
```
9.2.24
```bash
sudo apt install postgresql-9.2 postgresql-client-9.2 -y
```
9.1.24
```bash
sudo apt install postgresql-9.1 postgresql-client-9.1 -y
```
9.0.24
```bash
sudo apt install postgresql-9.0 postgresql-client-9.0 -y
```
8.4.23
```bash
sudo apt install postgresql-8.4 postgresql-client-8.4 -y
```
8.3.23
```bash
sudo apt install postgresql-8.3 postgresql-client-8.3 -y
```
8.2.23
```bash
sudo apt install postgresql-8.2 postgresql-client-8.2 -y
```
8.1.23
```bash
sudo apt install postgresql-8.1 postgresql-client-8.1 -y
```
8.0.23
```bash
sudo apt install postgresql-8.0 postgresql-client-8.0 -y
```
7.4.25
```bash
sudo apt install postgresql-7.4 postgresql-client-7.4 -y
```
7.3.26
```bash
sudo apt install postgresql-7.3 postgresql-client-7.3 -y
```
7.2.5
```bash
sudo apt install postgresql-7.2 postgresql-client-7.2 -y
```
7.1.5
```bash
sudo apt install postgresql-7.1 postgresql-client-7.1 -y
```
7.0.5
```bash
sudo apt install postgresql-7.0 postgresql-client-7.0 -y
```
6.5.5
```bash
sudo apt install postgresql-6.5 postgresql-client-6.5 -y
```
6.4.5
```bash
sudo apt install postgresql-6.4 postgresql-client-6.4 -y
```
6.3.5
```bash
sudo apt install postgresql-6.3 postgresql-client-6.3 -y
```
6.2.5
```bash
sudo apt install postgresql-6.2 postgresql-client-6.2 -y
```
6.1.5
```bash
sudo apt install postgresql-6.1 postgresql-client-6.1 -y
```
6.0.5
```bash
sudo apt install postgresql-6.0 postgresql-client-6.0 -y
```
5.0.5
```bash
sudo apt install postgresql-5.0 postgresql-client-5.0 -y
```
4.4.5
```bash
sudo apt install postgresql-4.0 postgresql-client-4.0 -y
```
4.3.5
```bash
sudo apt install postgresql-3.0 postgresql-client-3.0 -y
```
4.2.5
```bash
sudo apt install postgresql-2.0 postgresql-client-2.0 -y
```
4.1.5
```bash
sudo apt install postgresql-1.0 postgresql-client-1.0 -y
```

</details>

<!-- ```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql
```
```bash
systemctl status postgresql
```
```bash
sudo -u postgres psql -c "SELECT version();"
```
```bash
psql --version
``` -->

### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
```