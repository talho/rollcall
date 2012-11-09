php ./attendance.php
php ./symptoms.php

sftp -oIdentityFile=isd.rsa isd@s1.talho.org <<EOF
  put attendance.csv
  put symptoms.csv
  exit
EOF
