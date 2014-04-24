#!/bin/bash

source $(dirname $0)/var_file.sh

# Delcare variables that we'll use to identify the proper directories to compress
# We're keeping these here, because they're not needed by other scripts
LAST_MONTH_FULL=$(date -d '1 month ago' +'%Y%m')
LAST_MONTH_YEAR=$(date -d '1 month ago' +'%Y')
LAST_MONTH_MONTH=$(date -d '1 month ago' +'%m')

# Compress last month's archive directory
tar -zcvf ${BACKUP_DIR}/archive/${LAST_MONTH_YEAR}/evergreen_${LAST_MONTH_MONTH}.tar.gz ${BACKUP_DIR}/archive/${LAST_MONTH_YEAR}/${LAST_MONTH_MONTH}
rm -rf ${BACKUP_DIR}/archive/${LAST_MONTH_YEAR}/${LAST_MONTH_MONTH}
