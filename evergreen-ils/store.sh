#!/bin/bash

source $(dirname $0)/var_file.sh

# On January 11, archive last year's directory of archives
# We're keeping this here, because it's not needed by other scripts
LAST_YEAR=$(date -d '1 year ago' +'%Y')

# Put some information at the top of the email message
echo 'Evergreen Yearly Storage Archive' >> ${MESSAGE}
echo "TIME: `date`" >> ${MESSAGE}

# Check to make sure that last year's directory actually exists
if [ -d ${BACKUP_DIR}/archive/${LAST_YEAR} ]; then
    echo 'Directory for last year exists. Continuing with backup.' >> ${MESSAGE}

    # Store the name of all files in a temp file
    FILES='/tmp/files.txt'
    ls ${BACKUP_DIR}/archive/${LAST_YEAR} > ${FILES}

    # Check to make sure that only evergreen_XX.tar.gz files exist
    if grep -v --quiet 'evergreen_[0-1][0-9].tar.gz' ${FILES}; then
        echo "Unexpected files found in ${BACKUP_DIR}/archive/${LAST_YEAR}/. No action taken." >> ${MESSAGE}
    else
        echo "Expected files found in ${BACKUP_DIR}/archive/${LAST_YEAR}/. Continuing with backup." >> ${MESSAGE}
        # create a tar.gz file, containing all of the individual monthly backups
        tar -zcvf ${BACKUP_DIR}/archive/evergreen_${LAST_YEAR}.tar.gz ${BACKUP_DIR}/archive/${LAST_YEAR} 2>&1 >> ${MESSAGE}
        # remove the unarchived directory
        rm -rf ${BACKUP_DIR}/archive/${LAST_YEAR}
    fi
else
    # Directory does not exist, there's nothing to backup
    echo 'Directory for last year does not exist. No action taken.' >> ${MESSAGE}
fi

# Send an email with all of the information from this script
# 'sendmail' may not be available in your distribution,
# or may be in a different location. Edit accordingly.
/usr/sbin/sendmail "${TO}" <<EOF
subject:${SUBJECT}
from:${FROM}
`cat ${MESSAGE}`
EOF

# Clean up our temporary files
rm ${FILES}
rm ${MESSAGE}
