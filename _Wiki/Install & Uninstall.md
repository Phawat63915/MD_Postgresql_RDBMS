# 

## Ubuntu 22.04 LTS, 20.04 LTS, 18.04 LTS and Debian 11, 10, 9

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. เช็คว่ามี PostgreSQL Package ว่าเป็นเวอร์ชั้นที่เราต้องการหรือไม่
```bash
sudo apt-cache search postgresql | grep postgresql
```
2. Add PostgreSQL Package Repository (หากไม่มีให้เพิ่มเข้าไป)
```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
```bash
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
```
```bash
sudo apt update -y
```
**Step 2: Install PostgreSQL 15 Database Server and Client**

(15.1) Latest Version 

```bash
sudo apt install postgresql postgresql-client -y
```
<details><summary>Other version (1-14)</summary>

(14.0)
```bash
sudo apt install postgresql-14 postgresql-client-14 -y
```
(13.4)
```bash
sudo apt install postgresql-13 postgresql-client-13 -y
```
(12.8)
```bash
sudo apt install postgresql-12 postgresql-client-12 -y
```
(11.13)
```bash
sudo apt install postgresql-11 postgresql-client-11 -y
```
(10.18)
```bash
sudo apt install postgresql-10 postgresql-client-10 -y
```
(9.6.23)
```bash
sudo apt install postgresql-9.6 postgresql-client-9.6 -y
```
(9.5.27)
```bash
sudo apt install postgresql-9.5 postgresql-client-9.5 -y
```
(9.4.32)
```bash
sudo apt install postgresql-9.4 postgresql-client-9.4 -y
```
(9.3.27)
```bash
sudo apt install postgresql-9.3 postgresql-client-9.3 -y
```
(9.2.24)
```bash
sudo apt install postgresql-9.2 postgresql-client-9.2 -y
```
(9.1.24)
```bash
sudo apt install postgresql-9.1 postgresql-client-9.1 -y
```
(9.0.24)
```bash
sudo apt install postgresql-9.0 postgresql-client-9.0 -y
```
(8.4.23)
```bash
sudo apt install postgresql-8.4 postgresql-client-8.4 -y
```
(8.3.23)
```bash
sudo apt install postgresql-8.3 postgresql-client-8.3 -y
```
(8.2.23)
```bash
sudo apt install postgresql-8.2 postgresql-client-8.2 -y
```
(8.1.23)
```bash
sudo apt install postgresql-8.1 postgresql-client-8.1 -y
```
(8.0.23)
```bash
sudo apt install postgresql-8.0 postgresql-client-8.0 -y
```
(7.4.25)
```bash
sudo apt install postgresql-7.4 postgresql-client-7.4 -y
```
(7.3.26)
```bash
sudo apt install postgresql-7.3 postgresql-client-7.3 -y
```
(7.2.5)
```bash
sudo apt install postgresql-7.2 postgresql-client-7.2 -y
```
(7.1.5)
```bash
sudo apt install postgresql-7.1 postgresql-client-7.1 -y
```
(7.0.5)
```bash
sudo apt install postgresql-7.0 postgresql-client-7.0 -y
```
(6.5.5)
```bash
sudo apt install postgresql-6.5 postgresql-client-6.5 -y
```
(6.4.5)
```bash
sudo apt install postgresql-6.4 postgresql-client-6.4 -y
```
(6.3.5)
```bash
sudo apt install postgresql-6.3 postgresql-client-6.3 -y
```
(6.2.5)
```bash
sudo apt install postgresql-6.2 postgresql-client-6.2 -y
```
(6.1.5)
```bash
sudo apt install postgresql-6.1 postgresql-client-6.1 -y
```
(6.0.5)
```bash
sudo apt install postgresql-6.0 postgresql-client-6.0 -y
```
(5.0.5)
```bash
sudo apt install postgresql-5.0 postgresql-client-5.0 -y
```
(4.4.5)
```bash
sudo apt install postgresql-4.0 postgresql-client-4.0 -y
```
(3.3.5)
```bash
sudo apt install postgresql-3.0 postgresql-client-3.0 -y
```
(2.2.5)
```bash
sudo apt install postgresql-2.0 postgresql-client-2.0 -y
```
(1.1.5)
```bash
sudo apt install postgresql-1.0 postgresql-client-1.0 -y
```

</details>

**Step 3: Start PostgreSQL Database Server**

```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql
```

**Step 5: Check PostgreSQL Version**
```bash
sudo -u postgres psql -c "SELECT version();"
```
OR:
```bash
psql --version
```

### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
```




## Red Hat Enterprise, Rocky, or Oracle version 9, 8

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. Add PostgreSQL Package Repository (หากไม่มีให้เพิ่มเข้าไป)

<details><summary>Red Hat Enterprise, Rocky, or Oracle version 9</summary>

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

</details>

<details><summary>Red Hat Enterprise, Rocky, or Oracle version 8</summary>

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

</details>

```bash
sudo dnf -qy module disable postgresql
```

**Step 2: Install PostgreSQL 15 Database Server and Client Select a version next step**

