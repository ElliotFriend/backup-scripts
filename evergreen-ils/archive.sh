#!/bin/bash

source $(dirname $0)/var_file.sh

# Every day, a little past midnight, archive yesterday's backup files.
# Set some variables that we'll use for date information
# We're keeping these here, because they're not needed by other scripts
YESTERDAY_FULL=$(date -d '1 day ago' +'%Y%m%d')
YESTERDAY_YEAR=$(date -d '1 day ago' +'%Y')
YESTERDAY_MONTH=$(date -d '1 day ago' +'%m')

LAST_WEEK_FULL=$(date -d '1 week ago' +'%Y%m%d')
LAST_WEEK_YEAR=$(date -d '1 week ago' +'%Y')
LAST_WEEK_MONTH=$(date -d '1 week ago' +'%m')

# Put some info at the top of the email
echo 'Evergreen Daily Archive' >> ${MESSAGE}
echo "TIME: `date`" >> ${MESSAGE}

# Backup our backup scripts
echo 'Backing up backup scripts.' >> ${MESSAGE}
cp $(dirname $0)/* ${BACKUP_DIR}/scripts

# Check to make sure the appropriate archive directories exist
if [ -d ${BACKUP_DIR}/archive/${YESTERDAY_YEAR} ]; then
    echo 'Year archive directory exists. No action taken.' >> ${MESSAGE}
else
    echo 'Making year archive directory.' >> ${MESSAGE}
    mkdir ${BACKUP_DIR}/archive/${YESTERDAY_YEAR}
fi

if [ -d ${BACKUP_DIR}/archive/${YESTERDAY_YEAR}/${YESTERDAY_MONTH} ]; then
    echo 'Month archive directory exists. No action taken.' >> ${MESSAGE}
else
    echo 'Making month archive directory.' >> ${MESSAGE}
    mkdir ${BACKUP_DIR}/archive/${YESTERDAY_YEAR}/${YESTERDAY_MONTH}
fi

## copy the last dbdump to our off-site backup destination
echo 'Trying to backup the most recent db dump offsite; to Los Angeles, son!!' >> ${MESSAGE}
tar -zcvf /tmp/evergreen_${YESTERDAY_FULL}.tar.gz ${BACKUP_DIR}/evergreen_${YESTERDAY_FULL}_23.backup
scp /tmp/evergreen_${YESTERDAY_FULL}.tar.gz ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${YESTERDAY_YEAR}/
if [ "$?" -eq '0' ]; then
    echo 'Offsite backup successful; rest easy.' >> ${MESSAGE}
else
    echo 'Offsite backup failed; check on that!' >> ${MESSAGE}
fi


# Move all of yesterday's files to the corresponding archive directory
echo 'Moving database dumps from yesterday to archive.' >> ${MESSAGE}
mv ${BACKUP_DIR}/evergreen_${YESTERDAY_FULL}_*.backup ${BACKUP_DIR}/archive/${YESTERDAY_YEAR}/${YESTERDAY_MONTH}/


# Remove all of last_week_full's files, with the exception of 23:00 dbdump
echo 'Removing excessive archives from last week. Keeping 23:00 dbdump for each day.' >> ${MESSAGE}
ls ${BACKUP_DIR}/archive/${LAST_WEEK_YEAR}/${LAST_WEEK_MONTH}/evergreen_${LAST_WEEK_FULL}* | grep -v evergreen_${LAST_WEEK_FULL}_23.backup | xargs rm

# Send an email with all of the information from this script
# 'sendmail' may not be available in your distribution,
# or may be in a different location
/usr/sbin/sendmail "${TO}" <<EOF
subject:${SUBJECT}
from:${FROM}
`cat ${MESSAGE}`
EOF

# Clean up our temporary files
rm /tmp/evergreen_${YESTERDAY_FULL}.tar.gz
rm ${MESSAGE}
