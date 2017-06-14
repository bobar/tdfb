#! /bin/bash

ts=`date "+%Y-%m-%d %H:%M"`
filepath="/tmp/tdb_dump_`echo $ts | sed \"s/ /_/g\"`.sql.gz"
mysqldump --net-buffer-length=8192 --add-locks --disable-keys --single-transaction -uroot -p$PASSWD tdb | gzip > $filepath
sendEmail -f bobar.save@gmail.com -t bobar.save@gmail.com -u "DB dump $ts" -m "See attachment" -s smtp.gmail.com:587 -o tls=yes -xu bobar.save@gmail.com -xp $PASSWD -a $filepath > /dev/null
rm $filepath
