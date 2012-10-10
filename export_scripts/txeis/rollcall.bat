@echo off
C:
cd \rollcall
dbisql -c "uid=dba;pwd=043917;eng=txeis;dbn=db043917"  RollCall_Attendance.sql
cd "\Program Files (x86)\WinSCP"
winscp.exe /console /script=C:\rollcall\upload.txt /log=c:\rollcall\sftplog.txt
cd \rollcall
