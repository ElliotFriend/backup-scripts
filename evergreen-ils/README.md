Evergreen-ILS
=============

These are the scripts that I have cron run on our Evergreen-ILS server.
In the end you get:
* An hourly backup of the database that are kept for a week
* A daily backup of the 23:00 database dump that are kept indefinitely
* A collection of daily backups from a given month that are compressed
  into .tar.gz format and retained indefinitely.
* A collection of monthly backups that are compressed into .tar.gz format,
  and are retained indefinitely.

I'm sure this isn't the most elegant solution in the world, but it seems
to be working pretty well for me. I sleep well knowing that I have these
scripts running on my server.

A couple gotchas that you may need to address before you use these:
* These scripts focus heavily on Evergreen's database. I'm not currently
  too concerned with scripting the backups for file customizations, and
  the like. We've got a pretty good VM backup solution in place, so I've
  not focused much on OS-level stuff.
* If you run these scripts according to the 'example.crontab' file, you'll
  end up with an awful lot of backups. If backup space is at a premium
  for you, look into that.
* These scripts don't do much deduplication, removing old backups, or
  anything else along those lines. This means that sometimes manual
  intervention is required. My focus here is on solid, reliable
  backups of the database. We lost our entire electronic catalog once,
  due to poor backup strategy. My intention is to make sure that never
  happens again, at the cost of some extra hard-drive space and time to
  go through the backups once in a while.
* I'm directing most of these backups to the `/backup` directory. For me,
  that directory is an NFS mount on another server, in another part of
  SLCC's campus. Adjust the mount-point/directory/destination to your
  liking.