<details><summary>(15.1) Latest Version </summary>

```bash
sudo dnf install -y postgresql15-server postgresql15-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-15
```

</details>

<details><summary>(14.0) Old Version </summary>

```bash
sudo dnf install -y postgresql14-server postgresql14-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-14
```

</details>

<details><summary>(13.4) Old Version </summary>

```bash
sudo dnf install -y postgresql13-server postgresql13-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-13
```

</details>

<details><summary>(12.8) Old Version </summary>

```bash
sudo dnf install -y postgresql12-server postgresql12-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-12
```

</details>

<details><summary>(11.13) Old Version </summary>

```bash
sudo dnf install -y postgresql11-server postgresql11-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-11
```

</details>

**Step 5: Check PostgreSQL Version**
```bash
sudo -u postgres psql -c "SELECT version();"
```
OR:
```bash
psql --version
```

<!-- ### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
``` -->

## Red Hat Enterprise, CentOS, Scientific or Oracle version 7

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. Add PostgreSQL Package Repository (หากไม่มีให้เพิ่มเข้าไป)
```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```
```bash
sudo dnf -qy module disable postgresql
```

**Step 2: Install PostgreSQL 15 Database Server and (Select a version to Next Step)**

<details><summary>(15.1) Latest Version </summary>

```bash
sudo dnf install -y postgresql15-server postgresql15-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-15
```

</details>

<details><summary>(14.0) Old Version </summary>

```bash
sudo dnf install -y postgresql14-server postgresql14-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-14
```

</details>

<details><summary>(13.4) Old Version </summary>

```bash
sudo dnf install -y postgresql13-server postgresql13-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-13
```

</details>

<details><summary>(12.8) Old Version </summary>

```bash
sudo dnf install -y postgresql12-server postgresql12-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-12
```

</details>

<details><summary>(11.13) Old Version </summary>

```bash
sudo dnf install -y postgresql11-server postgresql11-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-11
```

</details>

**Step 5: Check PostgreSQL Version**
```bash
sudo -u postgres psql -c "SELECT version();"
```
OR:
```bash
psql --version
```

<!-- ### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
``` -->




## Red Hat Enterprise, CentOS, Scientific or Oracle version 6

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. Add PostgreSQL Package Repository (หากไม่มีให้เพิ่มเข้าไป)
```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```
```bash
sudo dnf -qy module disable postgresql
```

**Step 2: Install PostgreSQL 15 Database Server and (Select a version to Next Step)**

<details><summary>(15.1) Latest Version </summary>

```bash
sudo dnf install -y postgresql15-server postgresql15-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-15
```

</details>

<details><summary>(14.0) Old Version </summary>

```bash
sudo dnf install -y postgresql14-server postgresql14-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-14
```

</details>

<details><summary>(13.4) Old Version </summary>

```bash
sudo dnf install -y postgresql13-server postgresql13-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-13
```

</details>

<details><summary>(12.8) Old Version </summary>

```bash
sudo dnf install -y postgresql12-server postgresql12-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-12
```

</details>

<details><summary>(11.13) Old Version </summary>

```bash
sudo dnf install -y postgresql11-server postgresql11-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-11
```

</details>

**Step 5: Check PostgreSQL Version**
```bash
sudo -u postgres psql -c "SELECT version();"
```
OR:
```bash
psql --version
```

<!-- ### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
``` -->




## Fedora version 37, 36

### Install

**Step 1: Enable PostgreSQL 15 Package Repository**
1. Add PostgreSQL Package Repository (หากไม่มีให้เพิ่มเข้าไป)

<details><summary>Fedora version 37</summary>

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-37-x86_64/pgdg-fedora-repo-latest.noarch.rpm
```

</details>

<details><summary>Fedora version 36</summary>

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-36-x86_64/pgdg-fedora-repo-latest.noarch.rpm
```

</details>


**Step 2: Install PostgreSQL 15 Database Server and Client (Select a version to Next Step)**

<details><summary>(15.1) Latest Version </summary>

```bash
sudo dnf install -y postgresql15-server postgresql15-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-15
```

</details>

<details><summary>(14.0) Old Version </summary>

```bash
sudo dnf install -y postgresql14-server postgresql14-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-14
```

</details>

<details><summary>(13.4) Old Version </summary>

```bash
sudo dnf install -y postgresql13-server postgresql13-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-13
```

</details>

<details><summary>(12.8) Old Version </summary>

```bash
sudo dnf install -y postgresql12-server postgresql12-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-12
```

</details>

<details><summary>(11.13) Old Version </summary>

```bash
sudo dnf install -y postgresql11-server postgresql11-client
```

**Step 3: Start PostgreSQL Database Server**

```bash
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11
```

**Step 4: Check PostgreSQL Database Server Status**

```bash
systemctl status postgresql-11
```

</details>

**Step 5: Check PostgreSQL Version**
```bash
sudo -u postgres psql -c "SELECT version();"
```
OR:
```bash
psql --version
```

<!-- ### Uninstall
```bash
sudo apt-get --purge remove postgresql postgresql-* -y && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/
``` -->



