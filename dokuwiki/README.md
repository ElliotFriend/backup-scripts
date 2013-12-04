DokuWiki
=============

I have a DokuWiki server at work that I mostly use to keep track of my
IT documentation. Here's the script I use to back it up, in addition
to our VM-level backups.

This script is run from a server that is remote from the server running
dokuwiki. Adjust your script accordingly, if that's not the case for you.

This script was adapted from the dokuwiki wiki:
https://www.dokuwiki.org/tips:backup_script#an_rsync_alternative

In the end you get:
* A daily rsync of the dokuwiki installation (minus any files in the
  exclude list) that is retained for 15 days. Note that the use of Rsync
  means you will have a complete backup for the first day, and a backup
  of all differences on the following days. Effectively, though, it seems
  like a backup of each day.
* A monthly archive of the dokuwiki installation
