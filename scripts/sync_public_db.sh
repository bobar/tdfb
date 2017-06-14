#! /bin/bash

ts=`date -d "-6 months" "+%Y-%m-%d %H:%M:%S"` # 6 months ago
mysqldump --net-buffer-length=8192 --add-locks --disable-keys --single-transaction -uroot -p$PASSWD tdb accounts admins clopes droits users > /tmp/public_db.sql
mysqldump --net-buffer-length=8192 --add-locks --disable-keys --single-transaction -uroot -p$PASSWD tdb transactions --where="date >= '$ts'" >> /tmp/public_db.sql
gzip -c /tmp/public_db.sql > /tmp/public_db.sql.gz
rm /tmp/public_db.sql
lftp -u bob,$PASSWD -e "put /tmp/public_db.sql.gz -o tdb_dump.sql.gz; exit" ftp.bobar.pro
rm /tmp/public_db.sql.gz
