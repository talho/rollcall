@echo off
C:
cd \rollcall
dbisql -c "uid=dba;pwd=;eng=txeis;dbn=db"  Rollcall_Attendance.sql
dbisql -c "uid=dba;pwd=;eng=txeis;dbn=db"  Rollcall_Symptoms.sql
cd "\Program Files (x86)\WinSCP"
winscp.exe /console /script=C:\rollcall\upload.txt /log=c:\rollcall\sftplog.txt
cd \rollcall
