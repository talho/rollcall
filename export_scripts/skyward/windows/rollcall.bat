@echo off
C:
cd \rollcall
php ./attendance.php
php ./symptoms.php
cd "\Program Files (x86)\WinSCP"
winscp.exe /console /script=C:\rollcall\upload.txt /log=c:\rollcall\sftplog.txt
cd \rollcall
