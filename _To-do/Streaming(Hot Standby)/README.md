# Introduction
PostgreSQL Streaming หรือ Hot Standby เป็นการเปิดใช้งานฟีเจอร์ที่ช่วยให้สามารถสร้างการสำรองข้อมูลแบบ Real-time ได้โดยไม่มีการหยุดเซิร์ฟเวอร์หลัก (Primary Server) และสามารถใช้งานต่อเนื่องได้โดยไม่มีการตั้งค่าเพิ่มเติมในส่วนของโปรแกรม PostgreSQL

โดยการ Streaming ข้อมูลจะถูกส่งไปยังตัว Hot Standby Server โดยตรงโดยใช้โพรโตคอลการสื่อสารของ PostgreSQL โดยจะมีการตรวจสอบความถูกต้องและการแนะนำแบบ Streaming Replication ที่มาพร้อมกับ PostgreSQL 9.0 ขึ้นไปทำให้การใช้งานแบบ Hot Standby ใน PostgreSQL สามารถสร้างระบบโดยไม่ยุ่งยากและมีความยืดหยุ่นสูงในการใช้งาน

# Manual List
- [Streaming(Hot Standby) Basic](./SHS-15.md)
