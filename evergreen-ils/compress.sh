#!/bin/bash

## Delcare variables that we'll use to identify the proper directories to compress
#MAILTO=cron@slcconline.edu
LAST_MONTH_FULL=$(date -d '1 month ago' +'%Y%m')
LAST_MONTH_YEAR=$(date -d '1 month ago' +'%Y')
LAST_MONTH_MONTH=$(date -d '1 month ago' +'%m')
# Now, echo those back just to check
#echo "Last month's full date was "$LAST_MONTH_FULL
#echo "Last month's year was "$LAST_MONTH_YEAR
#echo "Last month's month was "$LAST_MONTH_MONTH

## Compress last month's archive directory
tar -zcvf /backup/archive/$LAST_MONTH_YEAR/evergreen_${LAST_MONTH_MONTH}.tar.gz /backup/archive/$LAST_MONTH_YEAR/$LAST_MONTH_MONTH
rm -rf /backup/archive/$LAST_MONTH_YEAR/$LAST_MONTH_MONTH
