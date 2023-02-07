
### Ubuntu

#### Install

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

Latest Version (15)
```bash
sudo apt install postgresql postgresql-client -y
```
<details><summary>Other version</summary>

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