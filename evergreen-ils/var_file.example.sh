## File that holds common variables for the various scripts
## Copy this file to 'var_file.sh' and edit accordingly

# General common variables
BACKUP_DIR='/path/to/local/backup/directory'

# Variables for Email Alerts
SUBJECT='Evergreen Cron Alert'
TO='yourname@example.com'
FROM='evergreen@example.com'
MESSAGE='/tmp/archive-message.txt'

# Variables for remote backups
REMOTE_USER='remoteuser'
REMOTE_HOST='example.com'
REMOTE_DIR='/path/to/remote/backup/directory'
