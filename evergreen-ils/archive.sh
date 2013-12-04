#!/bin/bash

SUBJECT="Evergreen Cron Alert"
TO="yourname@example.com"
FROM="evergreen@example.com"
MESSAGE="/tmp/archive-message.txt"

## Every day, a little past midnight, archive yesterday's backup files.
## Set some variables that we'll use for date and time stamps
YESTERDAY_FULL=$(date -d '1 day ago' +'%Y%m%d')
YESTERDAY_YEAR=$(date -d '1 day ago' +'%Y')
YESTERDAY_MONTH=$(date -d '1 day ago' +'%m')
YESTERDAY_DAY=$(date -d '1 day ago' +'%d')

LAST_WEEK_FULL=$(date -d '1 week ago' +'%Y%m%d')
LAST_WEEK_YEAR=$(date -d '1 week ago' +'%Y')
LAST_WEEK_MONTH=$(date -d '1 week ago' +'%m')
LAST_WEEK_DAY=$(date -d '1 week ago' +'%d')

# Put some info at the top of the email
echo "Evergreen Daily Archive" >> $MESSAGE
echo "TIME: `date`" >> $MESSAGE

## Backup our backup scripts
echo "Backing up backup scripts (meta, right?)." >> $MESSAGE
cp /root/scripts/evergreen/* /backup/scripts

## Check to make sure the appropriate archive directories exist
if [ -d /backup/archive/$YESTERDAY_YEAR ]; then
    echo "Year archive directory exists. No action taken." >> $MESSAGE
else
    echo "Making year archive directory." >> $MESSAGE
    mkdir /backup/archive/$YESTERDAY_YEAR
fi

if [ -d /backup/archive/$YESTERDAY_YEAR/$YESTERDAY_MONTH ]; then
    echo "Month archive directory exists. No action taken." >> $MESSAGE
else
    echo "Making month archive directory." >> $MESSAGE
    mkdir /backup/archive/$YESTERDAY_YEAR/$YESTERDAY_MONTH
fi

## copy the last dbdump to our off-site backup destination
echo "Trying to backup the most recent db dump offsite; to Los Angeles, son!!" >> $MESSAGE
tar -zcvf /tmp/evergreen_${YESTERDAY_FULL}.tar.gz /backup/evergreen_${YESTERDAY_FULL}_23.backup
scp /tmp/evergreen_${YESTERDAY_FULL}.tar.gz remoteuser@example.com:evergreen/
if [ "$?" -eq "0" ]; then
    echo "Offsite backup successful; rest easy." >> $MESSAGE
else
    echo "Offsite backup failed; check on that!" >> $MESSAGE
fi


## Move all of yesterday's files to the corresponding archive directory
echo "Moving yesterday's database dumps to archive." >> $MESSAGE
mv /backup/evergreen_${YESTERDAY_FULL}_*.backup /backup/archive/$YESTERDAY_YEAR/$YESTERDAY_MONTH/


## Remove all of last_week_full's files, with the exception of 23:00 dbdump
echo "Removing excessive archives from last week. Keeping 23:00 dbdump for each day." >> $MESSAGE
ls /backup/archive/$LAST_WEEK_YEAR/$LAST_WEEK_MONTH/evergreen_${LAST_WEEK_FULL}* | grep -v evergreen_${LAST_WEEK_FULL}_23.backup | xargs rm

# Send an email with all of the information from this script
/usr/sbin/sendmail "$TO" <<EOF
subject:$SUBJECT
from:$FROM
`cat $MESSAGE`
EOF

# Clean up our temporary files
rm /tmp/evergreen_${YESTERDAY_FULL}.tar.gz
rm $MESSAGE
