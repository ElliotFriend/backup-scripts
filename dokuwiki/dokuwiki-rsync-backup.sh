#!/bin/sh

#========================
# backup script for stuff on wiki to be run periodically through a crontab on a trusted server
# > crontab -e
#
# daily : 1 1 * * * /path/to/script/wwwbackup.sh
# weekly: 1 1 * * 0 /path/to/script/wwwbackup.sh # I Guess weekly backup is enough for not frequetly updated wiki
#========================
#here=`pwd`
mydate="`date '+%Y%m%d.%H%M'`"
 
# Define wiki location
myhost='wiki.example.com'	       #name of the server hosting your your wiki
myuser='yourname'                  #name of the user that has an ssh access to "myhost"
relpathtowiki='/var/www/'          #relative path to your wiki from "myhost" base
backupsource="${myuser}@${myhost}:${relpathtowiki}"
#backupsource="/abs/path/to/wiki/" #Use this line instead of the above if you run the backup script directly on your www server.
 
# Define location of backup
backupdir="/backup/dokuwiki/${myhost}"
logfile="${backupdir}/backup.log"
excludelist="/root/scripts/backup/dokuwiki/wwwbackup-exclude-list.txt"
 
bkname="dokuwiki-backup"
 
nbbackup="15" # keep this amount of old backup
 
#-- creates $1, if not existant
checkDir() {
    if [ ! -d "${backupdir}/$1" ] ; then
        mkdir -p "${backupdir}/$1"
    fi
}
 
# 1 -> path
# 2 -> name
# 3 -> number of backups
rotateDir() {
    for i in `seq $(($3 - 1)) -1 0`
      do
      if [ -d "$1/$2-$i" ] ; then
          /bin/rm -f "$1/$2-$((i + 1))"
          mv "$1/$2-$i" "$1/$2-$((i + 1))"
      fi
    done
}
 
#-- make sure everything exists
checkDir "archive"
checkDir "daily"
 
#-- first step: rotate daily.
rotateDir "${backupdir}/daily" "$bkname" "$nbbackup"
 
mv ${logfile} ${backupdir}/daily/${bkname}-1/
 
cat >> ${logfile} <<_EOF
===========================================
  Backup done on: $mydate
===========================================
_EOF
 
#-- Do the backup and save difference in backup-1
mkdir -p ${backupdir}/daily/${bkname}-1/
mkdir -p ${backupdir}/daily/${bkname}-0/
cd ${backupdir}/daily/${bkname}-0
rsync -av -e "ssh -p 2322" --whole-file --delete --force \
    -b --backup-dir ${backupdir}/daily/${bkname}-1/${thisdir} \
    --exclude-from=${excludelist} \
    $backupsource . \
    1>> ${logfile} 2>&1
 
#-- create an archive backup every month
lastarchivetime="0"
if [ -r ${backupdir}/lastarchivetime ] ; then
  lastarchivetime=`cat ${backupdir}/lastarchivetime`
fi
now=`date +%j`
let diffday=$now-$lastarchivetime
if [ $diffday  -ge 30 -o $diffday -lt 0 ] ; then
    echo $now > ${backupdir}/lastarchivetime
    cd ${backupdir}/daily
    tar -cjf ${backupdir}/archive/${bkname}-${mydate}.tar.bz2 ./${bkname}-0
fi
