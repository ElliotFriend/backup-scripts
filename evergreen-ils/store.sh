#!/bin/bash

SUBJECT="Evergreen Cron Alert"
TO="yourname@example.com"
FROM="evergreen@example.com"
MESSAGE="/tmp/store-message.txt"

# On January 11, archive last year's directory of archives
LAST_YEAR=$(date -d '1 year ago' +'%Y')

# Put some information at the top of the email message
echo "Evergreen Yearly Storage Archive" >> $MESSAGE
echo "TIME: `date`" >> $MESSAGE

# Check to make sure that last year's directory actually exists
if [ -d /backup/archive/$LAST_YEAR ]; then
    echo "Last year's directory exists. Continuing..." >> $MESSAGE

    # Store the name of all files in a temp file
    FILES="/tmp/files.txt"
    ls /backup/archive/$LAST_YEAR > $FILES

    # Check to make sure that only evergreen_XX.tar.gz files exist
    if grep -v --quiet 'evergreen_[0-1][0-9].tar.gz' $FILES; then
        echo "Unexpected files found in /backup/archive/$LAST_YEAR/. No action taken." >> $MESSAGE
    else
        echo "Expected files found in /backup/archive/$LAST_YEAR/. Continuing..." >> $MESSAGE
        # create a tar.gz file, containing all of the individual monthly backups
        tar -zcvf /backup/archive/evergreen_${LAST_YEAR}.tar.gz /backup/archive/$LAST_YEAR 2>&1 >> $MESSAGE
        # remove the unarchived directory
        rm -rf /backup/archive/${LAST_YEAR}
    fi
else
    # Directory does not exist, somebody make a decision
    echo "Last year's directory does not exist. No action taken." >> $MESSAGE
fi

#cat $MESSAGE
# Send an email with all of the logging for this
/usr/sbin/sendmail "$TO" <<EOF
subject:$SUBJECT
from:$FROM
`cat $MESSAGE`
EOF

# Clean up our temporary files
rm $FILES
rm $MESSAGE
