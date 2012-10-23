@echo off
C:
cd \rollcall
SQLCMD -S MyInstance -E -d dbname -i attendance.sql -o attendance.csv -s ,
SQLCMD -S MyInstance -E -d dbname -i symptoms.sql -o attendance.csv -s ,
cd "\Program Files (x86)\WinSCP"
winscp.exe /console /script=C:\rollcall\upload.txt /log=c:\rollcall\sftplog.txt
cd \rollcall
