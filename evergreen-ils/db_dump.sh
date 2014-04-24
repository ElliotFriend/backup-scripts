#!/bin/bash

# In the interest of reducing server load, I'm not bringing in all the
# variables from the var_file, since this script is run the most frequently
# and really contains the fewest variables. I don't know whether or not
# that really does make a performance difference or not, but that's my
# thinking, anyway

# Time stamp to use in the filename
TIMESTAMP=$(date +%Y%m%d_%H)

# Execute pg_dump on the 'evergreendb' database, and place the file in the /backup directory
pg_dump -U evergreen -h localhost -f /backup/evergreen_${TIMESTAMP}.backup evergreendb
